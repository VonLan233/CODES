local Repairable = Class(function(self, inst)
    self.inst = inst
    self.required_items = {}  -- 需要修复的物品列表
    self.onrepairedfn = nil   -- 修复完成后的回调函数
end)

-- 设置修复所需的物品
function Repairable:SetRequiredItems(items)
    self.required_items = items
end

-- 检查玩家是否有足够的物品来修复
function Repairable:CanRepair(player)
    if player and player.components.inventory then
        for _, item in ipairs(self.required_items) do
            if not player.components.inventory:Has(item.name, item.amount) then
                return false
            end
        end
        return true
    end
    return false
end

-- 执行修复逻辑
function Repairable:DoRepair(player)
    if self:CanRepair(player) then
        for _, item in ipairs(self.required_items) do
            player.components.inventory:ConsumeByName(item.name, item.amount)
        end
        if self.onrepairedfn then
            self.onrepairedfn(self.inst)
        end
    end
end

-- 设置修复完成后的回调函数
function Repairable:SetOnRepairedFn(fn)
    self.onrepairedfn = fn
end

return Repairable
