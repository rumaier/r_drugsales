Core = exports.r_bridge:returnCoreObject()

local framework = Core.Framework.Current

local onPlayerLoaded = framework == 'es_extended' and 'esx:playerLoaded' or 'QBCore:Client:OnPlayerLoaded'
RegisterNetEvent(onPlayerLoaded, function()
  InitializeStreetZones()
end)

RegisterNUICallback('setGameFocus', function(_, cb) cb(SetNuiFocus(false, false)) end)

RegisterNUICallback('getLocales', function(_, cb) cb(Language[Cfg.Server.Language]) end)

RegisterNUICallback('getConfig', function(_, cb)
  Cfg.Server.InventoryPath = Core.Inventory.IconPath
  cb(Cfg)
end)
