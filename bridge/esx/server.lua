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

RegisterNetEvent('r_drugsales:invcheck')
AddEventHandler('r_drugsales:invcheck', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    for k, v in pairs(Cfg.Drugs) do
        Item = xPlayer.getInventoryItem(k)
    end
    return Item
end)
