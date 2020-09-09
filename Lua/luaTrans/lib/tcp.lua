-- @Author : fangcheng
-- @Date   : 2020-07-22 18:31:16
-- @remark : TCP套接字封装(包括分包逻辑)

local socket = require("socket")
local EventEmitter = require('EventEmitter')

local STATUS_CLOSED = "closed"
local STATUS_TIMEOUT = "timeout"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"

local log = print

local SocketTCP = class("SocketTCP")

function SocketTCP:ctor(ip, port)
	self.ip = ip
	self.port = port
	self.event = EventEmitter.new()
	self.isConnect = false
	self.writeQue = {}
end

----------------------------------------- public begin -----------------------------------------

function SocketTCP:bind()
	assert(self.tcp == nil)
	self.tcp = socket.tcp()
	local result, err = self.tcp:bind(self.ip, self.port)
	if result == nil then  
		log('tcp bind error:', err)
		return false
	end
	return true
end

function SocketTCP:listen(maxCount)
	local result,err = self.tcp:listen(50)
	if result == nil then  
		log('tcp listen error:', err)
		return false
	end
	self:startRecv()
	return true
end

function SocketTCP:connect()
	self:stopAllCo()
	self.con_connect = oRoutine(o_once(function()
		if self:doconnect() then
			self.isClient = true
			self.con_connect = nil
			self.isConnect = true
			self.event:emit('connect', true)
			self:startRecv()
		else
			self.isConnect = false
			o_wait(o_seconds(1.0))
			self.con_connect = nil
			self.event:emit('connect', false)
		end
	end))
end

function SocketTCP:disconnect()
	self:stopAllCo()
	if self.tcp then
		self.tcp:close()
		self.tcp = nil
		self.writeQue = {}
		self.event:emit('disconnect')
	end
end

function SocketTCP:send(data)
	if not self.isConnect then
		return
	end

	local begin = string.format('0x%08x', string.len(data))
	self.writeQue[#self.writeQue + 1] = begin .. data

	if self.co_send then
		return
	end

	self.co_send = oRoutine(o_loop(function()
		if #self.writeQue <= 0 then
			return
		end

		local data = self.writeQue[1]
		while true do
			if self.tcp == nil then
				self:disconnect()
				break
			end
			local fd = self.tcp
    	    fd:settimeout(0)
    	    local count, status = fd:send(data)
    	    
    	    if (status == STATUS_TIMEOUT) then
    	        log("send data timeout, now yield. fd:", fd)
    	        coroutine.yield()
    	    elseif (status == STATUS_CLOSED) then
    	        log("closed by peer, fd:", fd)
    	        self:disconnect()
    	        break
    	    end
    	    
			if count then
    			data = string.sub(data, count + 1, -1)
    			if string.len(data) <= 0 then
    				break
    			end
    		end
			coroutine.yield()
    	end

    	if #self.writeQue > 0 then
    		table.remove(self.writeQue, 1)
    	end
	end))
end

----------------------------------------- public end -----------------------------------------

function SocketTCP:doconnect()
	if self.tcp then
		self.tcp:close()
		self.tcp = nil
	end
	self.tcp = socket.tcp()
	local succ, err = self.tcp:connect(self.ip, self.port)
	if succ ~= 1 then
		log('tcp connect error:', err)
	end
	if succ == 1 or status == STATUS_ALREADY_CONNECTED then
		return true
	end
	return false
end

function SocketTCP:startRecv()
	assert(self.co_recv == nil)

	self.tcp:settimeout(0)

	self.buffer = ''

	if self.isClient then
		self.co_recv = oRoutine(o_loop(function()
		
			-- 第一种接收逻辑
			local body, status, partial = self.tcp:receive("*a")
    		if status == STATUS_CLOSED or status == STATUS_NOT_CONNECTED then
    			log('tcp receive error:', status)
				self:disconnect()
				return
		    end

		    if 	(body and #body <= 0) or (partial and #partial <= 0) then
				return
			end

		    if body and partial then 
		    	body = body .. partial 
		    end

			if partial then
		    	self.buffer = self.buffer .. partial
		    else
		    	self.buffer = self.buffer .. body
		    end

		    -- 0xffffffff
		    repeat
		    	local buflen = string.len(self.buffer)
		    	if buflen >= 10 then
		    		local count = tonumber(string.sub(self.buffer, 1, 10))
		    		if count == nil or count <= 0 then
		    			self:disconnect()
		    			return
		    		end
		    		if buflen >= count + 10 then
		    			self.event:emit('recv', string.sub(self.buffer, 11, 10 + count))
		    			self.buffer = string.sub(self.buffer, 11 + count, buflen)
		    		else
		    			break
		    		end
		    	else
		    		break
		    	end
		    until(false)
		end))
	else
		self.co_recv = oRoutine(o_loop(function()
			local client, err = self.tcp:accept()
			if client then
				local ip, port = client:getpeername()

				local cliSocket = SocketTCP.new(ip, port)
				cliSocket.isConnect = true
				cliSocket.isClient = true
				cliSocket.tcp = client
				cliSocket:startRecv()
				self.event:emit('newconnect', cliSocket)
			end
		end))
	end
end

function SocketTCP:stopAllCo()
	if self.co_recv then
		oRoutine:remove(self.co_recv)
		self.co_recv = nil
	end
	if self.con_connect then
		oRoutine:remove(self.con_connect)
		self.con_connect = nil
	end
	if self.co_send then
		oRoutine:remove(self.co_send)
		self.co_send = nil
	end
	self.isConnect = false
end

return SocketTCP

