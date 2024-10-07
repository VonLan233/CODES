local assets = {
    Asset("ANIM", "anim/lord_katana.zip"),  -- 你的太刀动画文件
    Asset("ATLAS", "images/inventoryimages/lord_katana.xml"),
}

local function OnUpgrade(inst, level)
    local damage = 59 + (level - 1) * 2.1 -- 每次升级增加2.1伤害，最高82
    inst.components.weapon:SetDamage(damage)
end

local function ToggleFireEnchantment(inst)
    if inst.fire_enchantment then
        inst.components.weapon.attackwear = 1 -- 移除火附魔
        inst.fire_enchantment = false
    else
        inst.components.weapon.attackwear = 0 -- 添加火附魔
        inst.components.weapon:SetOnAttack(function(inst, attacker, target)
            if target and target.components.burnable then
                target.components.burnable:Ignite() -- 对目标进行燃烧攻击
            end
        end)
        inst.fire_enchantment = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 动画设置
    inst.AnimState:SetBank("lord_katana")
    inst.AnimState:SetBuild("lord_katana")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")

    -- 设置服务器端物品属性
    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加武器组件
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(59)
    inst.components.weapon.attackwear = 1 -- 无耐久

    -- 添加可升级功能
    inst:ListenForEvent("onupgrade", OnUpgrade)

    -- 火附魔切换
    inst:AddComponent("inventoryitem")
    inst:ListenForEvent("toggle_fire", ToggleFireEnchantment)

    return inst
end

return Prefab("lord_katana", fn, assets)
