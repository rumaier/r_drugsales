Core = exports.r_bridge:returnCoreObject()

local framework = Core.Framework.Current
local onPlayerLoaded = framework == 'es_extended' and 'esx:playerLoaded' or 'QBCore:Client:OnPlayerLoaded'

local function initialize()
    InitializeZones()
end

RegisterNetEvent(onPlayerLoaded, initialize)

function NormalizeTargetData(data)
    if type(data) ~= 'table' then
        local entity = data
        return {
            entity = entity,
            coords = GetEntityCoords(entity)
        }
    else
        return data
    end
end

RegisterNUICallback('setNuiFocus', function(focus, cb)
    cb(SetNuiFocus(focus, focus))
end)

RegisterNUICallback('fetchLocales', function(_, cb)
    cb(Language[Cfg.Language])
end)

RegisterNUICallback('fetchConfig', function(_, cb)
    Cfg.IconPath = Core.Inventory.IconPath
    cb(Cfg)
end)
