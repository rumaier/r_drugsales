lib.callback.register('r_drugsales:checkIfPolice', function(src)
    local job = Core.Framework.GetPlayerJob(src)
    for _, policeJob in pairs(Cfg.Dispatch.policeJobs) do
        if job == policeJob then
            return true
        end
    end
    return false
end)

lib.callback.register('r_drugsales:getPoliceOnline', function(src)
    local count = 0
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local job = Core.Framework.GetPlayerJob(playerId)
        for _, policeJob in pairs(Cfg.Dispatch.policeJobs) do
            if job == policeJob then
                count = count + 1
            end
        end
    end
    return count or 0
end)

lib.callback.register('r_drugsales:getPlayerItems', function(src)
    return Core.Inventory.GetInventoryItems(src)
end)

lib.callback.register('r_drugsales:streetSale', function(src, playerNetId, customerNetId, itemInfo)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local playerItem = Core.Inventory.GetItem(src, itemInfo.name)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local pCoords, cCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(pCoords - cCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src. _L('cheater')) return false end
    if not playerItem or playerItem.count < Cfg.Selling.streetQuantity[1] then return false end
    local quantity = math.random(Cfg.Selling.streetQuantity[1], math.min(Cfg.Selling.streetQuantity[2], playerItem.count))
    local pay = math.random(Cfg.Selling.drugs[itemInfo.name].street[1], Cfg.Selling.drugs[itemInfo.name].street[2]) * quantity
    Core.Inventory.RemoveItem(src, itemInfo.name, quantity)
    Core.Framework.AddAccountBalance(src, Cfg.Selling.account, pay)
    return true, quantity, pay
end)

lib.callback.register('r_drugsales:bulkSale', function(src, playerNetId, customerNetId, itemInfo)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local playerItem = Core.Inventory.GetItem(src, itemInfo.name)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local pCoords, cCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(pCoords - cCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src. _L('cheater')) return false end
    if not playerItem or playerItem.count < Cfg.Selling.bulkQuantity[1] then return false end
    local quantity = math.random(Cfg.Selling.bulkQuantity[1], math.min(Cfg.Selling.bulkQuantity[2], playerItem.count))
    local pay = math.random(Cfg.Selling.drugs[itemInfo.name].bulk[1], Cfg.Selling.drugs[itemInfo.name].bulk[2]) * quantity
    Core.Inventory.RemoveItem(src, itemInfo.name, quantity)
    Core.Framework.AddAccountBalance(src, Cfg.Selling.account, pay)
    return true, quantity, pay
end)

lib.callback.register('r_drugsales:robPlayer', function(src, slot)
    local quantity = math.random(table.unpack(Cfg.Selling.streetQuantity))
    Core.Inventory.RemoveItem(src, slot.name, quantity)
    return true, quantity
end)

lib.callback.register('r_drugsales:retrieveDrugs', function(src, slot, quantity, playerNetId, customerNetId)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local pCoords, cCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(pCoords - cCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src. _L('cheater')) return false end
    Core.Inventory.AddItem(src, slot.name, quantity)
    return true
end)

if Cfg.Server.interaction == 'item' then
    Core.Framework.RegisterUsableItem('r_trapphone', function(src)
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end)
elseif Cfg.Server.interaction == 'command' then
    RegisterCommand(Cfg.Server.command, function(src)
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end, false)
end