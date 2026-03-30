DatabaseBuilt = false
Core = exports.r_bridge:returnCoreObject()

local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)

local function checkVersion()
    if not Cfg.VersionCheck then return end
    Core.VersionCheck(resource)
    SetTimeout(3600000, checkVersion)
end

local function buildDatabase()
    local built = MySQL.query.await('SHOW TABLES LIKE "' .. resource .. '"')
    if #built == 0 then
        built = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `]] .. resource .. [[` (
            `example` varchar(50) NOT NULL,
            PRIMARY KEY (`example`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci
        ]])
        if not built then
            _error('Failed to build database for ' .. resource)
        else
            _debug('Database built for ' .. resource)
            DatabaseBuilt = true
        end
    else
        DatabaseBuilt = true
    end
end

local function startupPrints()
    local debug = Cfg.Debug
    print('------------------------------')
    print(locale('startup_info', resource, version))
    if debug then
        print(locale('debug_enabled'))
    end
    print('------------------------------')
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= resource then return end
    -- buildDatabase()
    startupPrints()
    checkVersion()
end)
