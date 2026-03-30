local phoneModel = `prop_prologue_phone`
local phoneProp = nil

RegisterNUICallback('triggerStreet', function(_, cb)
    if IsStreetSelling() or IsBulkSelling() then
        Core.Interface.notify(locale('notify_title'), locale('already_selling'), 'error')
        return cb(false)
    end
    cb(StreetSale())
end)

RegisterNUICallback('triggerBulk', function(_, cb)
    if IsStreetSelling() or IsBulkSelling() then
        Core.Interface.notify(locale('notify_title'), locale('already_selling'), 'error')
        return cb(false)
    end
    if IsBulkCooldown() then
        local duration = Cfg.BulkCooldown
        Core.Interface.notify(locale('notify_title'), locale('on_cooldown', duration), 'error')
        return cb(false)
    end
    cb(BulkSale())
end)

RegisterNUICallback('getTime', function(_, cb)
    cb({
        hour = GetClockHours(),
        minute = GetClockMinutes()
    })
end)

function DeletePhone()
    if not phoneProp then return end
    DeleteEntity(phoneProp)
    phoneProp = nil
end

RegisterNUICallback('closeMenu', function(_, cb)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_out', 750, 16, 0.0)
    Wait(750)
    DeletePhone()
    cb(true)
end)

local function triggerPhoneAnim()
    phoneProp = Core.Natives.createObject(phoneModel, vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(phoneProp, cache.ped, 90, 0, 0, 0, 0, 0, 0, false, false, false, false, 2, true)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_in', 750, 16, 0.0)
    Wait(750)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_read_base', -1, 17, 0.0)
end

RegisterNetEvent('r_drugsales:openMenu', function()
    SendNUIMessage({ action = 'openMenu' })
    SetNuiFocus(true, true)
    triggerPhoneAnim()
end)