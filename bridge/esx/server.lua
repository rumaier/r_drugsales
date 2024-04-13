if GetResourceState('es_extended') ~= 'started' then return end
print('Current Framework: ESX')

local ESX = exports["es_extended"]:getSharedObject()

function SvNotify(msg, type)
    local src = source    
    if Cfg.Notification == 'default' then
        TriggerClientEvent('esx:showNotification', src, msg, type)
    elseif Cfg.Notification == 'ox' then
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function SvAddMoney(src, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not amount then
        print(src, " Is A Cheater")
        return
    end
    xPlayer.addMoney(amount)
end

function SvRemoveItem(src, item, qty)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.removeInventoryItem(item, qty)
end

function SvInvCheck(item)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local item = xPlayer.getInventoryItem(item)
    if item["stack"] then
        return item
    end
end

if Cfg.Interaction == 'item' then
    ESX.RegisterUsableItem('r_trapphone', function(source)
        local src = source
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end)
end
