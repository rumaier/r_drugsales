if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports["es_extended"]:getSharedObject()

Framework = {
    notify = function(msg, type)
        if Cfg.Server.notification == 'default' then
            ESX.ShowNotification(msg, type)
        elseif Cfg.Server.notification == 'ox' then
            lib.notify({ description = msg, type = type, position = 'top' })
        elseif Cfg.Server.notification == 'custom' then
            -- Insert your notification system here
        end
    end,

    toggleOutfit = function(on)
        if not Cfg.Uniform.enabled then return end
        if on then
            local outfits = Cfg.Uniform.outfit
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                local gender = skin.sex
                local outfit = gender == 1 and outfits.female or outfits.male
                if not outfit then return end
                TriggerEvent('skinchanger:loadClothes', skin, outfit)
            end)
        else
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        end
    end,
}

RegisterNetEvent('esx:playerLoaded', function()
    while not ESX.IsPlayerLoaded() do Wait(0) end
    -- do stuff when the player loads
end)
