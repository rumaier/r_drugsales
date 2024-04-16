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

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function SvAddMoney(src, amount)
    local xPlayer = GetPlayer(src)

    if not xPlayer or not amount then
        print(source .. ' Is Possibly A Cheater!')
    end
    if Cfg.Account == 'cash' then Cfg.Account = 'money' end

    xPlayer.addAccountMoney(Cfg.Account, amount)
end

function SvRemoveItem(src, item, qty)
    local xPlayer = GetPlayer(src)
    if not xPlayer then return end
    xPlayer.removeInventoryItem(item, qty)
end

function SvInvCheck(item)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local item = xPlayer.getInventoryItem(item)
    if item then
        return item
    end
end

function RegisterUsableItem(item, cb)
    ESX.RegisterUsableItem(item, cb)
end
