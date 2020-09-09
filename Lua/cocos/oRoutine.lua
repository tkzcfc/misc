-- @Author : fangcheng
-- @Date   : 2020-09-09 17:25:49
-- @remark : 协程封装

local yield = coroutine.yield
local wrap = coroutine.wrap
local table_insert = table.insert
local table_remove = table.remove

local DirectordeltaTime = 0.0
local schedulerid = nil

local function wait(cond)
	repeat
		yield(false)
	until not cond(DirectordeltaTime)
end

local function once(job)
	return wrap(function()
		job()
		return true
	end)
end

local function loop(job)
	return wrap(function()
		repeat yield(false) until job() == true
		return true
	end)
end

local function seconds(duration)
	local time = 0
	return function(deltaTime)
		time = time + deltaTime
		return time < duration
	end
end

local function cycle(duration,work)
	local time = 0
	local function worker()
		local deltaTime = DirectordeltaTime
		time = time + deltaTime
		if time < duration then
			work(time/duration)
			return true
		else
			work(1)
			return false
		end
	end
	while worker() do
		yield(false)
	end
end

local function Routine_end() return true end
local Routine =
{
	remove = function(self,routine)
		for i = 1,#self do
			if self[i] == routine then
				self[i] = Routine_end
				return true
			end
		end
		return false
	end,
	clear = function(self)
		while #self > 0 do
			table_remove(self)
		end
	end,
}

setmetatable(Routine,
{
	__call = function(self,routine)
		table_insert(self,routine)
		return routine
	end,
})

local listener = nil

function Routine:start()
	self:stop()

	listener = function (dt)
		DirectordeltaTime = dt
		local i,count = 1,#self
		while i <= count do
			if self[i]() then
				self[i] = self[count]
				table_remove(self,count)
				i = i-1
				count = count-1
			end
			i = i+1
		end
	end

	local scheduler=cc.Director:getInstance():getScheduler()
	schedulerid = scheduler:scheduleScriptFunc(function (dt)
		DirectordeltaTime = dt
		local i,count = 1,#self
		while i <= count do
			if self[i]() then
				self[i] = self[count]
				table_remove(self,count)
				i = i-1
				count = count-1
			end
			i = i+1
		end
	end, 1 / 60.0, false)
end

Routine.stop = function(self)
	if schedulerid then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerid)
		schedulerid = nil
	end
end

Routine:start()


cc.exports.o_wait 		= wait
cc.exports.o_once 		= once
cc.exports.o_loop 		= loop
cc.exports.o_seconds 	= seconds
cc.exports.o_cycle 		= cycle

cc.exports.oRoutine 	= Routine




-- example

-- oRoutine(o_once(function() 
-- 	o_wait(o_seconds(1.0))
-- 	print("wait 1.0")
-- 	o_wait(o_seconds(5.0))
-- 	print("wait 5.0")
-- end))


-- oRoutine(o_loop(function()
-- 	o_wait(o_seconds(3))
-- 	print("every 3 second")
-- end))

-- local routine = oRoutine(o_once(function()
-- 	o_wait(o_seconds(20))
-- 	print("this routine will be cancelled")
-- end))

-- oRoutine(o_once(function()
-- 	o_wait(o_seconds(10))
-- 	oRoutine:remove(routine)
-- 	print("after 10 seconds, cancel routine above")
-- end))

-- local progress = 0

-- oRoutine(o_once(function()
-- 	o_cycle(2, function(percent)
-- 		progress = percent
-- 	end)
-- end))

-- oRoutine(o_once(function()
-- 	o_wait(function() return progress < 1 end)
-- 	print("now progress is", progress)
-- end))

