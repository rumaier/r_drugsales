local robberies = {}

local function isPlayerPolice(src)
    local jobs = Cfg.PoliceJobs
    local job = Core.Framework.getPlayerJob(src)
    return lib.table.contains(jobs, job.name)
end

local function getPoliceCount()
    local count = 0
    local players = GetPlayers()
    for _, id in pairs(players) do
        if isPlayerPolice(tonumber(id)) then
            count = count + 1
        end
    end
    return count
end

lib.callback.register('r_drugsales:getPlayerInventory', function(src)
    return Core.Inventory.getPlayerInventory(src)
end)

local function isPlayerNearCustomer(player, customer)
    local pCoords = GetEntityCoords(player)
    local cCoords = GetEntityCoords(customer)
    local distance = #(pCoords - cCoords)
    return distance < 5.0
end

RegisterNetEvent('r_drugsales:setCustomer', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then
        _error('Invalid customer entity for netId ' .. tostring(netId))
    else
        Entity(entity).state:set('drug_customer', true, true)
    end
end)

local function payPlayer(src, amount)
    local type = Cfg.CurrencyType
    local account = Cfg.Currency
    if type == 'item' then
        Core.Inventory.addItem(src, account, amount)
    else
        Core.Framework.addAccountBalance(src, account, amount)
    end
end

lib.callback.register('r_drugsales:retrieve', function(src, netId)
    local robbery = robberies[src]
    if not robbery or netId ~= robbery.netId then
        return _error('Invalid robbery data for player ' .. src)
    end
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not isPlayerNearCustomer(player, customer) then
        return _error('Player ' .. src .. ' is not near the customer for robbery retrieval.')
    end
    local offer = robbery.offer
    local added = Core.Inventory.addItem(src, offer.drug, offer.count)
    if not added then
        return _error('Error adding ' .. offer.drug .. ' to player ' .. src .. ' inventory')
    end
    robberies[src] = nil
    return true
end)

lib.callback.register('r_drugsales:robbery', function(src, netId, offer)
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.count)
    if not removed then
        return _error('Error removing ' .. offer.drug .. ' from player ' .. src)
    end
    robberies[src] = {
        netId = netId,
        offer = offer
    }
    return true
end)

lib.callback.register('r_drugsales:bulk', function(src, netId, offer)
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        return _error('Player ' .. src .. ' attempted a bulk sale with an invalid customer entity.')
    end
    if not isPlayerNearCustomer(player, customer) then
        return _error('Player ' .. src .. ' attempted a bulk sale but is not near the customer.')
    end
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.count)
    if not removed then
        return _error('Error removing ' .. offer.drug .. ' from player ' .. src)
    end
    payPlayer(src, offer.price)
    return true
end)

lib.callback.register('r_drugsales:street', function(src, netId, offer)
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        return _error('Player ' .. src .. ' attempted a street sale with an invalid customer entity.')
    end
    if not isPlayerNearCustomer(player, customer) then
        return _error('Player ' .. src .. ' attempted a street sale but is not near the customer.')
    end
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.count)
    if not removed then
        return _error('Error removing ' .. offer.drug .. ' from player ' .. src)
    end
    payPlayer(src, offer.price)
    return true
end)

local function openMenu(src)
    if isPlayerPolice(src) then
        TriggerClientEvent('r_bridge:notify', src, locale('notify_title'), locale('police_cant_sell'), 'error')
        return
    end
    if getPoliceCount() < Cfg.PoliceNeeded then
        TriggerClientEvent('r_bridge:notify', src, locale('notify_title'), locale('not_enough_police'), 'error')
        return
    end
    TriggerClientEvent('r_drugsales:openMenu', src)
end

local function registerItem()
    local item = Cfg.Item
    Core.Framework.registerUsableItem(item, openMenu)
end

local function registerCommand()
    local cmd = Cfg.Command
    lib.addCommand(cmd, { help = locale('command_help') }, openMenu)
end

AddEventHandler('onResourceStart', function(resource)
    local r_drugsales = GetCurrentResourceName()
    if resource ~= r_drugsales then return end
    local method = Cfg.Interaction
    if method == 'item' then
        registerItem()
    elseif method == 'command' then
        registerCommand()
    end
end)
