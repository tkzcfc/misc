local FileTool = require('FileTool')


-- 内容是否启用base64加密文本
local USE_BASE64_DECODE = true
-- 是否使用json打包消息
local USE_JSON_PACK_MSG = true
-- 是否使用system库
local USE_LUA_SYSTEM = true

local json, base64, luasystem

if USE_JSON_PACK_MSG then
	json = require('cjson')
end

if USE_BASE64_DECODE then
	base64 = require('base64')
end

if USE_LUA_SYSTEM then
	luasystem = require('system')
end

local E_Event = 
{
	ready = 'ready',
	run = 'run',
	finish = 'finish',
	error = 'error'
}

local E_STATUS = 
{
	none = 0,
	init = 1,
	wait_read = 2,
	wait_write = 3,
	run = 4,
	err = 5,
}

-- 缓存阀值
local FILE_CACHE_THRESHOLD = 1024 * 1024
-- 单次分片大小
local FRAGMENT_SIZE = 1024*60

local ERR_COM_BEGIN	 = 10000
local ERR_SEND_BEGIN = 20000
local ERR_RECV_BEGIN = 30000
local E_ERR_CODE = 
{
	ERR_MSG_PARSE_FAIL = ERR_COM_BEGIN + 1,
	ERR_PACK_MSG_FAIL = ERR_COM_BEGIN + 2,

	-- sender
	ERR_FILE_NO_EXIST = ERR_SEND_BEGIN + 1,
	ERR_INTERNAL_1 = ERR_SEND_BEGIN + 2,
	ERR_INTERNAL_2 = ERR_SEND_BEGIN + 3,
	ERR_INTERNAL_3 = ERR_SEND_BEGIN + 4,

	-- recv
	ERR_FILE_EXIST = ERR_RECV_BEGIN + 1,
	ERR_CREATE_TMP_FILE_FAIL = ERR_RECV_BEGIN + 2,
	ERR_WRITE_ERR_1 = ERR_RECV_BEGIN + 3,
	ERR_WRITE_ERR_2 = ERR_RECV_BEGIN + 4,
	ERR_REMOVE_TMP_FAIL = ERR_RECV_BEGIN + 5,
	ERR_RENAME_FAIL = ERR_RECV_BEGIN + 6,
	ERR_UNKNOWN_1= ERR_RECV_BEGIN + 7,
}

local E_ERR_STR = 
{
	[E_ERR_CODE.ERR_MSG_PARSE_FAIL] = 'message parsing failed',
	[E_ERR_CODE.ERR_PACK_MSG_FAIL] = 'failed to package message',

	[E_ERR_CODE.ERR_FILE_NO_EXIST] = 'target file does not exist or does not have read permission',
	[E_ERR_CODE.ERR_INTERNAL_1] = 'internal error 1',
	[E_ERR_CODE.ERR_INTERNAL_2] = 'internal error 2',
	[E_ERR_CODE.ERR_INTERNAL_3] = 'internal error 3, read content nil',

	[E_ERR_CODE.ERR_FILE_EXIST] = 'target file already exists',
	[E_ERR_CODE.ERR_CREATE_TMP_FILE_FAIL] = 'temporary file creation failed',
	[E_ERR_CODE.ERR_WRITE_ERR_1] = 'write data failed, terminate transfer, code = 1',
	[E_ERR_CODE.ERR_WRITE_ERR_2] = 'write data failed, terminate transfer, code = 2',
	[E_ERR_CODE.ERR_REMOVE_TMP_FAIL] = 'failed to remove temporary file',
	[E_ERR_CODE.ERR_RENAME_FAIL] = 'rename failed',
	[E_ERR_CODE.ERR_UNKNOWN_1] = 'unknown error 1',
}

local log = print

local function gettime()
	if USE_LUA_SYSTEM then
		return luasystem:gettime()
	end
	return os.clock()
end

----------------------------------------------FlowControl----------------------------------------------

local FlowControl = {}

