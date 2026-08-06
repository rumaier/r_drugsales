local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)
local rateLimits = {}
local cooldowns = {}

function IsRateLimited(src, action, duration)
    local last = rateLimits[('%s:%s'):format(src, action)]
    return last and GetGameTimer() - last < duration
end

function SetRateLimit(src, action)
    rateLimits[('%s:%s'):format(src, action)] = GetGameTimer()
end

function IsOnCooldown(src, action, duration)
    local last = cooldowns[('%s:%s'):format(src, action)]
    return last and GetGameTimer() - last < duration
end

function SetCooldown(src, action)
    cooldowns[('%s:%s'):format(src, action)] = GetGameTimer()
end

local function copyDrugItemsForClient(drugItems)
    local copied = {}
    for name, data in pairs(drugItems or {}) do
        copied[name] = {
            street = {
                maxOffer = data.street.maxOffer,
                maxPrice = data.street.maxPrice,
            },
        }
    end
    return copied
end

lib.callback.register('r_drugsales:getClientConfig', function()
    return {
        Language = Cfg.Language,
        NuiColor = Cfg.NuiColor,
        Debug = Cfg.Debug,
        BulkSalesEnabled = Cfg.BulkSalesEnabled,
        DrugItems = copyDrugItemsForClient(Cfg.DrugItems),
        EnableZones = Cfg.EnableZones,
        ZoneBehavior = Cfg.ZoneBehavior,
        Zones = Cfg.Zones,
        StreetPedMethod = Cfg.StreetPedMethod,
        StreetPedFrequency = Cfg.StreetPedFrequency,
        StreetFetchDistance = Cfg.StreetFetchDistance,
        StreetPedWalkSpeed = Cfg.StreetPedWalkSpeed,
        StreetAbandonDistance = Cfg.StreetAbandonDistance,
        StreetDispatchOdds = Cfg.StreetDispatchOdds,
        StreetRobberyChance = Cfg.StreetRobberyChance,
        StreetPedModels = Cfg.StreetPedModels,
        BulkPedModels = Cfg.BulkPedModels,
        BulkMeetupTimer = Cfg.BulkMeetupTimer,
        BulkSaleCooldown = Cfg.BulkSaleCooldown,
        ForceCleanup = Cfg.ForceCleanup,
        InteractMethod = Cfg.InteractMethod,
        InteractItem = Cfg.InteractItem,
        InteractCommand = Cfg.InteractCommand,
        DispatchResource = Cfg.DispatchResource,
        PoliceJobs = Cfg.PoliceJobs,
        VersionCheck = Cfg.VersionCheck,
    }
end)

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
    if Cfg and Cfg.Debug then print('^1' .. locale('debug_enabled') .. '^0') end
    print('------------------------------')
    checkVersion()
end)

AddEventHandler('playerDropped', function()
    local src = source
    local prefix = '^' .. src .. ':'
    for key in pairs(rateLimits) do
        if key:match(prefix) then rateLimits[key] = nil end
    end
    for key in pairs(cooldowns) do
        if key:match(prefix) then cooldowns[key] = nil end
    end
end)
