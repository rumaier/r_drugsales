if GetResourceState('qb-target') ~= 'started' then return end

Target = {
    AddLocalEntity = function(entities, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddTargetEntity(entities, {
            options = options,
            distance = 1.5
        })
    end,

    AddBoxZone = function(name, coords, size, heading, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
            name = name,               
            debugPoly = Cfg.Debug,     
            heading = heading,
            minZ = coords.z - (size.x * 0.5),
            maxZ = coords.z + (size.x * 0.5),
        }, {
            options = options,
            distance = 1.5,
        })
    end
}