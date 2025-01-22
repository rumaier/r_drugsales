Core = exports['r_bridge']:returnCoreObject()

local onPlayerLoaded = Core.Info.Framework == 'ESX' and 'esx:playerLoaded' or 'QBCore:Client:OnPlayerLoaded'
RegisterNetEvent(onPlayerLoaded, function()
    -- do things when players load
end)

function _debug(...)
    if Cfg.Debug then
        print(...)
    end
end