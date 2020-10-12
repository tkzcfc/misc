-- @Author : fangcheng
-- @Date   : 2020-10-12 18:05:07
-- @remark : Hash表实现


local HashTable = {}

-- 最小容量
local HashTableOpacityMin = 10

HashTable.__index = HashTable

------------------------------------------- static -------------------------------------------

function HashTable.new(...)
	local t = setmetatable({}, HashTable)
	t:ctor(...)
	return t
end

------------------------------------------- public -------------------------------------------

-- @param hashFunc hash函数
-- @param capacity 初始size
-- @param stepScaleSize 重构增长size倍数
function HashTable:ctor(hashFunc, capacity, stepScaleSize)
	self.hashFunc = hashFunc
	assert(self.hashFunc ~= nil)

	self.stepScaleSize = stepScaleSize or 1
	-- 数据桶
	self.bucket = {}
	-- 标记数组
	self.tag = {}
	-- 当前数据数量
	self.size = 0
	-- 桶当前容量
	self.capacity = capacity or 10

	for i = 1, self.capacity do
		self.bucket[i] = {}
		self.tag[i] = 0
	end
end

-- @brief hash 表插入数据
function HashTable:insert(key, value)
	local data, idx, count = self:_search(key)
	
	-- 冲突次数过多,进行重构
	if count > self.capacity * 0.5 then
		self:_recreateHashTable(1)
		self:insert(key, value)
	else
		local cur = self.bucket[idx]
		assert(cur == data)
	
		if self.tag[idx] ~= 1 then
			self.size = self.size + 1
		end
	
		self.tag[idx] = 1
		cur.key = key
		cur.value = value
	end
end

-- @brief hash表删除数据
function HashTable:delete(key)
	local data, idx, count = self:_search(key)

	if self.tag[idx] == 1 and data.key == key then
		self.bucket[idx] = {}-- 此处请不请空无所谓,只要tag为-1,这个数据块都不会再使用
		self.tag[idx] = -1
		self.size = self.size - 1
		return true
	end
	return false
end

-- @brief 查找数据
function HashTable:find(key)
	local data, idx, count = self:_search(key)
	if self.tag[idx] == 1 and data.key == key then
		return data.value
	end
end

-- @brief 清除所有数据
function HashTable:clear()
	for i = 1, self.capacity do
		self.tag[i] = 0
	end
	self.size = 0
	self:optimize()
end

-- @brief 优化hash表
function HashTable:optimize()
	-- 元素被删除到很少了,重构一下
	if self.capacity > HashTableOpacityMin and self.size < self.capacity * 0.3 then
		self:_recreateHashTable(-1)
	end
end

-- @brief 打印hash表
function HashTable:print()
	print("size:", self.size)
	for i = 1, self.capacity do
		local key = tostring(self.bucket[i].key)
		local value = tostring(self.bucket[i].value)
		print(string.format("%d  tag:%d data:{key : %s, value : %s}", i, self.tag[i], key, value))
	end
	print("\n\n")
end

------------------------------------------- private -------------------------------------------

-- @brief 重构hash表
-- @param capacityOp 容量操作 1增加 -1减少 其他不变
function HashTable:_recreateHashTable(capacityOp)
	-- 计算新的容量
	local newCapacity = self.capacity
	if capacityOp == 1 then
		newCapacity = newCapacity + math.ceil(self.capacity * self.stepScaleSize)
	elseif capacityOp == -1 then
		newCapacity = self.size * 2
		if newCapacity < HashTableOpacityMin then newCapacity = HashTableOpacityMin end
	end

	local bucket = self.bucket
	local tag = self.tag

	-- 数据桶
	self.bucket = {}
	-- 标记数组
	self.tag = {}
	-- 当前数据数量
	self.size = 0
	-- 桶当前容量
	self.capacity = newCapacity

	for i = 1, self.capacity do
		self.bucket[i] = {}
		self.tag[i] = 0
	end

	-- 将之前的数据插入新桶
	for k,v in pairs(bucket) do
		if tag[k] == 1 then
			self:insert(v.key, v.value)
		end
	end
end

function HashTable:_search(key)
	assert(key ~= nil)

	local hash = self.hashFunc(key)
	hash = self:_collision(hash)

	local data = self.bucket[hash]
	local count = 0
	
	repeat
		-- 数据不存在
		if self.tag[hash] == 0 then
			break
		end

		-- 找到目标数据
		if self.tag[hash] ~= -1 and self.bucket[hash].key == key then
			break
		end

		-- 没有可存储的位置了
		if count > self.capacity then
			-- 此时返回的data数据是错误的,外部应该判断他的key是否相等
			break
		end

		hash = self:_collision(hash)
		data = self.bucket[hash]
		count = count + 1
	until(false)

	return data, hash, count
end

-- 碰撞调整
function HashTable:_collision(hash)
	return (hash % self.capacity) + 1 -- lua table 下标从1开始 所以此处+1
end








------------------------------------------------------------
-- test
------------------------------------------------------------

-- 字符串hash化
local function HashString( v )
	local MaxStringBankBinSize = 524288
	local val = 0
	local fmod = math.fmod
	local gmatch = string.gmatch
	local byte = string.byte
	local MaxStringBankBinSize = MaxStringBankBinSize
	local c
	for _c in gmatch( v, "." ) do
		c = byte( _c )
		val = val + c * 193951
		val = fmod( val, MaxStringBankBinSize )
		val = val * 399283
		val = fmod( val, MaxStringBankBinSize )
	end
	return val
end

local hash = HashTable.new(HashString, 10)

local loopCount = 1000

local gen_key = function(i) return "key_" .. i end
local gen_value = function(i) return "value_" .. i * 100 end

print("插入操作测试----------------------------->>")

for i = 1, loopCount do
	hash:insert(gen_key(i), gen_value(i))
end
-- 数据校验
for i = 1, loopCount do
	local key = gen_key(i)
	local value = hash:find(key)
	if value ~= gen_value(i) then
		print("bad data in", key)
	end
end
print("size", hash.size)
print("capacity", hash.capacity)



print("删除操作测试----------------------------->>")
for i = 1, loopCount - 10 do
	local key = gen_key(i)
	if not hash:delete(key) then
		print("can not delete", key)
	end
	-- 数据校验
	local value = hash:find(key)
	if value ~= nil then
		print("bad data in", key)
	end
end

print("size", hash.size)
print("capacity", hash.capacity)




print("优化操作测试----------------------------->>")
-- 大量删除操作之后调用此函数,会重构一下hash表结构,是否不使用的内存
hash:optimize()
print("size", hash.size)
print("capacity", hash.capacity)




print("清空操作测试----------------------------->>")
-- 删除所有,内部也会调用一次 optimize 函数
hash:clear()

print("size", hash.size)
print("capacity", hash.capacity)



