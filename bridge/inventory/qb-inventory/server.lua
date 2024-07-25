if GetResourceState('qb-inventory') ~= 'started' then return end

Core.Inventory = 'qb-inventory'
local QBCore = exports['qb-core']:GetCoreObject()

Inventory = {
    
    givePlayerItem = function(src, item, qty, metadata)
        local src = src or source
        if metadata then
            local info = metadata
            exports['qb-inventory']:AddItem(src, item, qty, nil, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
        elseif metadata == nil then
            exports['qb-inventory']:AddItem(src, item, qty)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
        end
    end,

    removePlayerItem = function(src, item, qty)
        local src = src or source
        exports['qb-inventory']:RemoveItem(src, item.name, qty)
    end,

    getPlayerItem = function(src, item, metadata)
        local src = src or source
        local hasItems = exports['qb-inventory']:GetItemsByName(src, item)
        return hasItems.amount
    end,

    getPlayerInventory = function(src)
        local src = src or source
        local player = QBCore.Functions.GetPlayer(src)
        return player.PlayerData.items
    end,

    canCarryItem = function(src, item, count)
        local src = src or source
        return true -- idk what to do here, QB is ass...
    end,

    registerStash = function(name, label, slots, weight, owner)
        -- Ignore this, QB does it all client side.
    end,

    getServerItem = function(item)
        if item == 'all' then return QBCore.Shared.Items end
        return QBCore.Shared.Items[item]
    end
}
