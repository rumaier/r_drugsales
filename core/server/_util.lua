local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)

local function checkVersion()
    if not Cfg.VersionCheck then return end
    bridge.version.check(resource)
    SetTimeout(3600000, checkVersion)
end

local function isBridgeCompatible()
    local v = bridge.version.current:gsub('%.', '')
    return tonumber(v) >= 300
end

local function buildDb()
    MySQL.query(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `example` varchar(50) NOT NULL,
            PRIMARY KEY (`example`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci
    ]]):format(resource), function(resp)
        if resp.warningStatus == 0 then
            print('Database built for ' .. resource)
        end
        -- fire off any fetches etc
    end)
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
    -- buildDb()
end)
