local sSelling = false
local bSelling = false
local pZone = nil

function StreetSale()

end

function BulkSale()
    local player = PlayerPedId()
    local animDict = 'cellphone@'
    lib.requestAnimDict(animDict, 100)
    ClearPedTasksImmediately(player)
    TaskPlayAnim(player, animDict, 'cellphone_call_listen_base', 8.0, 8.0, -1, 1, 0.0, false, false, false)
end

function OpenDealerMenu()
    local player = PlayerPedId()
    ClearPedTasks(player)
    TaskStartScenarioInPlace(player, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    Wait(3500)
    lib.registerContext({
        id = 'dealermenu',
        title = 'Dealer Menu',
        onExit = function()
            ClearPedTasks(player)
        end,
        options = {
            {
                title = 'Street Sales',
                description = 'Sell to clients on the streets.',
                icon = 'joint',
                onSelect = function()
                    ClearPedTasks(player)
                end,
                metadata = {
                    {label = 'High Risk ', value = 'High Reward'}
                  },
            },
            {
                title = 'Bulk Sale',
                description = 'Sell to a bulk buyer at a meetup.',
                icon = 'truck-ramp-box',
                onSelect = function()
                    PlaySound(-1, 'Put_Away', 'Phone_SoundSet_Michael', false, 0, true)
                    BulkSale()
                end,
                metadata = {
                    {label = 'Low Risk ', value = 'Low Reward'}
                  },
            },
        }
    })
    lib.showContext('dealermenu')
end

RegisterCommand('dealer', function()
    OpenDealerMenu()
end, false)

RegisterCommand('debug', function()
    ClInvCheck()
end, false) 
