if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports["es_extended"]:getSharedObject()

function ClNotify(msg, type)
    if Cfg.Notification == 'default' then
        ESX.ShowNotification(msg, type)
    elseif Cfg.Notification == 'ox' then
        lib.notify({ description = msg, type = type, position = 'top' })
    elseif Cfg.Notification == 'custom' then
        -- Insert your notification system here
    end
end

function ClInvCheck()
    local data = {}
    for k, v in pairs(Cfg.Drugs) do
        Item = ESX.SearchInventory(k)
        -- print(json.encode(Item))
        data.item = Item.name
        print(data.item)
    end
end
