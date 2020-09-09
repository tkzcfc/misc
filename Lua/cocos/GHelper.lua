local GHelper = {}

GHelper.log = function(...)
	print(...)
end

function GHelper.copyTable(tb)
	local tab = { }
	for k, v in pairs(tb or { }) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = GHelper.copyTable(v)
		end
	end
	return tab
end

function GHelper.lerp(x, y, alpha)
	local ret = x + alpha *(y - x)
	return ret
end

function GHelper.loadStudioFile(fileName, target)
	local root = require(fileName).create(function (path, node, funcName)
		if target == nil then
			return
		end
        return function(...) 
            if target[funcName] and type(target[funcName]) == "function" then
                target[funcName](target, ...)
            else
                GHelper.log(string.format("[%s -> %s]: %s方法未实现", path, node:getName(), funcName))
            end
        end
    end)
    return root
end

function GHelper.serialMap2Url(tb)
	if type(tb) == "table" then
		local s = ""
		for key, val in pairs(tb) do
			s = s .. key .. "=" .. val
			s = s .. "&"
		end
		return string.sub(s, 1, #s - 1)
	else
		return tb
	end
end

function GHelper.httpPost(url, data, callback, response_type)
	if not url then
		return
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = response_type or cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:open("POST", url)
	local function onReadyStateChange()
		if xhr.readyState == 4 and(xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			local output = nil
			if response and #response > 0 and xhr.responseType == cc.XMLHTTPREQUEST_RESPONSE_JSON then
				output = json.decode(response, 1)
            else
                output = response
			end
			GHelper.log(string.format("Http Responds: %s", response))
			callback(output, xhr)
		else
			GHelper.log(string.format("xhr.readyState is:%s ,xhr.status is:%s", xhr.readyState, xhr.status))
			callback(nil)
		end
	end
	xhr:registerScriptHandler(onReadyStateChange)
	local post_str = GHelper.serialMap2Url(data)
	GHelper.log("http post data: ", post_str)
	xhr:send(post_str)
end

function GHelper.httpGet(url, callback)
	if not url then
		return
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)

	local function onReadyStateChange()
		if xhr.readyState == 4 and(xhr.status >= 200 and xhr.status < 207) then
			local statusString = "Http Status Code:" .. xhr.statusText
			GHelper.log(statusString)
			callback(xhr.response, xhr)
		else
			GHelper.log("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
			callback(nil)
		end
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

--依据宽度截断字符
-- local str = "更具function appdf.stringEllipsis(szText, sizeE,sizeCN,maxWidth)"
-- local ret = GHelper.stringEllipsis(str, 10, 20, 100)
-- print(ret) -- 更具func...
function GHelper.stringEllipsis(szText, sizeE, sizeCN, maxWidth)
	--当前计算宽度
	local width = 0
	--截断位置
	local lastpos = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	 
	local i = 1
	 
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width +sizeCN <= maxWidth - 3*sizeE then
				width = width +sizeCN
				 i = i + 3
				 lastpos = i+2
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width +sizeE <= maxWidth - 3*sizeE then
				width = width +sizeE
				i = i + 1
				lastpos = i
			else
				bOK = true
				break
			end
		else
			i = i + 1
			lastpos = i
		end
	end
	if lastpos ~= 0 then
		szResult = string.sub(szText, 1, lastpos)
		if(bOK) then
			szResult = szResult.."..."
		end
	end
	return szResult
end

-- 字符分割
function GHelper.split(str, flag)
	local tab = {}
	local flaglen = #flag
	if flag == "." then
		flag = "%."
	end
	while true do
		local n = string.find(str, flag)
		print(n)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+flaglen, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

-- 格式化lua值
function GHelper.format_lua_value(inValue)
    if type(inValue) ~= "table" then
        return tostring(inValue)
    end

    local formatting = "{\n"

    local function format_lua_table (lua_table, indent)
        indent = indent or 0
        
        for k, v in pairs(lua_table) do
            if type(k) == "string" then
                k = string.format("%q", k)
            end
            local szSuffix = ""
            if type(v) == "table" then
                szSuffix = "{"
            end
            local szPrefix = string.rep("    ", indent)
            formatting = formatting .. szPrefix.."["..k.."]".." = "..szSuffix
            if type(v) == "table" then
                formatting = formatting.."\n"
                format_lua_table(v, indent + 1)
                formatting = formatting .. szPrefix.."},\n"
            else
                local szValue = ""
                if type(v) == "string" then
                    szValue = string.format("%q", v)
                else
                    szValue = tostring(v)
                end
                formatting = formatting..szValue..",\n"
            end
        end
    end
    format_lua_table(inValue, 1)
    return formatting.."}"
end

-- 输出lua值
function GHelper.print_lua_value(inValue)
	print(GHelper.format_lua_value(inValue))
end

-- table元素个数
function GHelper.lenOfMap(tb)
	local len = 0
	for k, v in pairs(tb) do
		if v ~= nil then
			len = len + 1
		end
	end
	return len
end

-- example:
--     GHelper.registerTouchEventListener(self, button, "onButtonClick")
--
function GHelper.registerTouchEventListener(this, node, funcName)
	node:addClickEventListener( function(sender)
		local func = this[funcName]
		if func ~= nil then
			func(this, sender)
		end
	end )
end

function GHelper.md5(str)
	local md5 = require("utils.md5")
	return md5.sumhexa(str)
end

function GHelper.getUTF8SubString(input, subLen)
	local len = string.len(input)
	local left = len
	local cnt = 0
	local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
	while left ~= 0 do
		local tmp = string.byte(input, - left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
		if cnt >= subLen then
			return string.sub(input, 1, - left - 1)
		end
	end
	return input
end

function GHelper.getWidthWithNode(aNode)
	local reseult = 0
	if aNode then
		result = aNode:getContentSize().width * math.abs(aNode:getScaleX())
	end
	return result
end

function GHelper.getHeightWithNode(aNode)
	local reseult = 0
	if aNode then
		result = aNode:getContentSize().height * math.abs(aNode:getScaleY())
	end
	return result
end

function GHelper.runWithCoroutine(func)
	local co = coroutine.create(func)
	local result, msg = coroutine.resume(co)
	if not result then
		print(msg)
	end
end

function GHelper.readfile(path)
      local file = io.open(path, "r")
      if file then
        local content = file:read("*a")
        io.close(file)
        return content
      end
      return nil
end

function GHelper.writefile(path, content, mode)
      mode = mode or "wb"
      local file = io.open(path, mode)
      if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
      else
        return false
      end
end

function GHelper.fileExists(path)
    local file = io.open(path, "r")
    if file then
      io.close(file)
      return true
    end
    return false
end

function GHelper.getCurrentDir()
	local path = string.gsub(lfs.currentdir(), "\\", "/")
	return path
end

function GHelper.getFileName(path)
	return string.match(path, "(%w+%.*%w*)$")
end

function GHelper.getExtension(path)
	return string.match(path, "%.(%w+)$") or ""
end

function GHelper.fmtFileName(filename)
	filename = EHelper:replaceString(filename, "\\", "/")
	filename = EHelper:replaceString(filename, GHelper.getCurrentDir(), "")
	if string.sub(filename, 1, 1) == "/" then
		filename = string.sub(filename, 2, -1)
	end
	return filename
end

return GHelper
