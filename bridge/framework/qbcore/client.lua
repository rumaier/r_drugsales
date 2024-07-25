if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

Framework = {
    notify = function(msg, type)
        if Cfg.Server.notification == 'default' then
            TriggerEvent('QBCore:Notify', msg, 'primary', 3000)
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
            local gender = QBCore.Functions.GetPlayerData().charinfo.gender
            local outfit = gender == 1 and outfits.female or outfits.male
            if not outfit then return end
            TriggerEvent('qb-clothing:client:loadOutfit', {outfitData = outfit})
        else
            TriggerServerEvent('qb-clothing:loadPlayerSkin')
        end
    end,
}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    
end)
