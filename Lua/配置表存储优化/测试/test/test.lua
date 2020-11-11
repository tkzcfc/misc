-- @Author : fangcheng
-- @Date   : 2020-10-10 11:16:51
-- @remark : 

local RUN_ORIGIN_SCRIPT = true

if arg[1] then
	RUN_ORIGIN_SCRIPT = false
end

local t1 = os.clock()
local cfg

local script = "app1.output.WDConfig"
if RUN_ORIGIN_SCRIPT then
	script = "app.WDConfig.WDConfig"
end
cfg = require(script)
print(string.format("\n\nrequire \"%s\"\n\n", script))
print(string.format("%.02fMB, load config time:%.03f", collectgarbage("count") / 1024, os.clock() - t1))
t1 = os.clock()



collectgarbage("collect")
collectgarbage("collect")
collectgarbage("collect")
collectgarbage("collect")
print(string.format("%.02fMB, collectgarbage time:%.03f", collectgarbage("count") / 1024, os.clock() - t1))
t1 = os.clock()




for J = 1, 1000 do
	for i = 124385, 134308 do
		cfg.Lang.getItem(i, "cn")
	end
end
print(string.format("%.02fMB, read config time:%.03f", collectgarbage("count") / 1024, os.clock() - t1))
t1 = os.clock()

