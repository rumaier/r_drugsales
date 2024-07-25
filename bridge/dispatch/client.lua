local cfg = Cfg.Dispatch

function TriggerPoliceDispatch()
    if cfg.resource == 'linden_outlawalert' then
        local data = {displayCode = '10-66', description = 'Suspicious Persons', isImportant = 0, recipientList = cfg.policeJobs, length = '10000', infoM = 'fa-info-circle', info = 'Possible narcotic sales reported in the area.'}
        local dispatchData = {dispatchData = data, caller = 'Anonymous', coords = GetEntityCoords(cache.ped)}
        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
    elseif cfg.resource == 'ps-dispatch' then
        exports['ps-dispatch']:DrugSale()
    elseif cfg.resource == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = cfg.policeJobs,
            coords = data.coords,
            title = '10-66 - Suspicious Persons',
            message = 'A ' .. data.sex .. ' reported for narcotic sales near ' .. data.street,
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = { sprite = 431, scale = 1.2, colour = 3, flashes = false, text = '911 - Store Robbery', time = 5, radius = 0, }
        })
    elseif cfg.resource == 'rcore_dispatch' then
        local data = exports['rcore_dispatch']:GetPlayerData()
        TriggerEvent('rcore_dispatch:server:sendAlert', {
            code = '10-66 - ', 
            default_priority = 'low', 
            coords = data.coords,
            job = cfg.policeJobs, 
            text = 'A ' .. data.sex .. ' reported for narcotic sales near ' .. data.street,
            type = 'alerts',
            blip = { sprite = 54, colour = 3, scale = 0.7, text = 'Car theft', flashes = false, radius = 0 }
        })
    elseif cfg.resource == 'custom' then
        -- insert your dispatch system here
    end
end