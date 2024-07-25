if GetResourceState('qb-target') ~= 'started' or GetResourceState('ox_target') == 'started' then return end

Target = {
    addLocalEntity = function(entities, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddTargetEntity(entities, {
            options = options,
            distance = 1.5
        })
    end,

    addModel = function(models, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddTargetModel(models, {
            options = options,
            distance = 1.5, 
        })
    end,

    addBoxZone = function(name, coords, size, heading, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
            name = name,
            debugPoly = Cfg.Debug.targets,
            heading = heading,
            minZ = coords.z - (size.x * 0.5),
            maxZ = coords.z + (size.x * 0.5),
        }, {
            options = options,
            distance = 1.5,
        })
    end,

    removeLocalEntity = function(entity)
        exports['qb-target']:RemoveTargetEntity(entity)
    end,

    removeModel = function(model)
        exports['qb-target']:RemoveTargetModel(model)
    end,

    removeZone = function(name)
        exports['qb-target']:RemoveZone(name)
    end
}
