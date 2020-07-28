-- @Author : fangcheng
-- @Date   : 2020-07-28 15:32:45
-- @remark : 


--------------------------------------------------------------------------
print("for in 循环")
--[[
lua for in 循环理解
https://blog.csdn.net/qq_28644183/article/details/71629908

	for k, v in explist do
		print(k, v)
	end
	
	等价于以下代码
	
	local _f, _s, _var = explist
	while true do
		local k, v = _f(_s, _var)
		_var = k
		if _var == nil then break end
		print(k, v)
	end

_s永远不变,_var为可变值
]]



-- 测试:
function func(a1, a2, a3)
	print("func arg", a1, a2)
	if a2 > 5 then
		return
	end
	return a2 + 1, a2
end

local loop = 0
for k,v in func, 1, 2, 3, 4, 5 do --此处只有参数1 2生效
	print(k,v)

	loop = loop + 1
	if loop > 10 then
		break
	end
end

--[[
模拟 ipairs
local function read_key(t, i)
	i = i + 1
	if t[i] then
		return i, t[i]
	end
end

function my_ipairs(tab)
	return read_key, tab, 0
end

for k,v in my_ipairs(tab) do
	print(k,v)
end
]]






--------------------------------------------------------------------------
print("\n\n--------------------------------------------------------------------------")
print("多重赋值")
-- 多重赋值
function funcA()
	return 10, 20
end

a, b, c = funcA(), 30
print(a, b, c)		-- 10	30	nil

a, b, c = 7, funcA()
print(a, b, c) 		-- 7	10	20

a, b, c = 7, 8, funcA()
print(a, b, c) 		-- 7	8	10




