if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports["es_extended"]:getSharedObject()

function ClNotify(msg, type)
    if Cfg.Notification == 'default' then
        ESX.ShowNotification(msg, type)
    elseif Cfg.Notification == 'ox' then
        lib.notify({ description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function ClJobCheck()
    local job = ESX.GetPlayerData().job
    return (job.name == "police")
end

function ClInvCheck(item)
    if not item then
        for k, v in pairs(Cfg.Drugs) do
            Item = ESX.SearchInventory(k)
            if Item ~= nil then
                GetData(Item["name"], Item["label"], Item["count"])
                return true
            end
        end
    else
        Item = ESX.SearchInventory(item)
        if Item ~= nil then
            GetData(Item["name"], Item["label"], Item["count"])
            return true
        end
    end
end