-- 流控是否开启(只有发送端开启流控才限制速度，接收端是不限速的，因为接收端每次发送的数据量很小)
FlowControl.enable = false
-- 流控，每秒最大发送字节数
FlowControl.maxSpeed = 1024*1024

function FlowControl.new()
	FlowControl.__index = FlowControl
	return setmetatable({}, FlowControl)
end

--------------------------------------------------------------------------------------------------------

local FileTransfer = {}

function FileTransfer.new(...)
	FileTransfer.__index = FileTransfer
	local t = setmetatable({}, FileTransfer)
	t:ctor(...)
	return t
end

-- sttaic
function FileTransfer.errMsg(errCode)
	return E_ERR_STR[errCode]
end

-- localfile : 本地文件
-- isSender : 是否为发送端
-- sendCall : 发送消息回调函数
-- enableRenewal : 是否启用断点续传(发送端无效)
function FileTransfer:ctor(localfile, isSender, sendCall, enableRenewal)

	if enableRenewal == nil then enableRenewal = true end

	self.localfile = localfile
	self.tmpfile = self:tmpFileName(self.localfile)
	self.sender = isSender
	self.curIndex = 0
	self.totalSize = 0
	self.sendCall = sendCall
	self.enableRenewal = enableRenewal
	self.status = E_STATUS.none
	
	self.flowControl = FlowControl.new()
	self.flowControl.cache_sendQue = {}
	self.flowControl.lastSendTime = 0
	self.flowControl.curSendSize = 0
	self.flowControl.sendQueDirty = false
end

---------------------------------------------public begin---------------------------------------------

function FileTransfer:setEventCallback(call)
	self.evetCall = call
end

function FileTransfer:destroy()
	if self.fd then
		self.fd:close()
		self.fd = nil
	end
	if self.co_run then
		oRoutine:remove(self.co_run)
		self.co_run = nil
	end
end

function FileTransfer:input(content)
	if self.status == E_STATUS.err then
		return
	end

	local msg = nil
	local status, err = pcall(function()
		if USE_JSON_PACK_MSG then
			msg = json.decode(content)
		else
			msg = content
		end
	end)

	if not status then
		log(err)
		print('\n', content)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_MSG_PARSE_FAIL)
		return		
	end

	if not msg then
		assert(0)
		return
	end

	local msgName = msg.name
	local data = msg.data

	if msgName == 'try_read' then
		self:msg_try_read(data)
	elseif msgName == 'try_write' then
		self:msg_try_write(data)
	elseif msgName == 'read' then
		self:msg_read(data)
	elseif msgName == 'write' then
		self:msg_write(data)
	elseif msgName == 'read_err' then
		self:msg_read_err(data)
	elseif msgName == 'write_err' then
		self:msg_write_err(data)
	elseif msgName == 'read_end' then
		self:msg_read_end(data)
	elseif msgName == 'write_end' then
		self:msg_write_end(data)
	end
end

function FileTransfer:run()
	self.co_run = oRoutine(o_loop(function()
		self:update()
	end))
end

