-- @Author : fangcheng
-- @Date   : 2020-07-22 18:31:16
-- @remark : TCP服务端

local tcp = require('tcp')

local Server = class('Server')

function Server:start(ip, port, newConCall, maxCount)
	assert(self.svr == nil)
	assert(newConCall ~= nil)

	local svr = tcp.new(ip, port)
	
	if not svr:bind() then
		return false
	end
	
	svr:listen(maxCount or 0xffff)

	self.svr = svr
	self.startTag = true
	self.sessionIDSeed = 0xff
	self.sessions = {}

	svr.event:on("newconnect", function(socket)

		self.sessionIDSeed = self.sessionIDSeed + 1
		self.sessions[#self.sessions + 1] = {sessionID = self.sessionIDSeed, socket = socket}

		socket.event:on('disconnect', function()
			for k,v in pairs(self.sessions) do
				if v.socket == socket then
					table.remove(self.sessions, k)
					break
				end
			end
		end)

		if newConCall then
			newConCall(socket, self.sessionIDSeed)
		end
	end)
end

function Server:close()
	self:disconnectAll()
	self.svr:disconnect()
	self.svr = nil
	self.startTag = false
end

function Server:disconnectAll()
	local tmp = {}
	for k,v in pairs(self.sessions) do
		tmp[k] = v
	end

	for k,v in pairs(tmp) do
		v:disconnect()
	end

	self.sessions = {}
end

function Server:disconnect(sessionID)
	for k,v in pairs(self.sessions) do
		if v.sessionID == sessionID then
			table.remove(self.sessions, k)
			v.socket:disconnect()
			break
		end
	end
end

return Server