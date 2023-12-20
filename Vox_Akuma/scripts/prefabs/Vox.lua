local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Assets("ANIM", "anim/Vox.zip"),
--     Assets("ANIM", "anim/KING_BIG_CHEST.zip"),
}
local prefabs={
    "Voxsoul",
}
local start_inv={
    "Haori",
    "Onigiri",
}

-- local function HenShin()

-- local DevilHunger = Class(function(self, inst)
--     self.inst = inst
--     self.inst.dvlhunger = 100
--     self.inst.dvlhungermax = 200
--     self.inst.dvlhungermin = 0
--     self.inst:AddTag("devilhunger")
-- end,
-- nil,
-- nil)

-- function DevilHunger:ForEat()
    
-- end

-- return DevilHunger