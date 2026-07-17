local PHONE_MODEL = 'prop_prologue_phone'

local phoneProp = nil

function CleanupPhoneProp()
    if not phoneProp then return end
    DeleteEntity(phoneProp)
    phoneProp = nil
end

RegisterNUICallback('getGameTime', function(_, cb)
    cb({ hour = GetClockHours(), minute = GetClockMinutes() })
end)

RegisterNUICallback('onMenuClose', function(_, cb)
    cb(true)
    bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_out', 750, 16, 0.0)
    Wait(750)
    SetNuiFocus(false, false)
    DeleteEntity(phoneProp or 0)
    phoneProp = nil
end)

RegisterNetEvent('r_drugsales:openMenu', function()
    local access, err = lib.callback.await('r_drugsales:menuRequest', false)
    if not access and not err then
        error('Failed to open menu, check server console for more information.')
    elseif not access and err then
        bridge.interface.notify(locale('drug_sales'), locale(err), 'error')
    else
        phoneProp = bridge.natives.createObject(PHONE_MODEL, vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(phoneProp, cache.ped, 90, 0, 0, 0, 0, 0, 0, false, false, false, false, 2, true)
        bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_in', 750, 16, 0.0)
        Wait(750)
        bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_read_base', -1, 17, 0.0)
        SendNUIMessage({ action = 'openMenu' })
        SetNuiFocus(true, true)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if phoneProp then
        ClearPedTasks(cache.ped)
        DeleteEntity(phoneProp)
        SetNuiFocus(false, false)
    end
end)