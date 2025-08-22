Core = exports.r_bridge:returnCoreObject()

local framework = Core.Info.Framework

local onPlayerLoaded = framework == 'ESX' and 'esx:playerLoaded' or 'QBCore:Client:OnPlayerLoaded'
RegisterNetEvent(onPlayerLoaded, function()
  -- initialize shit when the player loads
end)

function _debug(...)
  if not Cfg.Debug then return end
  print('[^6DEBUG^0] -', ...)
end

RegisterNUICallback('setGameFocus', function(_, cb) cb(SetNuiFocus(false, false)) end)

RegisterNUICallback('getLocales', function(_, cb) cb(Language[Cfg.Server.Language]) end)

RegisterNUICallback('getConfig', function(_, cb)
  Cfg.Server.InventoryImagePath = Core.Inventory.ImgPath()
  cb(Cfg)
end)
