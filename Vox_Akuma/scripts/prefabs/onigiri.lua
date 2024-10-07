local assets = {
    Asset("ANIM", "anim/onigiri_pendant.zip"),  -- onigiri挂件动画文件
    Asset("ATLAS", "images/inventoryimages/onigiri_pendant.xml"),
}

local function OnHealthLow(inst)
    if inst.components.health:GetPercent() <= 0.3 then
        -- 放置Onigiri，进入暴走模式
        inst.components.combat:SetAreaDamage(51) -- 造成AOE伤害
        inst:AddTag("monster") -- 吸引怪物仇恨
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 动画设置
    inst.AnimState:SetBank("onigiri_pendant")
    inst.AnimState:SetBuild("onigiri_pendant")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("onigiri")

    -- 设置服务器端物品属性
    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加战斗组件，检测角色血量
    inst:AddComponent("combat")
    inst:ListenForEvent("healthdelta", OnHealthLow)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/onigiri_pendant.xml"

    return inst
end

return Prefab("onigiri_pendant", fn, assets)
