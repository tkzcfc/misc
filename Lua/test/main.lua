




-- local str = "<font   color=#ffffff>测试测试</font><font color=#37f70b>%dXXX</font>"

-- str = string.match(str, "<%s*font.->.-</%s-font%s->")
-- print(str)

-- print(string.match(str, "<%s*font.-#(%w%w%w%w%w%w)>"))

-- str = string.match(str, "<font.->(.*)</%s-font%s->")
-- print(str)

-- _, count = string.gsub(str, "[^\128-\193]", "")
-- print(count)

-- local code = [[\
-- 		function name(name) 
-- 			local function testFunc()
-- 			end
-- 			if true then 
-- 				print
-- 			end

-- 		end
-- 		]]


-- str = string.match(code, "function%s+%w+%s-%(%s-%w*%s-%)%s*(.*)%s*end")
-- print(str)



local Width = 10
local Height = 10

local map = {}

local function printMap(map)
    print("----------------------- begin")
    for i = 0, Height - 1 do
        local str = ""
        for j = 0, Width - 1 do
            str = str .. tostring(map[i][j]) .. " "
        end
        print(str)
    end
    print("----------------------- end")
end

for i=0 , Height - 1 do
    map[i] = {}
    for j= 0, Width - 1 do
        map[i][j] = j
    end
end

function reset(map)
for i=0 , Height - 1 do
    for j= 0, Width - 1 do
        map[i][j] = 0
    end
end
end

-- printMap(map)
-- reset(map)
-- printMap(map)


reset(map)

local function around(center, level)
    if level < 1 then
        return {}
    end

    local t = {}
    local beginX = center.x - level
    local beginY = center.y - level
    local range = level * 2

    for i = beginY, beginY + range do
        if i >= 0 and i < Height then
            for j = beginX, beginX + range do
                if j >= 0 and j < Width then
                    if i == center.y and j == center.x then
                    else
                        t[#t + 1] = {x = j, y = i}
                    end
                end
            end
        end
    end

    return t
end

local t = around({x = 8, y = 9}, 3)

for k,v in pairs(t) do
    map[v.y][v.x] = 1
end

printMap(map)



local m = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    320, 80, 0, 1,
}


local function mat_mut_vec4(m, v)
    local x = m[1] * v.x + m[5] * v.y + m[9] * v.z  + m[13] * v.w
    local y = m[2] * v.x + m[6] * v.y + m[10] * v.z + m[14] * v.w
    local z = m[3] * v.x + m[7] * v.y + m[11] * v.z + m[15] * v.w
    local w = m[4] * v.x + m[8] * v.y + m[12] * v.z + m[16] * v.w
    return {x, y, z, w}
end

local v4 = {x = 0, y = 0, z = 0, w = 1}
local out = mat_mut_vec4(m, v4)

for k,v in pairs(out) do
    print(k,v)
end



local m = {
    1.00000000, -1.12853371e-07, -4.10752676e-08, 0.000000000, 
    0.000000000, 0.342020154, -0.939692616, 0,
    1.20096047e-07, 0.939692616, 0.342020154, 0.000000000,
    320.000000, 211.595978, 187.938522, 1.00000000
}


local v4 = {x = 0, y = 0, z = 0, w = 1}
local out = mat_mut_vec4(m, v4)

for k,v in pairs(out) do
    print(k,v)
end


local m = {
2.59807634, 0, 0, 0,
0, 1.73205090, 0, 0,
0, 0, -1.01538432, -1,
-831.384399, -831.384399, 822.634460, 830.019043
}

local v4 = {x = out[1], y = out[2], z = out[3], w = out[4]}
out = mat_mut_vec4(m, v4)

for k,v in pairs(out) do
    print(k,v)
end