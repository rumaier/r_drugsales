if not Cfg.Dispatch then return end

RegisterNetEvent('r_drugsales:notifyPolice')
AddEventHandler('r_drugsales:notifyPolice', function(coords)
    local cop = ClJobCheck()
    if cop then
        if Cfg.Dispatch == 'linden_outlawalert' then
            local player = PlayerPedId()
            local coords = coords
            local data = {
                displayCode = '10-17',
                description = 'Suspicious Person',
                isImportant = 0,
                recipientList = Cfg.PoliceJobs,
                length = '10000',
                infoM = 'fa-info-circle',
                info = 'Possible Narcotics Distrubution'
            }
            local dispatchData = { dispatchData = data, caller = 'Anonymous', coords = coords }
            TriggerServerEvent('wf-alerts:svNotify', dispatchData)
        elseif Cfg.Dispatch == 'cd_dispatch' then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = Cfg.PoliceJobs,
                coords = data.coords,
                title = '10-17 - Suspicious Person',
                message = 'A ' .. data.sex .. ' is dealing narcotics at ' .. data.street,
                flash = 0,
                unique_id = data.unique_id,
                sound = 1,
                blip = {
                    sprite = 161,
                    scale = 1.0,
                    colour = 2,
                    flashes = true,
                    text = '10-17 - Suspicious Person',
                    time = 5,
                    radius = 0,
                }
            })
        elseif Cfg.Dispatch == 'rcore_dispatch' then
            local player_data = exports['rcore_dispatch']:GetPlayerData()
            local text = ('Hello, a %s is dealing narcotics, please come as fast as possible to %s!'):format(
                player_data.sex,
                player_data.street)
            local data = {
                code = '10-17 - Suspicious Person',
                default_priority = 'low',
                coords = player_data.coords,
                job = Cfg.PoliceJobs,
                text = text,
                type = 'alerts',
                blip_time = 5,
                blip = {
                    sprite = 161,
                    colour = 2,
                    scale = 1.0,
                    text = '10-17 - Suspicious Person',
                    flashes = true,
                }
            }
            TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
        elseif Cfg.Dispatch == 'core_dispatch' then
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            exports['core_dispatch']:addCall("10-17", "Suspicious Person",
                { { icon = "fa-cannabis", info = "Someone is dealing Narcotics." } }, coords, Cfg.PoliceJobs, 3000, 11, 5)
        elseif Cfg.Dispatch == 'custom' then
            -- add your dispatch system here
        end
    end
end)
