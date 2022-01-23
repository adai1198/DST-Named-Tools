local _G      = GLOBAL
local TheNet  = _G.TheNet
local STRINGS = _G.STRINGS
local subfmt  = _G.subfmt

STRINGS.NAMES.NAMEDTOOLS_TOOLNAME_FMT = "{owner_name}'s {prefab_name}"

local prefablist_anycase = {
    axe             = 1.0,
    goldenaxe       = 1.0,
    pickaxe         = 1.0,
    goldenpickaxe   = 1.0,
    shovel          = 1.0,
    goldenshovel    = 1.0,
    farm_hoe        = 1.0,
    golden_farm_hoe = 1.0,
    hammer          = 1.0,
    pitchfork       = 1.0
}

local prefablist_lowuses = {
    nightsword      = 10 / TUNING.NIGHTSWORD_USES,
    glasscutter     = 10 / TUNING.GLASSCUTTER.USES
}

local prefablist_crafted = {
    birdtrap        = 1,
    trap            = 1,
    razor           = 1
}

local function SetNamedOverOwner(inst)
    if inst.components.inventoryitem then
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if owner then
            local owner_name  = owner:GetDisplayName()
            local prefab_name = STRINGS.NAMES[string.upper(inst.prefab)]

            inst.components.named:SetName(subfmt(STRINGS.NAMES.NAMEDTOOLS_TOOLNAME_FMT, { owner_name=owner_name, prefab_name=prefab_name }))
        end
    end
end

local function OnPercentUsedChange(inst, data)
    local shouldChangeName = false

    if prefablist_anycase[inst.prefab] then
        shouldChangeName = true
    end

    if prefablist_lowuses[inst.prefab] and data.percent <= prefablist_lowuses[inst.prefab] then
        shouldChangeName = true
    end

    if shouldChangeName then
        SetNamedOverOwner(inst)
    end
end

if TheNet:GetIsServer() or TheNet:IsDedicated() then
    for prefab,_ in pairs(prefablist_anycase) do
        -- When it's loaded in game, e.g. log-in or crafted.
        AddPrefabPostInit(prefab, function(inst)
            -- if not _G.TheWorld.ismastersim then return inst end
            if not inst.components.named then inst:AddComponent("named") end
            inst:DoTaskInTime(0.1, SetNamedOverOwner)
            inst:ListenForEvent("percentusedchange", OnPercentUsedChange)
        end)
    end

    for prefab,_ in pairs(prefablist_lowuses) do
        AddPrefabPostInit(prefab, function(inst)
            -- if not _G.TheWorld.ismastersim then return inst end
            if not inst.components.named then inst:AddComponent("named") end
            inst:ListenForEvent("percentusedchange", OnPercentUsedChange)
        end)
    end

    for prefab,_ in pairs(prefablist_crafted) do
        -- When it's loaded in game, e.g. log-in or crafted.
        AddPrefabPostInit(prefab, function(inst)
            -- if not _G.TheWorld.ismastersim then return inst end
            if not inst.components.named then inst:AddComponent("named") end
            inst:DoTaskInTime(0.1, SetNamedOverOwner)
        end)
    end
end

-- TODO: Add support for Lucy and the reverted axes.