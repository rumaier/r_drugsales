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

function SvAddMoney(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not amount then print(src," Is A Cheater") return end
    Player.Functions.AddMoney('cash', amount)
end