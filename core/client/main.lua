local phone = { model = 'prop_prologue_phone', entity = nil }

RegisterNUICallback('triggerStreetSell', function(_, cb)
    if IsStreetSelling() then
        Core.Interface.notify(_L('notify_title'), _L('already_selling'), 'error')
        cb(false)
        return
    end
    local started = InitializeStreetSale()
    cb(started)
end)

RegisterNUICallback('triggerBulkOrder', function(_, cb)
    if IsBulkSelling() then
        Core.Interface.notify(_L('notify_title'), _L('already_selling'), 'error')
        cb(false)
        return
    end
    local started = InitializeBulkSale()
    cb(started)
end)

RegisterNUICallback('getGameTime', function(_, cb)
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    cb({ hour = hour, minute = minute })
end)

RegisterNUICallback('cleanupPhone', function(_, cb)
    cb(true)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_out', 750, 0, 0.0)
    if not phone.entity then return end
    SetTimeout(750, function()
        DeleteEntity(phone.entity)
        phone.entity = nil
    end)
end)

local function triggerPhoneAnimation()
    phone.entity = Core.Natives.createObject(phone.model, vec3(0, 0, 0), 0, true)
    repeat Wait(0) until DoesEntityExist(phone.entity)
    AttachEntityToEntity(phone.entity, cache.ped, 90, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_in', 750, 0, 0.0)
    SetTimeout(750, function()
        Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_read_base', -1, 1, 0.0)
    end)
end

local function openMenu()
    local isPolice = lib.callback.await('r_drugsales:isPlayerPolice', false)
    local policeCount = lib.callback.await('r_drugsales:getPoliceCount', false)
    if isPolice then Core.Interface.notify(_L('notify_title'), _L('police_cant_sell'), 'error') return end
    if policeCount < Cfg.Options.MinimumPolice then Core.Interface.notify(_L('notify_title'), _L('not_enough_police'), 'error') return end
    triggerPhoneAnimation()
    SetTimeout(750, function()
        _debug('[^6DEBUG^0] - Opening dealer menu')
        SendNUIMessage({ action = 'mount', data = 'dealerMenu' })
        SetNuiFocus(true, true)
    end)
end

RegisterNetEvent('r_drugsales:openMenu', openMenu)
