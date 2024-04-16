if GetResourceState('qb-core') ~= 'started' then return end
print('Current Framework: QBCore')

local QBCore = exports['qb-core']:GetCoreObject()

function SvNotify(msg, type)
    local src = source
    if Cfg.Notification == 'default' then
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    elseif Cfg.Notification == 'ox' then
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function SvAddMoney(src, amount)
    local player = GetPlayer(src)
    if player or not amount then
        print(src, " Is A Cheater")
        return
    end

    if Cfg.Account == 'money' then Cfg.Account = 'cash' end

    player.Functions.AddMoney(Cfg.Account, amount)
end

function SvRemoveItem(src, item, qty)
    local player = GetPlayer(src)
    if not player then return end
    player.Functions.RemoveItem(item, qty)
end

function SvInvCheck(item)
    local src = source
    local player = GetPlayer(src)
    local inventory = player.Functions.GetItemByName(item)
    if inventory then
        return inventory
    end
end

function RegisterUsableItem(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
end
