local assets = {
    Asset("ANIM", "anim/kindred_spirit.zip"),  -- 幻影动画文件
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("kindred_spirit")
    inst.AnimState:SetBuild("kindred_spirit")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("ghost")
    inst:AddTag("kindred_spirit")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")  -- 幻影可以移动
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)  -- 只有 1 点生命值，事件结束时消失

    return inst
end

return Prefab("kindred_spirit", fn, assets)
