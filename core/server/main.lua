local robberies = {}

lib.callback.register('r_drugsales:processBulkSale', function(src, customerNetId, offer)
    local customerEntity = NetworkGetEntityFromNetworkId(customerNetId)
    if not customerEntity or not DoesEntityExist(customerEntity) then return false end
    local playerEntity = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerEntity)
    local customerCoords = GetEntityCoords(customerEntity)
    if #(playerCoords - customerCoords) > 10.0 then return false, _debug('[^1ERROR^0] - Player ' .. src .. ' is too far from customer to complete sale') end
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.amount)
    if not removed then return false, _debug('[^1ERROR^0] - Failed to remove drug item from player ' .. src) end
    if Cfg.Options.CurrencyType == 'account' then
        Core.Framework.addAccountBalance(src, Cfg.Options.CurrencyName, offer.price)
    else
        Core.Inventory.addItem(src, Cfg.Options.CurrencyName, offer.price)
    end
    return true
end)

lib.callback.register('r_drugsales:processRobbery', function(src, customerNetId, offer)
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.amount)
    if not removed then return false, _debug('[^1ERROR^0] - Failed to remove drug item from player ' .. src) end
    local identifier = Core.Framework.getPlayerIdentifier(src)
    if not identifier then return false, _debug('[^1ERROR^0] - Failed to get identifier for player ' .. src) end
    robberies[identifier] = { customerNetId = customerNetId, offer = offer }
    return true
end)

lib.callback.register('r_drugsales:retrieveStolenDrugs', function(src, customerNetId)
    local identifier = Core.Framework.getPlayerIdentifier(src)
    if not identifier then return false, _debug('[^1ERROR^0] - Failed to get identifier for player ' .. src) end
    local robbery = robberies[identifier]
    if not robbery then return false, _debug('[^1ERROR^0] - No robbery data found for player ' .. src) end
    if robbery.customerNetId ~= customerNetId then return false, _debug('[^1ERROR^0] - Customer net ID does not match for player ' .. src) end
    local customerEntity = NetworkGetEntityFromNetworkId(customerNetId)
    if not customerEntity or not DoesEntityExist(customerEntity) then return false, _debug('[^1ERROR^0] - Customer entity does not exist for player ' .. src) end
    local playerEntity = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerEntity)
    local customerCoords = GetEntityCoords(customerEntity)
    if #(playerCoords - customerCoords) > 10.0 then return false, _debug('[^1ERROR^0] - Player ' .. src .. ' is too far from customer to retrieve drugs') end
    local added = Core.Inventory.addItem(src, robbery.offer.drug, robbery.offer.amount)
    if not added then return false, _debug('[^1ERROR^0] - Failed to add drug item back to player ' .. src) end
    robberies[identifier] = nil
    return true
end)

lib.callback.register('r_drugsales:processStreetSale', function(src, customerNetId, offer)
    local customerEntity = NetworkGetEntityFromNetworkId(customerNetId)
    if not customerEntity or not DoesEntityExist(customerEntity) then return false end
    local playerEntity = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerEntity)
    local customerCoords = GetEntityCoords(customerEntity)
    if #(playerCoords - customerCoords) > 10.0 then return false, _debug('[^1ERROR^0] - Player ' .. src .. ' is too far from customer to complete sale') end
    local removed = Core.Inventory.removeItem(src, offer.drug, offer.amount)
    if not removed then return false, _debug('[^1ERROR^0] - Failed to remove drug item from player ' .. src) end
    if Cfg.Options.CurrencyType == 'account' then
        Core.Framework.addAccountBalance(src, Cfg.Options.CurrencyName, offer.price)
    else
        Core.Inventory.addItem(src, Cfg.Options.CurrencyName, offer.price)
    end
    return true
end)

RegisterNetEvent('r_drugsales:setPedAsCustomer', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then return end
    Entity(entity).state:set('drug_customer', true, true)
end)

local function isPlayerPolice(src)
    local policeJobs = Cfg.Options.PoliceJobs
    local playerJob = Core.Framework.getPlayerJob(src)
    return lib.table.contains(policeJobs, playerJob.name)
end

lib.callback.register('r_drugsales:isPlayerPolice', isPlayerPolice)

lib.callback.register('r_drugsales:getPoliceCount', function()
    local count = 0
    local players = GetPlayers()
    for _, id in pairs(players) do
        if isPlayerPolice(id) then count = count + 1 end
    end
    return count
end)

lib.callback.register('r_drugsales:getPlayerInventory', function(src)
    local inventory = Core.Inventory.getPlayerInventory(src)
    return inventory
end)

local function registerUsablePhoneItem()
    if Cfg.Options.Interaction ~= 'item' then return end
    Core.Framework.registerUsableItem(Cfg.Options.InteractItem, function(src)
        print(('[^5r_drugsales^0] Player %s used dealer phone item'):format(src))
        TriggerClientEvent('r_drugsales:openMenu', src)
    end)
end

local function registerInteractCommand()
    if Cfg.Options.Interaction ~= 'command' then return end
    lib.addCommand(Cfg.Options.InteractCommand, {
        help = _L('command_help')
    }, function(src)
        TriggerClientEvent('r_drugsales:openMenu', src)
    end)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    registerUsablePhoneItem()
    registerInteractCommand()
end)