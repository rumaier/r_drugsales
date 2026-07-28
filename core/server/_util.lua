local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)

local function checkVersion()
    if not Cfg.VersionCheck then return end
    bridge.version.check(resource)
    SetTimeout(3600000, checkVersion)
end

AddEventHandler('onResourceStart', function(name)
    if name ~= resource then return end
    print('------------------------------')
    print(resource .. ' | ' .. version)
    if bridge then
        print('^2' .. locale('bridge_loaded') .. '^0')
    else
        print('^1' .. locale('update_bridge') .. '^0')
    end
    if Cfg.Debug then print('^1' .. locale('debug_enabled') .. '^0') end
    print('------------------------------')
    checkVersion()
end)
