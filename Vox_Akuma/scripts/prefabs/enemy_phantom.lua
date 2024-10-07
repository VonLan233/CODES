local assets = {
    Asset("ANIM", "anim/enemy_phantom.zip"),  -- 敌人投影动画文件
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("enemy_phantom")
    inst.AnimState:SetBuild("enemy_phantom")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("phantom")
    inst:AddTag("ghost")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(50)  -- 投影的生命值

    return inst
end

return Prefab("enemy_phantom", fn, assets)
