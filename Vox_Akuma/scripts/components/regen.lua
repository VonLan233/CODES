local Regen = Class(function(self, inst)
    self.inst = inst
    self.health_rate = 0      -- 每秒恢复的生命值
    self.sanity_rate = 0      -- 每秒恢复的 san 值
    self.hunger_rate = 0      -- 每秒恢复的饥饿值
    self.task = nil
end)

-- 设置恢复速度
function Regen:SetRates(health, sanity, hunger)
    self.health_rate = health
    self.sanity_rate = sanity
    self.hunger_rate = hunger
end

-- 启动恢复
function Regen:Start(duration)
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(1, function()
            if self.health_rate > 0 then
                self.inst.components.health:DoDelta(self.health_rate)
            end
            if self.sanity_rate > 0 then
                self.inst.components.sanity:DoDelta(self.sanity_rate)
            end
            if self.hunger_rate > 0 then
                self.inst.components.hunger:DoDelta(self.hunger_rate)
            end
        end)
        self.inst:DoTaskInTime(duration, function() self:Stop() end)
    end
end

-- 停止恢复
function Regen:Stop()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

return Regen
