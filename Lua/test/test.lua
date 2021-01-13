-- @Author : fangcheng
-- @Date   : 2020-06-24 10:19:07
-- @remark : 



local smooth = function(a, b, x)
	if x < a then
		return 0.0
	end
	if x >= b then
		return 1.0
	end
	local y = (x - a) / (b - a)
	return (y * y * (3.0 - 2.0 * y))
end

-- local length = 100
-- for i=1,length do
-- 	print(smooth(0, 1.0, i / length), i / length)
-- end


local function smooth_pulse(e0, e1, e2, e3, x)
	return smooth(e0, e1, x) - smooth(e2, e3, x)
end

local t = {
	name = "AAA",
	age = 100
}

-- print(next(t))
-- print(next(t, "name"))
-- print(next(t, "age"))
-- print(next(t, nil))


local function myPairs(t)
	return next, t, nil
end

for k,v in myPairs(table) do
	print(k, "=", v)
end

table.foreach(table, function(k, v)
	print(k, "=", v)
end)

t1 = {2, 4, 6, language="Lua", version="5", 8, 10, 12, web="hello lua"};
table.foreachi(t1, function(i, v) print (i, v) end) ; --等价于 foreachi(t1, print)
