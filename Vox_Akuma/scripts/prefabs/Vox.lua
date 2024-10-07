local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Asset("ANIM", "anim/Vox.zip"),
    Asset("ANIM", "anim/KING_BIG_CHEST.zip"),
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
local start_inv = {
    "camellia_cloak",
    "onigiri_pendant",
}

local function AddRecipes()
    -- 领主太刀的配方
    local lord_katana_recipe = Recipe("lord_katana", {Ingredient("twigs", 2), Ingredient("redgem", 1)}, RECIPETABS.WAR, TECH.SCIENCE_TWO)
    lord_katana_recipe.atlas = "images/inventoryimages/lord_katana.xml"

    -- 混天绫的配方（满级解锁后可制作）
    local hun_tian_lin_recipe = Recipe("hun_tian_lin", {Ingredient("silk", 6), Ingredient("goldnugget", 3)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
    hun_tian_lin_recipe.atlas = "images/inventoryimages/hun_tian_lin.xml"
    -- 山茶花羽织的制作配方
    local camellia_cloak_recipe = Recipe("camellia_cloak", {Ingredient("silk", 6), Ingredient("goldnugget", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
    camellia_cloak_recipe.atlas = "images/inventoryimages/camellia_cloak.xml"

end

local function GainExperience(inst, amount)
    inst.experience = inst.experience + amount
    if inst.experience >= 100 * inst.level then
        inst.level = inst.level + 1
        inst.experience = 0
        inst.components.combat.damagemultiplier = 1 + (inst.level * 0.1)
    end
end

local function OnKillSoulCreature(inst, data)
    if data.victim and data.victim:HasTag("soul") then
        local soul = SpawnPrefab("wortox_soul_common")
        soul.Transform:SetPosition(data.victim.Transform:GetWorldPosition())
        
        -- 自动吸收到背包
        if inst.components.inventory then
            inst.components.inventory:GiveItem(soul)
        end
    end
end

local function OnBossKilled(inst, boss)
    if boss.prefab == "spiderqueen" then
        inst:AddTag("spiderfriend")
    elseif boss.prefab == "dragonfly" then
        inst.components.temperature.inherentinsulation = 100
        inst.components.fireproof = true
    elseif boss.prefab == "deerclops" then
        inst.components.temperature.inherentsummerinsulation = 100
    elseif boss.prefab == "moose" then
        inst.components.rainimmunity = true
    elseif boss.prefab == "antlion" then
        inst:AddTag("soulhop")  -- 赋予灵魂跳跃能力
    elseif boss.prefab == "bearger" then
        inst.components.worker:AddMultiplier(ACTIONS.CHOP, 1.5)
        inst.components.worker:AddMultiplier(ACTIONS.MINE, 1.5)
    elseif boss.prefab == "beequeen" then
        inst:AddTag("knockbackimmune")
    elseif boss.prefab == "klaus" then
        inst.components.revivablecorpse:EnableAutoRevive(true)
    elseif boss.prefab == "ancientguardian" then
        -- 生成触手攻击特效
        inst:ListenForEvent("onattackother", function(inst, data)
            if data.target then
                local tentacle = SpawnPrefab("shadowtentacle")
                tentacle.Transform:SetPosition(data.target.Transform:GetWorldPosition())
            end
        end)
    elseif boss.prefab == "toadstool" then
        inst:AddTag("sleepproof")
    elseif boss.prefab == "shadowweaver" then
        inst:AddTag("bonearmor")
    elseif boss.prefab == "malbatross" then
        inst:AddTag("waterwalking")
    elseif boss.prefab == "crabking" then
        inst.components.lifesteal:Enable(true)
    elseif boss.prefab == "celestialchampion" then
        inst:AddTag("enlightened")
    end

    inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME * 5, function()
        -- 清除boss能力
        inst:RemoveTag("spiderfriend")
        inst.components.temperature.inherentinsulation = 0
        inst.components.fireproof = false
        -- 其他能力清除逻辑...
    end)
end

local function NearMonkeys(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local monkeys = TheSim:FindEntities(x, y, z, 20, {"monkey"})
    for _, monkey in ipairs(monkeys) do
        inst.components.sanity:DoDelta(1)
        monkey:RemoveTag("scarytoprey")
    end
end
-- 在Prefab文件末尾添加配方
AddRecipes()

local function OnTryToEat(inst, data)
    -- 定义无法食用的海鲜/鱼类
    local seafood_tags = {"fish", "oceanfish", "fishmeat", "seafood"}
    
    if data.food and data.food:HasTag(seafood_tags) then
        -- 如果食物是海鲜或鱼类，阻止食用
        inst.components.talker:Say("I don't eat seafood!")  -- 提示玩家
        return false  -- 阻止食用
    end

    -- 正常食物处理
    if inst.components.demonhunger and inst.components.demonhunger.current == 0 then
        -- 恶魔饥饿值为 0 时，普通食物只恢复 5% 的饥饿值
        local original_hunger_value = data.food.components.edible.hungervalue or 0
        local reduced_hunger_value = original_hunger_value * 0.05
        inst.components.hunger:DoDelta(reduced_hunger_value)
    else
        -- 正常情况下食用恢复饥饿值
        inst.components.hunger:DoDelta(data.food.components.edible.hungervalue)
    end

    -- 恢复生命值和san值（如适用）
    if data.food.components.edible.healthvalue then
        inst.components.health:DoDelta(data.food.components.edible.healthvalue)
    end

    if data.food.components.edible.sanityvalue then
        inst.components.sanity:DoDelta(data.food.components.edible.sanityvalue)
    end

    return true
end

local function OnEatNightmareFuel(inst, food)
    if food.prefab == "nightmarefuel" then
        -- 食用噩梦燃料时恢复恶魔饥饿、san值和生命值
        inst.components.health:DoDelta(10)
        inst.components.sanity:DoDelta(15)
        inst.components.demonhunger:DoDelta(20)
    elseif food.prefab == "wortox_soul_common" then
        -- 食用灵魂的效果和 Wortox 一致
        inst.components.demonhunger:DoDelta(20)
        inst.components.sanity:DoDelta(-10)
    end
end

local function fn(inst)
    -- 基本属性
    inst:AddComponent("inventory")
    inst.components.health:SetMaxHealth(200)
    inst.components.sanity:SetMax(120)
    inst.components.hunger:SetMax(150)

    -- 恶魔饥饿条
    inst:AddComponent("demonhunger")
    inst.components.demonhunger:SetMax(100)
    inst.components.demonhunger.rate = inst.components.hunger.hungerrate * 0.75
    inst.components.demonhunger:StartDrain()
    inst.rage_mode = false
    inst.level = 1
    inst.experience = 0

    -- 在角色 prefab 中加入该监听事件
    inst:ListenForEvent("killed", OnKillSoulCreature)

    -- 生成并装备山茶花羽织
    local camellia_cloak = SpawnPrefab("camellia_cloak")
    inst.components.inventory:Equip(camellia_cloak)

    -- 生成并给予onigiri挂件
    local onigiri = SpawnPrefab("onigiri_pendant")
    inst.components.inventory:GiveItem(onigiri)

    -- 生成并给予Kindred宠物
    local kindred = SpawnPrefab("kindred_pet")
    inst.components.inventory:GiveItem(kindred)

    -- 满级解锁混天绫
    inst:ListenForEvent("levelup", function(inst, data)
        if data.level == 10 then
            inst.components.builder:UnlockRecipe("mixed_sky_ribbon")
        end
    end)

    -- 监听杀死邪恶生物事件
    inst:ListenForEvent("killed", OnKillEvilCreature)

    -- 监听食物事件，处理正常食用逻辑
    inst:ListenForEvent("oneat", OnTryToEat)

    -- 监听食用噩梦燃料和灵魂的事件
    inst:ListenForEvent("oneat", OnEatNightmareFuel)

    -- Boss击杀
    inst:ListenForEvent("killed", function(inst, data)
        if data.victim and data.victim.prefab then
            GainExperience(inst, 10)
            OnBossKilled(inst, data.victim)
        end
    end)
    -- 猴子感应
    inst:DoPeriodicTask(1, NearMonkeys)
end



return MakePlayerCharacter("Vox", prefabs, assets, start_inv,fn)
