RegisterNetEvent('r_drugsales:dataCheck')
AddEventHandler('r_drugsales:dataCheck', function(coords, info, qty)
    local src = source
    local dist = #(coords[1] - coords[2])
    local hasItem = SvInvCheck(info["drug"])
    if dist > 5 then return end
    if hasItem and (hasItem.count or hasItem.amount or 0) < qty then return end
    local pay = info.pay * qty
    SvRemoveItem(src, hasItem["name"], qty)
    SvAddMoney(src, pay)
    SvNotify('You sold x' .. qty .. ' ' .. hasItem["label"] .. ' for $' .. pay .. '', 'info')
end)

function SvJobCheck(source)
    local player = GetPlayer(source)
    if not player then return false end

    local job = player.job.name

    for _, policeJob in ipairs(Cfg.PoliceJobs) do
        if job == policeJob then
            return true
        end
    end

    return false
end

lib.callback.register('r_drugsales:getCopsOnline', function()
    local cops = 0
    local players = GetPlayers()

    for _, playerId in ipairs(players) do
        if playerId then
            local player = GetPlayer(tonumber(playerId))
            if player then
                local job = player.job and player.job.name or player.PlayerData.job.name
                for _, policeJob in ipairs(Cfg.PoliceJobs) do
                    if job == policeJob then
                        cops = cops + 1
                    end
                end
            end
        end
    end

    return cops or 0
end)

if Cfg.Interaction == 'item' then
    RegisterUsableItem('r_trapphone', function(source)
        local src = source
        TriggerClientEvent('r_drugsales:openDealerMenu', src)
    end)
end

print('ServerSide Is Loaded [r_drugsales, Disco shit... Pure as the driven snow.]')
