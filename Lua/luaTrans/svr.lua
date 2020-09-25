package.path = package.path .. ';lib/?.lua'

require('functions')
require('luasocket')
local EventEmitter = require('EventEmitter')
G_SysEventEmitter = EventEmitter.new()


local system = require('system')
require('oRoutine')

local breakloop = false
function appExit()
	breakloop = true
end

local oldPrint = print
local logFd = io.open("svr.log", "wb+")
local function logFile(...)
	oldPrint(...)

	local log = ""
	for k,v in pairs({...}) do
		log = log .. tostring(v) .. "  "
	end
	local content = "\n[LOG]:" .. log
	logFd:write(content)
end
print = logFile

local FileTransfer = require('FileTransfer')

local ft
local o_ft
-- 接收的文件路径
local file = [[./recv_test.exe]]


local function do_svr()
	local tcp = require('TcpSocket')
	local svr = tcp.new('0.0.0.0', 7000)
	if not svr:bind() then
		print('bind fail')
		return
	end
	svr:listen(1000)
	svr.event:on("newconnect", function(socket)
		print('new socket', tostring(socket))

		ft = FileTransfer.new(file, false, function(data)
			-- print('send', #data, data)
			socket:send(data)
		end, true)
		local startRecvTag = false
		local startTime = 0
		ft:setEventCallback(function(event, data)
			if not startRecvTag then
				startRecvTag = true
				startTime = os.time()
			end
			print("[EVENT]", system:gettime(), "sender", event, data) 
			if event == 'finish' then
				socket:disconnect()
				local subTime = os.time() - startTime
				print("subTime", subTime)
			end
			if event == 'error' then
				print('ERROR1:', FileTransfer.errMsg(data))
				socket:disconnect()
			end
		end)
	
		o_ft = oRoutine(o_loop(function()
			ft:update()
		end))

		socket.event:on('recv', function(data)
			-- print('recv', #data, data)
			ft:input(data)
		end)

		socket.event:on('disconnect', function()
			print('socket close')
			ft:destroy()
			ft = nil
			oRoutine:remove(o_ft)
			appExit()
		end)
	end)
end

do_svr()

local sleeptime = 1 / 1000
local begintime = system:gettime()
local lasttime = begintime
local curtime = begintime
local delta = 0
repeat
	system.sleep(sleeptime)

	curtime = system:gettime()
	delta = curtime - lasttime
	lasttime = curtime
	G_SysEventEmitter:emit('update', delta)

	-- if system:gettime() - begintime > 15 then
	-- 	break
	-- end
until(breakloop)

logFd:close()
