if not Cfg.Dispatch then return end
print('Current Dispatch System: ' .. Cfg.Dispatch .. '')

RegisterNetEvent('r_drugsales:rollOdds')
AddEventHandler('r_drugsales:rollOdds', function(roll)
    if roll == true then
        local num = math.random(100)
        if num <= Cfg.ReportOdds then
            TriggerClientEvent('r_drugsales:notifyPolice', -1)
        end
    elseif roll == false then
        TriggerClientEvent('r_drugsales:notifyPolice', -1)
    end
end)
