function NormalizeTarget(data)
    if type(data) ~= 'table' then
        return {
            entity = data,
            coords = GetEntityCoords(data),
        }
    else
        return data
    end
end

RegisterNUICallback('setNuiFocus', function(focus, cb)
    SetNuiFocus(focus, focus)
    cb(IsNuiFocused())
end)

RegisterNUICallback('fetchLocales', function(_, cb)
    cb(Language[Cfg.Language])
end)

RegisterNUICallback('fetchConfig', function(_, cb)
    Cfg.IconPath = bridge.inventory.getIconPath()
    cb(Cfg)
end)
