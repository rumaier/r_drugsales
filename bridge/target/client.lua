local ox_target = exports.ox_target

if Cfg.Target == 'ox_target' then
    function AddLocalEntity(entities, options)
        ox_target:addLocalEntity(entities, options)
    end

    return
end

if Cfg.Target == 'qb-target' then
    function AddLocalEntity(entities, options)
        for k, v in pairs(options) do
            options[k].action = v.onSelect
        end
        exports['qb-target']:AddTargetEntity(entities, {
            options = options,
            distance = 1.5
        })
    end

    return
end
