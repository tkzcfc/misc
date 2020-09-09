-- @Author : fangcheng
-- @Date   : 2020-07-22 18:31:16
-- @remark : TCP客户端

local tcp = require('tcp')

local Client = class('Client')

function Client:ctor()
	self.sessions = {}
end

function Client:connect(sessionID, ip, port, enableReconnect, connectCall, recvCall)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			assert(0)
			return
		end
	end

	local so = tcp.new(ip, port)

	self.sessions[#self.sessions + 1] = {sessionID = sessionID, socket = so, isConnect = false, reconnect = enableReconnect}
	
	so.event:on('connect', function(suc)
		self:setSocketConnect(so, suc)
		if connectCall then
			connectCall(suc)
		end
	end)

	so.event:on('disconnect', function()
		self:setSocketConnect(so, false)
	end)

	if recvCall then
		so.event:on('recv', recvCall)
	end

	return so
end

function Client:send(sessionID, data)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			v.socket:send(data)
			break
		end
	end
end

function Client:disconnect(sessionID)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			v.socket:disconnect()
			break
		end
	end
end

function Client:disconnectAll()
	local tmp = {}
	for k,v in pairs(self.sessions) do
		tmp[k] = v
	end

	for k,v in pairs(tmp) do
		v:disconnect()
	end
end

function Client:setReconnect(sessionID, enableReconnect)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			v.reconnect = enableReconnect
			break
		end
	end
end

function Client:removeAll()
	for k,v in pairs(self.sessions) do
		v.removeTag = true
	end
	self:disconnectAll()
	self.sessions = {}
end

function Client:removeSession(sessionID)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			v.removeTag = true
			v.socket:disconnect()
			table.remove(self.sessions, k)
			break
		end
	end
end

function Client:setSocketConnect(socket, isConnect)
	for k,v in pairs(self.sessions) do
		if v.socket == socket then
			v.isConnect = isConnect
			if v.removeTag then
				table.remove(self.sessions, k)
				return
			else
				if v.reconnect then
					v.socket:connect()
				end
			end
			break
		end
	end
end

return Client