local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Assets("ANIM", "anim/Vox.zip"),
    Assets("ANIM", "anim/KING_BIG_CHEST.zip"),
    Asset("SCRIPT", "scripts/prefabs/wortox_soul_common.lua"),
    Asset("ANIM", "anim/player_idles_wortox.zip"),
    Asset("ANIM", "anim/wortox_portal.zip"),
}
local prefabs={
    "wortox_soul_spawn",
    "wortox_portal_jumpin_fx",
    "wortox_portal_jumpout_fx",
    "wortox_eat_soul_fx",
}
local start_inv={
    "Haori",
    "Onigiri",
}

init.components.health=200
init.components.hunger=150
init.components.sanity=120



local MakePlayerCharacter = require("prefabs/player_common")
local wortox_soul_common = require("prefabs/wortox_soul_common")

inst:AddComponent("dvlhun")



inst:AddComponent("souleater")

local function OnEatSoul(inst, soul)
    inst.components.dvlhun:DoDelta(20)
    inst.components.hunger:DoDelta(Val)
    inst.components.sanity:DoDelta(-5)
    if inst._checksoulstask ~= nil then
        inst._checksoulstask:Cancel()
    end
    inst._checksoulstask = inst:DoTaskInTime(.2, CheckSoulsRemovedAfterAnim, "eat")
end

inst.components.souleater:SetOnEatSoulFn(OnEatSoul)
    
local function state_KBC(inst)
    inst.AnimState:SetBuild("KING_BIG_CHEST")
end

local function Henshin(inst)
    if inst.dvlhun == 150 then
        inst.AnimState:SetBuild("KING_BIG_CHEST")
    end
end

local function CheckSoulsRemoved(inst)
    inst._checksoulstask = nil
    local count = 0
    for i, v in ipairs(inst.components.inventory:FindItems(IsSoul)) do
        count = count + GetStackSize(v)
        if count >= TUNING.WORTOX_MAX_SOULS * TUNING.WORTOX_WISECRACKER_TOOFEW then
            return
        end
    end
    inst:PushEvent(count > 0 and "soultoofew" or "soulempty") -- These events are not used elsewhere outside of wisecracker.
end

local function CheckSoulsRemovedAfterAnim(inst, anim)
    if inst.AnimState:IsCurrentAnimation(anim) then
        inst._checksoulstask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + 2 * FRAMES, CheckSoulsRemoved)
    else
        CheckSoulsRemoved(inst)
    end
end