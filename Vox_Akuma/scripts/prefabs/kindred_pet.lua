local assets = {
    Asset("ANIM", "anim/kindred_pet.zip"),  -- Kindred宠物动画文件
    Asset("ATLAS", "images/inventoryimages/kindred_pet.xml"),
}

local function RandomKingredAction(inst)
    local chance = math.random()
    if chance < 0.5 then
        -- 50% 概率增加 Vox 的 san 值
        ThePlayer.components.sanity:DoDelta(5)
    else
        -- 50% 概率减少 Vox 的 san 值
        ThePlayer.components.sanity:DoDelta(-5)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 动画设置
    inst.AnimState:SetBank("kindred_pet")
    inst.AnimState:SetBuild("kindred_pet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("pet")
    inst:AddTag("companion")

    -- 设置服务器端物品属性
    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加san值恢复功能
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_LARGE -- 快速恢复san值

    -- 交互功能
    -- 定期触发 Kingred 的随机动作
    inst:DoPeriodicTask(30, RandomKingredAction)
    inst:AddComponent("inspectable")
    inst:AddComponent("talker")
    inst:AddComponent("playeractionpicker")

    inst.components.playeractionpicker:SetActionOverride("pet", function()
        return "抚摸", "飞吻"
    end)

    return inst
end

return Prefab("kindred_pet", fn, assets)
