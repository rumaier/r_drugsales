if GetResourceState('qb-core') ~= 'started' then return end
print('Current Framework: QBCore')

local QBCore = exports['qb-core']:GetCoreObject()

function SvNotify(msg, type)
    local src = source
    if Cfg.Notification == 'default' then
        TriggerClientEvent('QBCore:Notify', src, msg, 'primary')
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
    print('player:', player)
    print('amount:', amount)
    if not player or not amount then
        print(src, " Is A Cheater")
        return
    end

    if Cfg.Account == 'black_money' or Cfg.Account == 'markedbills' then
        player.Functions.AddItem(Cfg.Account, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Cfg.Account], 'add')
        return
    end

    if Cfg.Account == 'money' or Cfg.Account == 'cash' then
        Cfg.Account = 'cash'
        player.Functions.AddMoney(Cfg.Account, amount)    
    end
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
