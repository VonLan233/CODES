local DevilHunger = Class(function(self,inst)
    self.inst=inst
    self.dvlhun=100
    self.maxdvkhun=150
    self.inst:AddTag("dvlhun")
end,
nil,
nil)

function DevilHunger:DoDelta(amount)
    self.dvlhun = self.dvlhun + amount
end

function DevilHunger:OnSave()
    return { dvlhun = self.dvlhun }
end

-- 打开游戏前加载之前储存的熟练度
function DevilHunger:OnLoad(data)
    if data.dvlhun ~= nil then
        self.dvlhun = data.dvlhun
    end
end

return DevilHunger