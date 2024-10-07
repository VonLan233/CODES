local assets = {
    Asset("ANIM", "anim/camellia_cloak.zip"),  -- 羽织的动画文件
    Asset("ATLAS", "images/inventoryimages/camellia_cloak.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 动画设置
    inst.AnimState:SetBank("camellia_cloak")
    inst.AnimState:SetBuild("camellia_cloak")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("armor")
    inst:AddTag("clothing")

    -- 只在服务器端工作
    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加护甲组件
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(100, 0.4)  -- 40% 的护甲值，没有耐久

    -- 添加可装备组件
    inst:AddComponent("equippable")
    inst.components.equippable.walkspeedmult = 1.05  -- 5% 的移速加成

    -- 添加物品组件
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/camellia_cloak.xml"

    -- 装备时的视觉效果
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_body", "camellia_cloak", "swap_body")
    end)

    -- 解除装备时移除视觉效果
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:ClearOverrideSymbol("swap_body")
    end)

    return inst
end

return Prefab("camellia_cloak", fn, assets)
