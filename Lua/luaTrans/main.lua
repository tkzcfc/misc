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
local logFd = io.open("client.log", "wb+")
local function logFile(...)
	local t = {...}
	local content = "\n[LOG]:" .. table.concat(t, " ")
	logFd:write(content)
	oldPrint(...)
end
print = logFile


require('entry')

local sleeptime = 1 / 100
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

