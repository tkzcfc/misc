




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



local str = [[[Log]   Publish file "./test/l1.asset" succeeded
[Log]   Publish file "./test/w1.asset" succeeded
[Log]   Publish file "./test/test1/l1.asset" succeeded
[Log]   Publish file "./test/test1/w1.asset" succeeded
666
7777
[Warning]   Copy file "dpsglogo.png" succeeded
5555555555555
[Log]   Copy file "dpsglogo_arrow1.png" succeeded
[Log]   Copy file "dpsglogo_arrow2.png" succeeded
[Error]   Copy file "dpsglogo_target.png" succeeded
44444444444444444
[Log]   Copy file "Loading.png" succeeded
[Log]   Copy file "test.edproj" succeeded
xxxxxxxxxxxxxxxxxxxxxxx
[Log]   Copy file "test1/Loading.png" succeeded
[Log]   Copy file "test1/test.edproj" succeeded
[Log]   publish finished
]]

local fun = string.gmatch(str, "(.-)\n")

local lines = {}

while true do
    local line = fun()
    if line then
        lines[#lines + 1] = line
    else
        break
    end
end

local logTagI = "[Log]"
local logTagW = "[Warning]"
local logTagE = "[Error]"

local lineInfo = {}
for k, v in ipairs(lines) do
    local t = {}
    
    if string.sub(v, 1, #logTagI) == logTagI then
        t.level = 0
        t.content = string.sub(v, #logTagI + 1)
    elseif string.sub(v, 1, #logTagW) == logTagW then
        t.level = 1
        t.content = string.sub(v, #logTagW + 1)
    elseif string.sub(v, 1, #logTagE) == logTagE then
        t.level = 2
        t.content = string.sub(v, #logTagE + 1)
    else
        if #lineInfo > 0 then
            t.level = lineInfo[#lineInfo].level
        else
            t.level = 0
        end
        t.content = v
    end

    lineInfo[#lineInfo + 1] = t
end

for k,v in pairs(lineInfo) do
    local level = v.level
    if level == 0 then
        print(logTagI, v.content)
    elseif level == 1 then
        print(logTagW, v.content)
    elseif level == 2 then
        print(logTagE, v.content)
    end
end


--[[
1 0 0 0
0 1 0 0
0  0 1 0
320 80 0 1
]]

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