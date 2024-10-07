local assets = {
    Asset("ANIM", "anim/throne_ruins.zip"),  -- 王座废墟的动画文件
    Asset("ATLAS", "images/inventoryimages/throne_ruins.xml"),
}

-- 修复王座时增加玩家生命值上限
local function OnRepaired(inst)
    local player = ThePlayer  -- 获取修复王座的玩家
    if player and player.components.health then
        player.components.health:SetMaxHealth(player.components.health.maxhealth + 50)  -- 增加 50 生命值上限
    end

    -- 切换到修复后的动画
    inst.AnimState:PlayAnimation("repaired")
    inst:AddTag("throne_repaired")  -- 标记为修复完成，防止重复修复
end

-- 初始化王座废墟状态
local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("ruins")
end

-- 王座效果：坐下后持续恢复生命、san值和饥饿
local function OnSitOnThrone(inst, player)
    if inst:HasTag("throne_repaired") then
        -- 设置恢复效果为帐篷的 1.5 倍
        player.components.health:StartRegen(3, 10)  -- 每 10 秒恢复 3 点生命
        player.components.sanity:StartRegen(2.25, 10)  -- 每 10 秒恢复 2.25 点 san 值
        player.components.hunger:DoDelta(2.25)  -- 每 10 秒恢复 2.25 点饥饿值
    end
end

-- 检查玩家是否拥有修复所需材料
local repair_items = {
    { name = "moonglass", amount = 15 },
    { name = "thulecite", amount = 15 },
    { name = "marble", amount = 10 },
    { name = "nightmarefuel", amount = 25 }
}

local function CanRepair(inst)
    local player = ThePlayer
    if player and player.components.inventory then
        for _, item in ipairs(repair_items) do
            if not player.components.inventory:Has(item.name, item.amount) then
                return false
            end
        end
        return true
    end
    return false
end

local function OnPlayerRepair(inst)
    local player = ThePlayer
    if CanRepair(inst) then
        -- 消耗修复材料
        for _, item in ipairs(repair_items) do
            player.components.inventory:ConsumeByName(item.name, item.amount)
        end
        -- 进行修复
        OnRepaired(inst)
    end
end
-- 保存当前的时间阶段以便事件结束后恢复
local previous_phase

local function TriggerMemoryEvent(inst)
    local chance = math.random()
    if chance < 0.2 then  -- 20% 概率触发过去的记忆事件
        -- 强制夜晚
        previous_phase = TheWorld.state.phase  -- 保存当前时间阶段
        TheWorld:PushEvent("ms_setphase", "night")  -- 强制设置为夜晚

        -- 生成 Kindred 幻影
        for i = 1, 3 do
            local kindred_spirit = SpawnPrefab("kindred_spirit")
            kindred_spirit.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end

        -- 生成敌人投影
        for i = 1, 2 do
            local enemy_phantom = SpawnPrefab("enemy_phantom")
            enemy_phantom.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
        -- 添加虚灵和敌人战斗特效
        inst:DoTaskInTime(5, function()
            ThePlayer.components.talker:Say("A fierce battle unfolds between the spirits...")
        end)
        -- 设置事件结束，恢复原本的时间阶段（天亮时）
        inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME, function()
            if previous_phase then
                TheWorld:PushEvent("ms_setphase", previous_phase)  -- 恢复原来的时间阶段
            end
        end)
    end
end


-- 主要 Prefab 函数
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 设置动画
    inst.AnimState:SetBank("throne_ruins")
    inst.AnimState:SetBuild("throne_ruins")
    inst.AnimState:PlayAnimation("idle")

    -- 设置标签
    inst:AddTag("structure")
    inst:AddTag("ruins")

    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加修复组件
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetOnFinishCallback(OnPlayerRepair)
    inst.components.workable:SetWorkLeft(1)

    -- 添加使用王座的功能
    inst:AddComponent("usableitem")
    inst.components.usableitem:SetOnUseFn(OnSitOnThrone)

    -- 定期检查是否触发过去的记忆事件
    inst:DoPeriodicTask(30, TriggerMemoryEvent)  -- 每 30 秒检查一次是否触发事件

    -- 监听建造完成事件
    inst:ListenForEvent("onbuilt", OnBuilt)

    return inst
end

return Prefab("throne_ruins", fn, assets)
