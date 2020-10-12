-- @Author : fangcheng
-- @Date   : 2020-10-10 11:16:51
-- @remark : 

local RUN_ORIGIN_SCRIPT = false

local t1 = os.clock()
local cfg

if RUN_ORIGIN_SCRIPT then
-- 44.873029708862
	cfg = require("app.WDConfig.WDConfig")
else
-- 20.461867332458 true false
-- 21.317422866821 true true
-- 30.415246963501 fasle true
	cfg = require("app.WDConfig_new.WDConfig")
end

-- cfg = nil
-- for k,v in pairs(package.loaded) do
-- 	package.loaded[k] = nil
-- end

collectgarbage("collect")
collectgarbage("collect")
collectgarbage("collect")
collectgarbage("collect")
print(string.format("%.02fMB, time:%.03f", collectgarbage("count") / 1024, os.clock() - t1))
-- print(cfg.Carbon.getItem(112001, "NameLang"))


