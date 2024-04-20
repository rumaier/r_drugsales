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
    for _, policeJob in ipairs(Cfg.PoliceJobs) do
        if job.name == policeJob then
            return true
        end
    end
    return false
end

function ClInvCheck(type)
    if type == 'street' then
        local raw = ESX.GetPlayerData().inventory
        for k, v in pairs(raw) do
            for _, drug in pairs(Cfg.Drugs) do
                if v["name"] == _ then
                    GetData(v["name"], v["label"], v["count"])
                    return v
                end
            end
        end
    elseif type == 'bulk' then
        local raw = ESX.GetPlayerData().inventory
        for k, v in pairs(raw) do
            for _, drug in pairs(Cfg.Drugs) do
                if v["name"] == _ and (v["count"] >= Cfg.BulkSale.Min) then
                    GetData(v["name"], v["label"], v["count"])
                    return v
                end
            end
        end
    end
end

RegisterCommand('debuginvcheck', function()
    ClInvCheck()
end, false)