function FileTransfer:update()
	if self.status == E_STATUS.none then
		self:_check()
	elseif self.status == E_STATUS.init then
		self:_init()
	elseif self.status == E_STATUS.wait_read then
		self:sendData('try_read', {start = self.curIndex})
	end

	if self.flowControl.sendQueDirty then
		local cur = gettime()
		if math.abs(cur - self.flowControl.lastSendTime) >= 1.0 then
			self.flowControl.curSendSize = 0
			self.flowControl.lastSendTime = cur
		end

		if self.flowControl.curSendSize > self.flowControl.maxSpeed then
			return
		end

		local que = self.flowControl.cache_sendQue
		local size = self.flowControl.curSendSize
		local idx = 0

		for k, v in pairs(que) do
			idx = k
			size = size + #v
			if size >= self.flowControl.maxSpeed then
				break
			end
		end
		self.flowControl.curSendSize = size

		local newQue = {}
		for i = 1, #que do
			if i <= idx then
				self.sendCall(que[i])
			else
				newQue[#newQue + 1] = que[i]
			end
		end

		self.flowControl.cache_sendQue = newQue
		self.flowControl.sendQueDirty = #newQue > 0
	end
end

---------------------------------------------public end---------------------------------------------

function FileTransfer:tmpFileName(file)
	return file .. '.tmp'
end

function FileTransfer:onEvent(event, data)
	if self.evetCall then
		self.evetCall(event, data)
	end

	if event == E_Event.error then
		self.status = E_STATUS.err
	end
end

function FileTransfer:sendData(msgName, msg)
	local t = {name = msgName, data = msg}
	
	local content = nil
	local status, err = pcall(function()
		if USE_JSON_PACK_MSG then
			content = json.encode(t)
		else
			content = t
		end
	end)

	if not status then
		log(err)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_PACK_MSG_FAIL)
		return		
	end

	if self.flowControl.enable then
		self.flowControl.cache_sendQue[#self.flowControl.cache_sendQue + 1] = content
		self.flowControl.sendQueDirty = true
	else
		self.sendCall(content)
	end
end

function FileTransfer:_check()
	assert(self.status == E_STATUS.none)
	if self.sender then
		local fd = io.open(self.localfile, 'rb')
		if not fd then
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_FILE_NO_EXIST)
			return 0, E_ERR_CODE.ERR_FILE_NO_EXIST
		end

		local filesize = fd:seek("end")
		-- 小于缓冲阀值，直接读取所有内容到内存中
		if filesize <= FILE_CACHE_THRESHOLD then
			fd:seek('set', 0)
			self.cache_content = fd:read("*a")
			fd:close()
		else
			self.fd = fd
		end
		self.curIndex = 0
		self.totalSize = filesize
		self.status = E_STATUS.wait_write
	else
		if FileTool.fileCheck(self.localfile) then
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_FILE_EXIST)
			return
		end
		self.status = E_STATUS.init
		if not self.enableRenewal and FileTool.fileCheck(self.tmpfile) then
			local s, e = FileTool.removeFile(self.tmpfile)
			if not s then
				log('failed to remove temporary file')
				self:sendData('read_err', E_ERR_CODE.ERR_REMOVE_TMP_FAIL)
				self:onEvent(E_Event.error, E_ERR_CODE.ERR_REMOVE_TMP_FAIL)
				return
			end
		end
	end
end

function FileTransfer:_init()
	if self.fd then
		assert(false)
		return
	end
	local fd = nil
	fd = io.open(self.tmpfile, 'rb')
	if fd then
		self.curIndex = fd:seek('end')
		fd:close()
	end
	fd = io.open(self.tmpfile, 'ab+')
	if fd == nil then
		log(string.format('Failed to create file \'%s\', code = 1', tostring(self.tmpfile)))
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_CREATE_TMP_FILE_FAIL)
		return
	end
	self.fd = fd
	self.status = E_STATUS.wait_read
end


----------------------------------------------- 发送者 -----------------------------------------------

function FileTransfer:msg_try_read(data)
	if self.status ~= E_STATUS.wait_write then
		return
	end

	self.curIndex = data.start
	-- 临时文件无效
	if data.start > self.totalSize then
		self.curIndex = 0
	end

	self:sendData('try_write', {start = self.curIndex, total = self.totalSize})
	self.status = E_STATUS.run
	self:onEvent(E_Event.ready)
end

