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





