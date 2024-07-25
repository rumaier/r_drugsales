if GetResourceState('qb-target') ~= 'started' or GetResourceState('ox_target') == 'started' then return end

Core.Target = 'qb-target'