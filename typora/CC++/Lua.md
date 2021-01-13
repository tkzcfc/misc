



# 语法理解

## for in 循环

https://blog.csdn.net/qq_28644183/article/details/71629908

### 测试

```lua
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
func arg	1	2
3	2
func arg	1	3
4	3
func arg	1	4
5	4
func arg	1	5
6	5
func arg	1	6
]]
```



### pairs实现

```lua
	for k, v in explist do
		print(k, v)
	end
	
	-- 等价于以下代码
	
	local _f, _s, _var = explist
	while true do
		local k, v = _f(_s, _var)
		_var = k
		if _var == nil then break end
		print(k, v)
	end

-- _f 迭代函数
-- _s 不可变状态
-- _var 控制变量初始值


-- pairs函数实现
local function myPairs(t)
	return next, t, nil
end

for k,v in myPairs(table) do
	print(k, "=", v)
end
```



## table

### foreach

```lua
table.foreach(table, function(k, v)
	print(k, "=", v)
end)

t1 = {2, 4, 6, language="Lua", version="5", 8, 10, 12, web="hello lua"};
table.foreachi(t1, function(i, v) print (i, v) end) ; --等价于 foreachi(t1, print)
```



