if GetResourceState('qb-core') ~= 'started' then return end

Core.Framework = 'QBCore'
local QBCore = exports['qb-core']:GetCoreObject()

Framework = {
    notify = function(src, msg, type)
        local src = src or source
        if Cfg.Notification == 'default' then
            TriggerClientEvent('QBCore:Notify', src, msg, type)
        elseif Cfg.Notification == 'ox' then
            TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type, position = 'top' })
        elseif Cfg.Notification == 'custom' then
            -- Insert your notification system here
        end
    end,

    getPlayerIdentifier = function(src)
        local src = src or source
        return QBCore.Functions.GetIdentifier(src, 'license')
    end,

    getPlayerName = function(src)
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end,

    getPlayerJob = function(src)
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.job.name
    end,

    getPlayerJobGrade = function(src)
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.job.grade.level
    end,

    addAccountMoney = function(src, acct, amt)
        if acct == 'money' then
            acct = 'cash'
        end
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney(acct, amt, 'idk')
    end,

    removeAccountMoney = function(src, acct, amt)
        if acct == 'money' then
            acct = 'cash'
        end
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney(acct, amt, 'idk')
    end,

    getAccountBalance = function(src, acct)
        local src = src or source
        local Player = QBCore.Functions.GetPlayer(src)
        if acct == 'money' then
            acct = 'cash'
        end
        return Player.PlayerData.money[acct]
    end,

    registerUsableItem = function(item, cb)
        QBCore.Functions.CreateUseableItem(item, cb)
    end
}
