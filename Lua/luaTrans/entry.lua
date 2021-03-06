-- oRoutine(o_loop(function()
-- 	o_wait(o_seconds(3))
-- 	print("every 3 second")
-- end))


local FileTransfer = require('FileTransfer')
local system = require('system')
local tcp = require('TcpSocket')
-- local cli = tcp.new('47.75.218.200', 1007)
local cli = tcp.new('127.0.0.1', 7000)

local ft
local o_ft

-- 要发送的文件路径
local file = [[./testfile.exe]]

cli.event:on("connect", function(suc)
	if suc then
		print('connect suc')

		ft = FileTransfer.new(file, true, function(data)
			-- print('send', #data, data)
			cli:send(data)
		end, true)
		-- 是否开启限速
		ft.flowControl.enable = true
		-- 每秒最大传输字节数
		ft.flowControl.maxSpeed = 1024*1024

		ft:setEventCallback(function(event, data)
			print("[EVENT]", system:gettime(), "sender", event, data) 
			if event == 'finish' then
				cli:disconnect()
			end
			if event == 'error' then
				print('ERROR1:', FileTransfer.errMsg(data))
				cli:disconnect()
			end
		end)

		o_ft = oRoutine(o_loop(function()
			ft:update()
		end))
	else
		print('connect fail')
		ft:destroy()
		ft = nil
		oRoutine:remove(o_ft)
		appExit()
	end
end)

cli.event:on('disconnect', function() 
	print('client disconnect')
	appExit()
end)

cli.event:on('recv', function(data)
	-- print('recv', #data, data)
	ft:input(data)
end)

cli:connect()
