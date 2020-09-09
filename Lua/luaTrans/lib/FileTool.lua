-- @Author : fangcheng
-- @Date   : 2020-07-22 18:31:16
-- @remark : 文件相关操作工具类

local lfs = require("lfs")

local FileTool = {}

local log = print

function FileTool.dirChildren(_rootPath, recursive)
	local list = {}

	local function _dirChildren(rootPath)
		for entry in lfs.dir(rootPath) do
    	    if entry~='.' and entry~='..' then
    	        local path = rootPath.."\\"..entry
    	        local attr = lfs.attributes(path)
    	        assert(type(attr)=="table") --如果获取不到属性表则报错
	
    	        attr.path = path
    	        if(attr.mode == "directory") then
    	            -- log("Dir:",path)
    	            list[#list + 1] = attr
    	            if recursive then
    	            	_dirChildren(path)
    	            end
    	        elseif attr.mode=="file" then
    	            -- log("File:",path)
    	            list[#list + 1] = attr
    	        end
    	    end
    	end
	end

	_dirChildren(_rootPath)
    
    return list
end

function FileTool.getAllFiles(_rootPath)
	local allFilePath = {}

	local function _getAllFiles(rootPath)
    	for entry in lfs.dir(rootPath) do
    	    if entry~='.' and entry~='..' then
    	        local path = rootPath.."\\"..entry
    	        local attr = lfs.attributes(path)
    	        assert(type(attr)=="table") --如果获取不到属性表则报错
    	        if(attr.mode == "directory") then
    	            _getAllFiles(path) --自调用遍历子目录
    	        elseif attr.mode=="file" then
    	            attr.path = path
    	            allFilePath[#allFilePath + 1] = attr
    	        end
    	    end
    	end
	end

	_getAllFiles(_rootPath)

	return allFilePath
end

function FileTool.dirCheck(rootPath)
	return lfs.dir(rootPath)() ~= nil
end

function FileTool.getDirSize(rootPath)
	local allFileList = FileTool.getAllFiles(rootPath)
	local totalSize = 0
	for k,v in pairs(allFileList) do
		totalSize = totalSize + v.size
	end
	return totalSize
end

function FileTool.createDir(path)
	return lfs.mkdir(path)
end

function FileTool.removeDir(path)
	return lfs.rmdir(path)
end

function FileTool.renameDir(oldDir, newDir)
	return os.rename(oldDir, newDir)
end

function FileTool.renameFile(oldName, newName)
	return os.rename(oldName, newName)
end

-- srcName 源文件
-- tarName 目标文件
function FileTool.copyFile(srcName, tarName)
	if srcName == tarName then
		return false, 'target path is consistent with source path'
	end
	if not FileTool.fileCheck(srcName) then
		return false, 'file does not exist'
	end
	local err = ''
	local oldfile = io.open(srcName, "rb")
	local newfile = io.open(tarName, 'wb')
	if oldfile and newfile then
		local data = oldfile:read("*a")
		if newfile:write(data) then
			oldfile:close()
			newfile:close()
			return true
		else
			err = 'fail to write to file'
		end
	else
		err = 'fail to open file'
	end
	if oldfile then oldfile:close()	end
	if newfile then newfile:close()	end
	return false, err
end

-- srcName 源文件夹
-- tarName 目标文件夹
function FileTool.copyDir(srcName, tarName)
	if srcName == tarName then
		return false, 'target path is consistent with source path'
	end
	if not FileTool.dirCheck(srcName) then
		return false, 'source folder does not exist'
	end
	if FileTool.dirCheck(tarName) then
		return false, 'destination folder already exists'
	end
	if not FileTool.createDir(tarName) then
		return false, string.format('Failed to create folder \'%s\'', tostring(tarName))
	end

	local fileList = FileTool.dirChildren(srcName, true)
	for k,v in pairs(fileList) do
		local oldPath = v.path
		local newPath = string.gsub(v.path, '^'..srcName, tarName)
		if v.mode == 'directory' then
			if (not FileTool.dirCheck(newPath)) and (not FileTool.createDir(newPath)) then
				return false, string.format('Failed to create folder \'%s\'', tostring(newPath))
			end
		elseif v.mode == 'file' then
			if not FileTool.copyFile(oldPath, newPath) then
				return false, string.format("Failed to copy file \'%s\'", tostring(newPath))
			end
		end
	end
	return true
end

function FileTool.removeFile(path)
	return os.remove(path)
end

function FileTool.fileCheck(path)
	local file = io.open(path, "rb")
	if file then
		file:close()
		return true
	end
	return false
end

return FileTool