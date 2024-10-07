local DemonHunger = Class(function(self, inst)
    self.inst = inst
    self.current = 0  -- 当前恶魔饥饿值
    self.max = 100    -- 恶魔饥饿的最大值
    self.rate = 1     -- 每秒减少的恶魔饥饿值
    self.task = nil
end)

-- 增加恶魔饥饿值
function DemonHunger:DoDelta(amount)
    self.current = math.clamp(self.current + amount, 0, self.max)
end

-- 设置最大恶魔饥饿值
function DemonHunger:SetMax(max_value)
    self.max = max_value
    self.current = math.clamp(self.current, 0, self.max)
end

-- 启动恶魔饥饿值的消耗
function DemonHunger:StartDrain()
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(1, function()
            self:DoDelta(-self.rate)
        end)
    end
end

-- 停止恶魔饥饿值的消耗
function DemonHunger:StopDrain()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

return DemonHunger
