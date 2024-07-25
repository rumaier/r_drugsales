if GetResourceState('es_extended') ~= 'started' then return end

Core.Framework = 'ESX'
local ESX = exports["es_extended"]:getSharedObject()

Framework = {
    notify = function(src, msg, type)
        local src = src or source
        if Cfg.Notification == 'default' then
            TriggerClientEvent('esx:showNotification', src, msg, type)
        elseif Cfg.Notification == 'ox' then
            TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type, position = 'top' })
        elseif Cfg.Notification == 'custom' then
            -- Insert your notification system here
        end
    end,

    getPlayerIdentifier = function(src)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        return xPlayer.getIdentifier()
    end,

    getPlayerName = function(src)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        return xPlayer.getName()
    end,

    getPlayerJob = function(src)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        return xPlayer.getJob().name
    end,

    getPlayerJobGrade = function(src)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        return xPlayer.getJob().grade
    end,

    addAccountMoney = function(src, acct, amt)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.addAccountMoney(acct, amt)
    end,

    removeAccountMoney = function(src, acct, amt)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.removeAccountMoney(acct, amt)
    end,

    getAccountBalance = function(src, acct)
        local src = src or source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        return xPlayer.getAccount(acct).money
    end,

    registerUsableItem = function(item, cb)
        ESX.RegisterUsableItem(item, cb)
    end
}