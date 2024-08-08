lib.callback.register('r_drugsales:checkIfPolice', function(src)
    local job = Framework.getPlayerJob(src)
    for _, police in pairs(Cfg.Dispatch.policeJobs) do
        if job == police then
            return true
        end
    end
    return false
end)

lib.callback.register('r_drugsales:getPoliceOnline', function(src)
    local count = 0
    local players = GetPlayers()
    for _, playerId in pairs(players) do
        local job = Framework.getPlayerJob(tonumber(playerId))
        for _, police in pairs(Cfg.Dispatch.policeJobs) do
            if job == police then
                count = count + 1
            end
        end
    end
    return count or 0
end)

lib.callback.register('r_drugsales:getPlayerInventory', function(src)
    return Inventory.getPlayerInventory(src)
end)

lib.callback.register('r_drugsales:streetSale', function(src, playerNetId, customerNetId, itemInfo)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local playerItem = Inventory.getPlayerItem(src, itemInfo.name)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local playerCoords, customerCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(playerCoords - customerCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src, _L('cheater')) return false end
    if not playerItem or playerItem < Cfg.Selling.streetQuantity[1] then return false end
    local quantity = math.random(Cfg.Selling.streetQuantity[1], math.min(Cfg.Selling.streetQuantity[2], playerItem))
    local pay = math.random(Cfg.Selling.drugs[itemInfo.name].street[1], Cfg.Selling.drugs[itemInfo.name].street[2]) * quantity
    Inventory.removePlayerItem(src, itemInfo.name, quantity)
    Framework.addAccountMoney(src, Cfg.Selling.account, pay)
    return true, quantity, pay
end)

lib.callback.register('r_drugsales:bulkSale', function(src, playerNetId, customerNetId, itemInfo)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local playerItem = Inventory.getPlayerItem(src, itemInfo.name)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local playerCoords, customerCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(playerCoords - customerCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src, _L('cheater')) return false end
    if not playerItem or playerItem < Cfg.Selling.bulkQuantity[1] then return false end
    local quantity = math.random(Cfg.Selling.bulkQuantity[1], playerItem)
    local pay = math.random(Cfg.Selling.drugs[itemInfo.name].bulk[1], Cfg.Selling.drugs[itemInfo.name].bulk[2]) * quantity
    Inventory.removePlayerItem(src, itemInfo.name, quantity)
    Framework.addAccountMoney(src, Cfg.Selling.account, pay * quantity)
    return true, quantity, pay
end)

lib.callback.register('r_drugsales:robPlayer', function(src, slot)
    local quantity = math.random(table.unpack(Cfg.Selling.streetQuantity))
    Inventory.removePlayerItem(src, slot.name, quantity)
    return true, quantity
end)

lib.callback.register('r_drugsales:retrieveDrugs', function(src, slot, quantity, playerNetId, customerNetId)
    local saleStep = lib.callback.await('r_drugsales:getSaleStep', src)
    local player, customer = NetworkGetEntityFromNetworkId(playerNetId), NetworkGetEntityFromNetworkId(customerNetId)
    local playerCoords, customerCoords = GetEntityCoords(player), GetEntityCoords(customer)
    local distance = #(playerCoords - customerCoords)
    if distance > 10 then DropPlayer(src, _L('cheater')) return false end
    if saleStep ~= 3 then DropPlayer(src, _L('cheater')) return false end
    Inventory.givePlayerItem(src, slot.name, quantity)
    return true
end)

if Cfg.Server.interaction == 'item' then
    Framework.registerUsableItem('r_trapphone', function(src)
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end)
elseif Cfg.Server.interaction == 'command' then
    RegisterCommand(Cfg.Server.command, function(src)
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end, false)
end

function debug(...)
    if Cfg.Debug.prints then
        print(...)
    end
end

local function checkVersion()
    if not Cfg.Server.versionCheck then return end
    local url = 'https://api.github.com/repos/rumaier/r_drugsales/releases/latest'
    local current = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    PerformHttpRequest(url, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            local latest = data.tag_name
            if latest ~= current then
                print('^8[!]^0 ^3' .. _L('update', GetCurrentResourceName()) ..'^0')
                print('^8[!]^0 ^3https://github.com/rumaier/r_drugsales/releases/latest^0')
            end
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        print('------------------------------')
        print(_L('version', GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0)))
        print(_L('framework', Core.Framework))
        print(_L('inventory', Core.Inventory))
        print(_L('target', Core.Target))
        print('------------------------------')
        checkVersion()
    end
end)