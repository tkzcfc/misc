-- @Author : fangcheng
-- @Date   : 2020-11-24 15:58:04
-- @remark : 渲染优化

if _G.RenderOptimize then
	return _G.RenderOptimize
end

-- @brief 将节点截图
-- @param node 目标节点
-- @param size 要截图的size
local function captureNode(node, size)
    local originPos = cc.p(node:getPosition())
    local originAnchorPoint = node:getAnchorPoint()

    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(size.width / 2, size.height / 2)

    local canva = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    canva:begin()
    node:visit()
    canva:endToLua()

    node:setAnchorPoint(originAnchorPoint)
    node:setPosition(originPos)

    local sprite = cc.Sprite:createWithTexture(canva:getSprite():getTexture())
    sprite:setFlippedY(true)
    return sprite
end

-- 任务队列
local taskQue = {}

-- 异步执行
async_run(function()
	repeat
		async_yield()
		if #taskQue > 0 then
			local task = taskQue[1]
			table.remove(taskQue, 1)
	
			local curWidget = task.widget
			repeat
				if tolua.isnull(curWidget) then break end
	
				local parent = curWidget:getParent()
				if parent == nil then break end
	
				if parent.optimize_cache_sp then
					parent.optimize_cache_sp:removeFromParent()
					parent.optimize_cache_sp = nil
				end
	
				curWidget:setVisible(true)
				
				local sprite = captureNode(curWidget, task.size)
				if sprite == nil then break end
				
				curWidget:setVisible(false)
	
				sprite:setPosition(curWidget:getPosition())
				parent:addChild(sprite)
	
				parent.optimize_cache_sp = sprite
	
				if task.call then task.call(sprite) end
			until(true)
		end
	until(false)
end)



local RenderOptimize = {}

-- @brief 添加优化任务
-- 		  优化原理:将节点渲染成一个单独图片,渲染完成之后隐藏该节点,使用图片替换节点显示
-- @param widget 要优化的节点
-- @param size 节点大小(大于等于节点大小即可)
-- @param call 优化完成之后的回调
function RenderOptimize:optimize(widget, size, call)
	if widget == nil then return end

	local parent = widget:getParent()
	if parent and parent.optimize_cache_sp then
		parent.optimize_cache_sp:removeFromParent()
		parent.optimize_cache_sp = nil
	end
	widget:setVisible(true)


	self:cancel(widget)
	table.insert(taskQue, {
		widget = widget,
		size = size,
		call = call
	})
end

-- @param 取消优化
function RenderOptimize:cancel(widget)
	for k,v in pairs(taskQue) do
		if v.widget == widget then
			table.remove(taskQue, k)
			break
		end
	end
end

function RenderOptimize:cancelAll()
	taskQue = {}
end

return RenderOptimize
