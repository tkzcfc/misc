-- @Author : fangcheng
-- @Date   : 2020-07-22 18:31:16
-- @remark : 未用到，准备做一个远程管理工具，这个类用于指令解析执行

local FileTool = require('FileTool')
local FileTransfer = require('FileTransfer')

local EMSG_TYPE = 
{
	attachReq = 0,	-- c2p
	attachReply = 1,-- p2c
	localFileOpReq = 2,
	localFileOpReply = 3,
	executeReq = 4,
	executeReply = 5,
	doStringReq = 6,
	doStringReply = 7,
	OpErrReply = 8,
}

local Peer = {}

function Peer.new(...)
	Peer.__index = Peer
	local t = setmetatable({}, Peer)
	t:ctor(...)
	return t
end

function Peer:ctor()
	self.rootDir = lfs.currentdir()
	
end

function Peer:onData(msg)
	local status, err = pcall(function()
		local switch = 
		{
			attachReq = self.attach,
			localFileOpReq = self.localFileOp,
			executeReq = self.execute,
			doStringReq = self.doString,
		}
		if switch[msg.type] then
			switch[msg.type](self, msg.data)
		else
			self:sendData(EMSG_TYPE.OpErrReply, 'Illegal operation')
		end
	end)
	if not status then
		self:sendData(EMSG_TYPE.OpErrReply, err)
	end
end

local StringArgFail = 'error'

function Peer:checkStringArg(arg)
	return type(arg) == 'string' 
end

function Peer:localFileOp(data)
	local option = data.option
	local arg = data.arg

	local reply = {}
	reply.result = false
	reply.error = ''

	local singleArgStrRetNull = 
	{
		"removeDir",
		"createDir",
		"removeFile",
	}
	for k,v in pairs(singleArgStrRetNull) do
		if v == option then
			if self:checkStringArg(arg[1]) then
				reply.result, reply.error = FileTool[option](arg[1])
			else
				reply.error = StringArgFail
			end
			self:sendData(EMSG_TYPE.localFileOpReply, reply)
			return
		end
	end


	local singArgStrRetData = 
	{
		"dirChildren",
		"getAllFiles",
		"getDirSize",
	}
	for k,v in pairs(singArgStrRetData) do
		if v == option then
			if self:checkStringArg(arg[1]) then
				reply.result = true
				reply.data = FileTool[option](arg[1], arg[2])
			else
				reply.error = StringArgFail
			end
			self:sendData(EMSG_TYPE.localFileOpReply, reply)
			return
		end
	end


	local twoArgStrRetNull = 
	{
		"renameFile",
		"copyFile",
		"renameDir",
		"copyDir",
	}
	for k,v in pairs(singArgStrRetData) do
		if v == option then
			if self:checkStringArg(arg[1]) and self:checkStringArg(arg[2]) then
				reply.result, reply.error = FileTool[option](arg[1], arg[2])
			else
				reply.error = StringArgFail
			end
			self:sendData(EMSG_TYPE.localFileOpReply, reply)
			return
		end
	end

	reply.error = 'invalid operation'
	self:sendData(EMSG_TYPE.localFileOpReply, reply)
end

function Peer:attach(data)
	self:sendData(EMSG_TYPE.attachReply, {
		rootDir = self.rootDir,
	})
end

function Peer:execute(data)
	self:sendData(EMSG_TYPE.executeReply, {
		os.execute(data.arg)
	})
end

function Peer:doString(data)
	local reply = {}
	local runTag = true
	local status, err = pcall(function()
		local func, loaderr = loadstring(data)
		if not func then
			runTag = false
			reply.status = false
			reply.err = loaderr
		end
		func()
	end)

	if runTag then
		reply.status = status
		reply.err = err
	end
	self:sendData(EMSG_TYPE.doStringReply, reply)
end

function Peer:sendData(msgName, msg)
	-- {type = msgName, data = msg}
end





-- local subprocess = require('subprocess')
-- for k,v in pairs(subprocess) do
-- 	print(k,v)
-- end

-- local exe = [[C:\Users\ASus\Desktop\ConsoleApplication1\Debug\ConsoleApplication1.exe]]

-- local arg = {
-- 	exe,
-- 	close = function() 
-- 		print('call close') 
-- 	end,
-- 	wait = function()
-- 		print('call wait')
-- 	end,
-- 	-- stdout = 'stdout.txt'
-- 	stdout = subprocess.PIPE
-- }
-- local proc, msg = subprocess.popen(arg)

-- if not proc then
-- 	print('error:', msg)
-- else
-- 	print("stdin, stdout, stderr", proc.stdin, proc.stdout, proc.stderr)
-- 	print('msg:', proc, msg)
-- 	for k,v in pairs(arg) do
-- 		print(k,v)
-- 	end
-- end

-- outfile = nil
-- local content = nil

-- repeat
-- 	-- local con = proc.stdout:read("*a")
-- 	-- if content ~= con then
-- 	-- 	content = con
-- 	-- 	print('content:', con)
-- 	-- end
-- 	-- if outfile == nil then
-- 	-- 	outfile = io.open(arg.stdout, 'rb')
-- 	-- end
-- 	-- if outfile then
-- 	-- 	local con = outfile:read("*a")
-- 	-- 	if content ~= con then
-- 	-- 		content = con
-- 	-- 		print('std::out<<', content)
-- 	-- 	end
-- 	-- end
-- until(proc:poll())

-- 	print('r1', os.clock())
-- 	print("run:", proc.stdout:read("*a"))
-- 	print('r2', os.clock())
-- -- if outfile then
-- -- 	outfile:close()
-- -- end

-- print('run finish------>>>')

