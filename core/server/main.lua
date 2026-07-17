local bulkOrders = {}
local robberies = {}

local function getPoliceCount()
    local count = 0
    for _, id in pairs(GetPlayers()) do
        local src = tonumber(id)
        if src then
            local job = bridge.framework.getPlayerJob(src) or {}
            if lib.table.contains(Cfg.PoliceJobs, job.name) then
                count = count + 1
            end
        end
    end
    return count
end

local function giveMoney(src, amount)
    local currency = Cfg.Currency
    if Cfg.CurrencyType == 'item' then
        bridge.inventory.addItem(src, currency, amount)
    else
        bridge.framework.addBalance(src, currency, amount)
    end
end

local function getPlayerDrugs(src)
    local drugs = {}
    local inventory = bridge.inventory.getInventory(src) or {}
    for _, item in pairs(inventory) do
        if Cfg.DrugItems[item.name] then
            table.insert(drugs, item)
        end
    end
    return drugs
end

lib.callback.register('r_drugsales:getPlayerDrugs', function(src)
    return getPlayerDrugs(src)
end)

RegisterNetEvent('r_drugsales:setPedAsCustomer', function(netId)
    local ped = NetworkGetEntityFromNetworkId(netId)
    if not ped or not DoesEntityExist(ped) then return end
    Entity(ped).state:set('drugCustomer', true, true)
end)

RegisterNetEvent('r_drugsales:clearBulkOrder', function()
    if bulkOrders[source] then
        bulkOrders[source] = nil
    end
end)

lib.callback.register('r_drugsales:bulkOrderRequest', function(src)
    local items = {}
    for _, item in pairs(getPlayerDrugs(src)) do
        if Cfg.DrugItems[item.name] and item.count >= Cfg.DrugItems[item.name].bulk.minRequest then
            table.insert(items, item)
        end
    end
    if #items == 0 then return items, false end
    local item = items[math.random(#items)]
    local cfg = Cfg.DrugItems[item.name].bulk
    local count = math.random(cfg.minRequest, math.min(cfg.maxRequest, item.count))
    local price = math.random(cfg.minPrice, cfg.maxPrice) * count
    bulkOrders[src] = { item = item, count = count, price = price }
    return items, bulkOrders[src]
end)

lib.callback.register('r_drugsales:processBulkSale', function(src, netId)
    local order = bulkOrders[src]
    bulkOrders[src] = nil
    if not order then
        print('^1[r_drugsales]^0 No bulk order found for player ' .. src)
        return false
    end
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        print('^1[r_drugsales]^0 Player ' .. src .. ' attempted to sell drugs to a customer who does not exist')
        return false
    end
    local pCoords = GetEntityCoords(player)
    local cCoords = GetEntityCoords(customer)
    if #(pCoords - cCoords) > 5.0 then
        print('^1[r_drugsales]^0 Player ' .. src .. ' attempted to sell drugs to a customer who is too far away')
        return false
    end
    if not bridge.inventory.removeItem(src, order.item.name, order.count) then
        print('^1[r_drugsales]^0 Failed to remove ' .. order.count .. ' x ' .. order.item.name .. ' from player ' .. src)
        return false
    end
    giveMoney(src, order.price)
    return true
end)

lib.callback.register('r_drugsales:processStreetRetrieval', function(src, netId)
    local identifier = bridge.framework.getPlayerIdentifier(src)
    if not identifier then
        print('^1[r_drugsales]^0 Failed to get player identifier for player ' .. src)
        return false
    end
    if not robberies[identifier] then
        print('^1[r_drugsales]^0 No robbery found for player ' .. src)
        return false
    end
    if robberies[identifier].netId ~= netId then
        print('^1[r_drugsales]^0 Net ID mismatch for player ' .. src)
        return false
    end
    if not bridge.inventory.addItem(src, robberies[identifier].offer.item, robberies[identifier].offer.count) then
        print('^1[r_drugsales]^0 Failed to add ' .. robberies[identifier].offer.count .. ' x ' .. robberies[identifier].offer.item .. ' to player ' .. src)
        return false
    end
    robberies[identifier] = nil
    return true
end)

lib.callback.register('r_drugsales:processStreetRobbery', function(src, netId, offer)
    if not bridge.inventory.removeItem(src, offer.item, offer.count) then
        print('^1[r_drugsales]^0 Failed to remove ' .. offer.count .. ' x ' .. offer.item .. ' from player ' .. src)
        return false
    end
    local identifier = bridge.framework.getPlayerIdentifier(src)
    if not identifier then
        print('^1[r_drugsales]^0 Failed to get player identifier for player ' .. src)
        return false
    end
    robberies[identifier] = {
        netId = netId,
        offer = offer
    }
    return true
end)

lib.callback.register('r_drugsales:processStreetSale', function(src, netId, offer)
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        print('^1[r_drugsales]^0 Player ' .. src .. ' attempted to sell drugs to a customer who does not exist')
        return false
    end
    local pCoords = GetEntityCoords(player)
    local cCoords = GetEntityCoords(customer)
    if #(pCoords - cCoords) > 5.0 then
        print('^1[r_drugsales]^0 Player ' .. src .. ' attempted to sell drugs to a customer who is too far away')
        return false
    end
    if not bridge.inventory.removeItem(src, offer.item, offer.count) then
        print('^1[r_drugsales]^0 Failed to remove ' .. offer.count .. ' x ' .. offer.item .. ' from player ' .. src)
        return false
    end
    giveMoney(src, offer.price * offer.count)
    return true
end)

lib.callback.register('r_drugsales:menuRequest', function(src)
    local job = bridge.framework.getPlayerJob(src) or {}
    if lib.table.contains(Cfg.PoliceJobs, job.name) then
        return false, 'no_police_allowed'
    end
    local minPolice = Cfg.MinPoliceRequired
    if minPolice and getPoliceCount() < minPolice then
        return false, 'not_enough_police'
    end
    return true
end)

local function registerInteractMethod()
    local method = Cfg.InteractMethod
    if method == 'item' then
        bridge.framework.registerUsableItem(Cfg.InteractItem, function(src)
            TriggerClientEvent('r_drugsales:openMenu', src)
        end)
    elseif method == 'command' then
        lib.addCommand(Cfg.InteractCommand, { help = locale('command_help') }, function(src)
            TriggerClientEvent('r_drugsales:openMenu', src)
        end)
    else
        error('Invalid interact method: ' .. method)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    registerInteractMethod()
end)