function FileTransfer:msg_read(data)
	if not self.sender or self.status ~= E_STATUS.run then
		assert(false)
		return
	end
	self.curIndex = data.b
	local begin = self.curIndex
	local e = self.curIndex + FRAGMENT_SIZE
	if begin > self.totalSize then
		self:sendData('write_err', E_ERR_CODE.ERR_INTERNAL_1)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_INTERNAL_1)
		return
	end
	if self.fd == nil and self.cache_content == nil then
		self:sendData('write_err', E_ERR_CODE.ERR_INTERNAL_2)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_INTERNAL_2)
		return
	end

	e = math.min(e, self.totalSize)

	local size = e - begin
	-- send suc
	if size <= 0 then
		self:sendData('write_end')
		self:onEvent(E_Event.run, 1)
		return
	end

	local content = ''
	if self.fd then
		self.fd:seek("set", begin)
		content = self.fd:read(size)
	else
		content = string.sub(self.cache_content, begin + 1, e)
	end

	if content == nil then
		self:sendData('write_err', E_ERR_CODE.ERR_INTERNAL_3)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_INTERNAL_3)
		return
	end
	if USE_BASE64_DECODE then
		content = base64.encode(content)
	end
	self:onEvent(E_Event.run, begin / self.totalSize)
	self:sendData('write', {b = begin, s = size, c = content})
end

function FileTransfer:msg_read_err(data)
	self:onEvent(E_Event.error, data)
end

function FileTransfer:msg_read_end(data)
	self:onEvent(E_Event.finish)
end

----------------------------------------------- 接收者 -----------------------------------------------

function FileTransfer:msg_try_write(data)
	if self.status ~= E_STATUS.wait_read then
		return
	end

	-- 发送端重定向了下标，删除缓存文件
	if self.curIndex ~= data.start then
		self.fd:close()
		local s, e = FileTool.removeFile(self.tmpfile)
		if not s then
			log('failed to remove temporary file')
			self:sendData('read_err', E_ERR_CODE.ERR_REMOVE_TMP_FAIL)
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_REMOVE_TMP_FAIL)
			return
		end
		
		self.fd = io.open(self.tmpfile, 'ab+')
		if self.fd == nil then
			log(string.format('Failed to create file \'%s\', code = 2', tostring(self.tmpfile)))
			self:sendData('read_err', E_ERR_CODE.ERR_CREATE_TMP_FILE_FAIL)
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_CREATE_TMP_FILE_FAIL)
			return
		end
	end
	self.curIndex = data.start
	self.totalSize = data.total
	self.status = E_STATUS.run
	self:onEvent(E_Event.ready)
	self:tryRead()
end

function FileTransfer:tryRead()
	if self.sender or self.status ~= E_STATUS.run then
		assert(false)
		return
	end
	self:sendData('read', {b = self.curIndex})
end

function FileTransfer:msg_write(data)
	local begin = data.b
	local size = data.s
	local content = data.c
	if self.fd == nil then
		self:sendData('read_err', E_ERR_CODE.ERR_WRITE_ERR_1)
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_WRITE_ERR_1)
		return
	end

	if self.totalSize > 0 then
		self:onEvent(E_Event.run, (begin + size) / self.totalSize)
	else
		self:onEvent(E_Event.run, 1.0)
	end

	self.curIndex = begin + size
	if size > 0 then
		if USE_BASE64_DECODE then
			content = base64.decode(data.c)
		end
		self.fd:seek("set", begin)
		if not self.fd:write(content) then
			self:sendData('read_err', E_ERR_CODE.ERR_WRITE_ERR_2)
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_WRITE_ERR_2)
			return
		end
	end
	self:tryRead()
end

function FileTransfer:msg_write_end(data)
	if self.sender then
		assert(false)
		return
	end
	if self.curIndex == self.totalSize then
		self:sendData('read_end')

		if self.fd then
			self.fd:close()
			self.fd = nil
		end
		local s, e = FileTool.renameFile(self.tmpfile, self.localfile)
		if not s then
			log(e)
			self:onEvent(E_Event.error, E_ERR_CODE.ERR_RENAME_FAIL)
		else
			self:onEvent(E_Event.finish)
		end
	else
		self:onEvent(E_Event.error, E_ERR_CODE.ERR_UNKNOWN_1)
		-- assert(false)
	end
end

function FileTransfer:msg_write_err(data)
	self:onEvent(E_Event.error, data)
end

return FileTransfer

--------------------------------------------------------------------------------------------------------
