if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function ClNotify(msg, type)
    if Cfg.Notification == 'default' then
        TriggerEvent('QBCore:Notify', msg, type, 3000)
    elseif Cfg.Notification == 'ox' then
        lib.notify({ description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function ClJobCheck()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return (PlayerData.job.name == "police")
end

function ClInvCheck()
    for k, v in pairs(Cfg.Drugs) do
        Item = QBCore.Functions.HasItem(k)
        print(json.encode(Item))
        if Item == nil then
            return
        end
    end
end
