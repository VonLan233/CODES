GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end}) 

PrefabFiles={
    "Vox",
    "Jiro",
    "Onigiri",
    "Tokugawa",
    "Haori",
    "Katana",
    "Kindred",
}

Assets={
    Asset( "IMAGE", "images/saveslot_portraits/vox.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/vox.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/vox.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/vox.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/vox_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/vox_silho.xml" ),

    Asset( "IMAGE", "bigportraits/vox.tex" ),
    Asset( "ATLAS", "bigportraits/vox.xml" ),
	
	Asset( "IMAGE", "images/map_icons/vox.tex" ),
	Asset( "ATLAS", "images/map_icons/vox.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_vox.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_vox.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_vox.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_vox.xml" ),

	Asset( "IMAGE", "images/avatars/self_inspect_vox.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_vox.xml" ),

---------------------------------------------------------------------------------

    Asset("ANIM","anim/Vox.zip"),


}

AddMinimapAtlas("images/map_icons/vox.xml")
AddMinimapAtlas("images/minimapicons/vox.xml")

local Vox_atlas={

    items = {
        "Voxsoul.tex",
        "Katana.tex",
        "Haori.tex",
        "Kindred.tex",
        "Onigiri.tex",
    },

}

for img, v in pairs(Vox_atlas) do
    for _, tex in pairs(v) do
        RegisterInventoryItemAtlas("images/inventoryimages/"..img..".xml", tex)
    end
end

RegisterInventoryItemAtlas("images/inventoryimages/oni_cl_qp.xml", "oni_cl_qp.tex")
RegisterInventoryItemAtlas("images/inventoryimages/oni_cl_qp_cb.xml", "oni_cl_qp_cb.tex")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Vector3 = GLOBAL.Vector3
local GROUND = GLOBAL.GROUND
local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
--ACTIONS.GIVE.priority = 2  --设置优先级
--ACTIONS.ADDFUEL.priority = 4
--ACTIONS.COOK.priority = 3
--ACTIONS.USEITEM.priority = 2
GLOBAL.vox_modinfo = modinfo
GLOBAL.vox_modname = modname

modimport("libs/Vox_tuning.lua")
modimport("libs/Vox_names.lua")
modimport("libs/Vox_tuningitem.lua")
modimport("libs/Vox_keyactions.lua")
modimport("libs/Vox_storeitem.lua")
modimport("libs/Vox_widgets.lua")
modimport("libs/Vox_addxxapi.lua")
modimport("libs/Vox_Recipe.lua")
modimport("data/actions/Vox_actions")
modimport("libs/strings_Kindred.lua")
modimport("libs/Vox_console.lua")
modimport("libs/Vox_inventoryimages.lua")
AddMinimap()

AddModCharacter("Vox","MALE")

-------------------------------------------------------------

AddReplicableComponent("vox_levelsys")
AddReplicableComponent("oni_command")

local ONI_FOLLOW = GLOBAL.Action({ priority=99, instant=true, ghost_valid=true})

ONI_FOLLOW.id = "ONI_FOLLOW"
ONI_FOLLOW.str = "点击开始跟随"
ONI_FOLLOW.strfn = function(act)
	if act.target ~= nil and act.target.replica.oni_command ~= nil then
		if act.target.replica.oni_command:IsCurrentlyStaying() then
			return "FOLLOW" 
		end
	end
	return act.target ~= nil and "STOPFOLLOW"
end

ONI_FOLLOW.fn = function(act)
    local targ = act.target
    local doer = act.doer
    if targ and targ.components.oni_command then
        if targ.components.oni_command:IsFollowing() then
            targ.components.oni_command:StopFollowing(false, doer)
        else
            targ.components.oni_command:Follow(truedoer)
        end
        return true
    end
end
AddAction(ONI_FOLLOW)

AddComponentAction("SCENE", "ONI_command",function(inst, doer, actions, right)
    if inst["所有者net"] then
        local owner inst["所有者net"]:value()
        if right and doer == owner then
            table.insert(actions, GLOLBAL.ACTIONS.ONI_FOLLOW)
        end
    end
end)

STRINGS.ACTIONS.ONI_FOLLOW = {
    FOLLOW = vox_loc("右键开始跟随", "Right click to follow"),
    STOP_FOLLOWING = vox_loc("右键停止跟随", "Right click to stop following"),
}
GLOBAL.STRINGS.ONIGIRI_TALK_PANICFIRE = { "WOWO!", "I'M BURNING!", "I'M BURNING!" }
GLOBAL.STRINGS.ONIGIRI_TALK_FIGHT = {""}

local ONI_CB = GLOBAL.Action({priority = 99})
ONI_CB.id = "ONI_CB"
ONI_CB.str = hl_loc("收回饭团哥", 'Call back Onigiri')
ONI_CB.fn = function(act)
	local target = act.target	
	local invobject = act.invobject
	local doer = act.doer
	if target ~= nil then
		local targetpos = target:GetPosition()
		local package = GLOBAL.SpawnPrefab("oni_cl_qp_Cb_build")
		if package and package.components.oni_qp_cb then
			package.components.oni_qp_db:Pack(target)
			package.Transform:SetPosition( targetpos:Get() )
			invobject:Remove()
			if doer and doer.SoundEmitter then
				doer.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
			end
		end
	end
	return true
end
AddAction(ONI_CB) 

AddComponentAction("USEITEM", "z_vox_oni_qp" , function(inst, doer, target, actions) 
	if target:HasTag("Onigiri") and target.prefab == "Onigiri" then
		if target['所有者net'] and target['所有者net']:value() == doer then
			table.insert(actions, GLOBAL.ACTIONS.ONI_CB)
		end
    end
end)
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.ONI_CB, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.ONI_CB, "dolongaction"))

-------------------------------------------------------------
--恶魔饥饿值
-- 添加一个自定义饥饿组件
AddComponentPostInit("DevilHunger", function(self)
    self.dvlhun = 100 -- 初始自定义饥饿值

    -- 定义恢复自定义饥饿值的函数
    function self:EatSoul(amount)
        self.dvlhun = math.min(self.dvlhun + amount, 100)
        self.inst:PushEvent("dvlhundelta", {new = self.dvlhun})
    end
end)

-- 修改灵魂和恶魔燃料的食用效果
AddPrefabPostInit("nightmarefuel", function(inst)
    if inst.components.edible then
        inst.components.edible.foodtype = "CUSTOM"
        inst.components.edible.healthvalue = 0
        inst.components.edible.hungervalue = 0 -- 不影响正常饥饿值
        inst.components.edible.sanityvalue = 0 -- 例如减少10理智值
    end
end)

AddPrefabPostInit("ghostlyelixir_slowregen", function(inst) -- 假设灵魂对应的Prefab是这个
    if inst.components.edible then
        inst.components.edible.foodtype = "CUSTOM"
        inst.components.edible.healthvalue = 0
        inst.components.edible.hungervalue = 0 -- 不影响正常饥饿值
        inst.components.edible.sanityvalue = 0
    end
end)

-- 当玩家食用特定物品时恢复自定义饥饿值
AddComponentPostInit("eater", function(self)
    local oldEat = self.Eat
    self.Eat = function(self, food)
        if food and food.components.edible and food.components.edible.foodtype == "CUSTOM" then
            self.inst.components.hunger:EatSoul(20) -- 假设每次恢复20自定义饥饿值
        end
        return oldEat(self, food)
    end
end)
