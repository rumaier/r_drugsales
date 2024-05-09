if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function ClNotify(msg, type)
    if Cfg.Notification == 'default' then
        TriggerEvent('QBCore:Notify', msg, 'primary', 3000)
    elseif Cfg.Notification == 'ox' then
        lib.notify({ description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function ClJobCheck()
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return false end

    for _, policeJob in ipairs(Cfg.PoliceJobs) do
        if playerData.job.name == policeJob then
            return true
        end
    end
    return false
end

function ClInvCheck()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if not PlayerData or not PlayerData.items or not next(PlayerData.items) then
        return false
    end

    for drug, _ in pairs(Cfg.Drugs) do
        for _, item in pairs(PlayerData.items) do
            if drug == item.name then
                GetData(item.name, item.label, item.amount or item.count)
                return true
            end
        end
    end
    return false
end
