Cfg = Cfg or {}

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

local function applyClientConfig(config)
    for key, value in pairs(config) do
        Cfg[key] = value
    end
    TriggerEvent('r_drugsales:clientConfigLoaded')
end

local function loadClientConfig()
    local config
    for attempt = 1, 10 do
        local success, response = pcall(lib.callback.await, 'r_drugsales:getClientConfig', false)
        if success and type(response) == 'table' then
            config = response
            break
        end
        Wait(attempt * 250)
    end
    if not config then
        log('warn', 'Failed to load client config; retrying in the background')
        CreateThread(function()
            while true do
                Wait(1000)
                local success, response = pcall(lib.callback.await, 'r_drugsales:getClientConfig', false)
                if success and type(response) == 'table' then
                    applyClientConfig(response)
                    return
                end
            end
        end)
        return
    end
    applyClientConfig(config)
end

local function buildNuiConfig()
    return {
        Language = Cfg.Language,
        NuiColor = Cfg.NuiColor,
        BulkSalesEnabled = Cfg.BulkSalesEnabled,
        DrugItems = copyDrugItemsForClient(Cfg.DrugItems),
        IconPath = bridge.inventory.getIconPath(),
    }
end

function NormalizeTarget(data)
    if type(data) ~= 'table' then
        return {
            entity = data,
            coords = GetEntityCoords(data),
        }
    end
    return data
end

RegisterNUICallback('setNuiFocus', function(focus, cb)
    SetNuiFocus(focus, focus)
    cb(IsNuiFocused())
end)

RegisterNUICallback('fetchLocales', function(_, cb)
    cb(Language[Cfg.Language or 'en'])
end)

RegisterNUICallback('fetchConfig', function(_, cb)
    cb(buildNuiConfig())
end)

loadClientConfig()
