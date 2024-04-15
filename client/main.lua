local drugData = {}
local custy = {}
local inZone = false
local isBusy = false
local ox_target = exports.ox_target

local function setRoute(x, y, z)
    if x == nil then
        ClearGpsMultiRoute()
        RemoveBlip(MeetBlip)
    else
        MeetBlip = AddBlipForCoord(x, y, z)
        SetBlipSprite(MeetBlip, 143)
        SetBlipScale(MeetBlip, 0.7)
        SetBlipColour(MeetBlip, 2)
        SetBlipDisplay(MeetBlip, 2)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Meetup Location')
        EndTextCommandSetBlipName(MeetBlip)
        ClearGpsMultiRoute()
        StartGpsMultiRoute(18, true, true)
        AddPointToGpsMultiRoute(x, y, z)
        SetGpsMultiRouteRender(true)
    end
end

local function getNearbyPeds()
    local pedPool = GetGamePool("CPed")
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPed = nil
    local minDistance = Cfg.PoolDistance

    for i = 1, #pedPool do
        local ped = pedPool[i]
        local pedCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - pedCoords)
        local inCar = IsPedSittingInAnyVehicle(ped)
        local type = GetPedType(ped)

        if distance <= minDistance and distance > 5 and ped ~= custy.last and ped ~= playerPed and type ~= 28 and not inCar then
            minDistance = distance
            nearbyPed = ped
        end
    end

    return nearbyPed
end

local function getPaid(type)
    local player = PlayerPedId()
    local pCoords = GetEntityCoords(player)
    local cCoords = GetEntityCoords(custy.current)
    local coordData = { pCoords, cCoords }
    if type == 'bulk' then
        local qty = nil
        drugData.pay = math.random(Cfg.Drugs[drugData.drug].Bulk.Min, Cfg.Drugs[drugData.drug].Bulk.Max)
        if drugData.qty < Cfg.BulkSale.Max then
            qty = math.random(Cfg.BulkSale.Min, drugData.qty)
        else
            qty = math.random(Cfg.BulkSale.Min, Cfg.BulkSale.Max)
        end
        TriggerServerEvent('r_drugsales:rollOdds', true)
        TriggerServerEvent('r_drugsales:dataCheck', coordData, drugData, qty)
    elseif type == 'street' then
        local qty = nil
        drugData.pay = math.random(Cfg.Drugs[drugData.drug].Street.Min, Cfg.Drugs[drugData.drug].Street.Max)
        if drugData.qty < Cfg.StreetSale.Max then
            qty = math.random(Cfg.StreetSale.Min, drugData.qty)
        else
            qty = math.random(Cfg.StreetSale.Min, Cfg.StreetSale.Max)
        end
        TriggerServerEvent('r_drugsales:rollOdds', true)
        TriggerServerEvent('r_drugsales:dataCheck', coordData, drugData, qty)
        ClInvCheck()
    end
end

local function getRejected()
    PlayPedAmbientSpeechNative(custy.current, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
    if Cfg.NotifyPoliceOnReject then
        TriggerServerEvent('r_drugsales:rollOdds', false)
    end
    ClNotify('I don\'t want this bulls***!', 'error')
    TaskWanderStandard(custy.current, 10.0, 10)
    RemovePedElegantly(custy.current)
    SetModelAsNoLongerNeeded(bagModel)
    SetModelAsNoLongerNeeded(cashModel)
    ox_target:removeLocalEntity(custy.current)
    custy.last = custy.current
    custy.current = nil
end

local function streetSell()
    local dead = IsEntityDead(custy.current)
    local odds = math.random(100)
    if dead then
        ClNotify('You can\'t sell to a dead person.', 'error')
        DeleteEntity(custy.current)
        custy.last = custy.current
        custy.current = nil
        return
    end
    if odds < Cfg.RejectChance then
        getRejected()
        return
    end
    local player = PlayerPedId()
    local animDict1 = 'mp_common'
    local animDict2 = 'weapons@holster_fat_2h'
    local bagModel = joaat('prop_meth_bag_01')
    local cashModel = joaat('prop_anim_cash_note')
    lib.requestModel(bagModel, 100)
    lib.requestModel(cashModel, 100)
    lib.requestAnimDict(animDict1, 100)
    lib.requestAnimDict(animDict2, 100)
    local bag = CreateObject(bagModel, 0, 0, 0, true, false, false)
    local cash = CreateObject(cashModel, 0, 0, 0, true, false, false)
    AttachEntityToEntity(bag, player, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    AttachEntityToEntity(cash, custy.current, GetPedBoneIndex(custy.current, 28422), 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    TaskPlayAnim(player, animDict1, 'givetake1_a', 8.0, 8.0, -1, 32, 0.0, false, false, false)
    TaskPlayAnim(custy.current, animDict1, 'givetake1_a', 8.0, 8.0, -1, 32, 0.0, false, false, false)
    Wait(1500)
    AttachEntityToEntity(bag, custy.current, GetPedBoneIndex(custy.current, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    AttachEntityToEntity(cash, player, 90, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    TaskPlayAnim(player, animDict2, 'holster', 5.0, 1.5, 3000, 32, 0.0, false, false, false)
    TaskPlayAnim(custy.current, animDict2, 'holster', 5.0, 1.5, 3000, 32, 0.0, false, false, false)
    Wait(500)
    DeleteEntity(bag)
    DeleteEntity(cash)
    getPaid('street')
    Wait(100)
    PlayPedAmbientSpeechNative(custy.current, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
    TaskWanderStandard(custy.current, 10.0, 10)
    RemovePedElegantly(custy.current)
    SetModelAsNoLongerNeeded(bagModel)
    SetModelAsNoLongerNeeded(cashModel)
    ox_target:removeLocalEntity(custy.current)
    custy.last = custy.current
    custy.current = nil
end

local function poolStreetSale()
    local pZone = nil
    local player = PlayerPedId()
    local pCoords = GetEntityCoords(player)
    local forwardCoords = GetEntityForwardVector(player)
    if not ClInvCheck() then
        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        ClNotify('You don\'t have any drugs to sell.', 'error')
        ClearPedTasks(player)
        return
    end
    isBusy = true
    pZone = lib.zones.sphere({
        coords = pCoords,
        radius = 5,
        onExit = function()
            isBusy = false
            pZone:remove()
            if custy.current then
                RemovePedElegantly(custy.current)
                ox_target:removeLocalEntity(custy.current)
            end
            custy.current = nil
            ClNotify('Selling cancelled.', 'error')
            return
        end,
        debug = false
    })
    ClNotify('Stay here and wait for customers.', 'info')
    while isBusy do
        if custy.current and isBusy then
            pCoords = GetEntityCoords(player)
            local cCoords = GetEntityCoords(custy.current)
            local distance = #(pCoords - cCoords)
            while distance > 1.4 and custy.current do
                TaskGoToCoordAnyMeans(custy.current, pCoords.x + (forwardCoords.x * 1.3), pCoords.y + (forwardCoords.y * 1.3), pCoords.z, 1.2, 0, false, 786603, 0xbf800000)
                cCoords = GetEntityCoords(custy.current)
                pCoords = GetEntityCoords(player)
                distance = #(pCoords - cCoords)
                Wait(100)
            end
            while distance < 1.4 and custy.current do
                cCoords = GetEntityCoords(custy.current)
                pCoords = GetEntityCoords(player)
                distance = #(pCoords - cCoords)
                TaskStandStill(custy.current, 501)
                TaskTurnPedToFaceEntity(custy.current, player, -1)
                Wait(500)
            end
        end
        if not custy.current and ClInvCheck() then
            Wait(math.random(Cfg.PedFrequency.Min * 1000, Cfg.PedFrequency.Max * 1000))
            custy.current = getNearbyPeds()
            ox_target:addLocalEntity(custy.current, {
                {
                    label = 'Sell ' .. drugData.label .. '',
                    name = 'streetsale',
                    icon = 'fas fa-cannabis',
                    distance = 1.5,
                    onSelect = function()
                        TaskTurnPedToFaceEntity(player, custy.current, 500)
                        Wait(500)
                        streetSell()
                    end
                },
            })
        elseif not ClInvCheck() then
            isBusy = false
            pZone:remove()
            if custy.current then
                RemovePedElegantly(custy.current)
                ox_target:removeLocalEntity(custy.current)
            end
            custy.current = nil
            SetModelAsNoLongerNeeded(PedModel)
            ClNotify('You are out of drugs to sell.', 'info')
            return
        end
        Wait(1000)
    end
end


local function spawnStreetSale()
    local pZone = nil
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local heading = GetEntityHeading(player)
    local forwardCoords = GetEntityForwardVector(player)
    if not ClInvCheck() then
        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        ClNotify('You don\'t have any drugs to sell.', 'error')
        ClearPedTasks(player)
        return
    end
    isBusy = true
    pZone = lib.zones.sphere({
        coords = coords,
        radius = 5,
        onExit = function()
            isBusy = false
            pZone:remove()
            if custy.current then
                RemovePedElegantly(custy.current)
                ox_target:removeLocalEntity(custy.current)
            end
            custy.current = nil
            ClNotify('Selling cancelled.', 'error')
        end,
        debug = false
    })
    ClNotify('Stay here and wait for customers.', 'info')
    while isBusy do
        if custy.current and isBusy then
            TaskGoToEntity(custy.current, player, -1, 1.2, 1.0, 1073741824, 0)
            ClInvCheck()
        end
        if not custy.current and ClInvCheck() then
            PedModel = Cfg.StreetPeds[math.random(1, #Cfg.StreetPeds)]
            lib.requestModel(PedModel, 100)
            Wait(math.random(10000, 15000))
            if isBusy then
                custy.current = CreatePed(0, PedModel, coords.x + (forwardCoords.x * 20), coords.y + (forwardCoords.y * 20), coords.z, heading - 180.0, true, true)
                ox_target:addLocalEntity(custy.current, {
                    {
                        label = 'Sell ' .. drugData.label .. '',
                        name = 'streetsale',
                        icon = 'fas fa-cannabis',
                        distance = 1.0,
                        onSelect = function()
                            streetSell()
                        end
                    },
                })
            end
        elseif not ClInvCheck() then
            isBusy = false
            pZone:remove()
            if custy.current then
                RemovePedElegantly(custy.current)
                ox_target:removeLocalEntity(custy.current)
            end
            custy.current = nil
            SetModelAsNoLongerNeeded(PedModel)
            ClNotify('You are out of drugs to sell.', 'info')
            return
        end
        Wait(1000)
    end
end

local function bulkSell()
    local player = PlayerPedId()
    local animDict1 = 'mp_common'
    local animDict2 = 'weapons@holster_fat_2h'
    local bagModel = joaat('xm_prop_x17_bag_01d')
    local cashModel = joaat('prop_anim_cash_pile_01')
    lib.requestModel(bagModel, 100)
    lib.requestModel(cashModel, 100)
    lib.requestAnimDict(animDict1, 100)
    lib.requestAnimDict(animDict2, 100)
    local bag = CreateObject(bagModel, 0, 0, 0, true, false, false)
    local cash = CreateObject(cashModel, 0, 0, 0, true, false, false)
    AttachEntityToEntity(bag, player, GetPedBoneIndex(player, 28422), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    AttachEntityToEntity(cash, custy.current, GetPedBoneIndex(custy.current, 28422), 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
    TaskPlayAnim(player, animDict1, 'givetake1_a', 8.0, 8.0, -1, 32, 0.0, false, false, false)
    TaskPlayAnim(custy.current, animDict1, 'givetake1_a', 8.0, 8.0, -1, 32, 0.0, false, false, false)
    Wait(1500)
    AttachEntityToEntity(bag, custy.current, GetPedBoneIndex(custy.current, 28422), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    AttachEntityToEntity(cash, player, GetPedBoneIndex(player, 28422), 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
    TaskPlayAnim(player, animDict2, 'holster', 5.0, 1.5, 3000, 32, 0.0, false, false, false)
    TaskPlayAnim(custy.current, animDict2, 'holster', 5.0, 1.5, 3000, 32, 0.0, false, false, false)
    getPaid('bulk')
    Wait(500)
    AttachEntityToEntity(bag, custy.current, GetPedBoneIndex(custy.current, 60309), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    SetEntityInvincible(custy.current, false)
    FreezeEntityPosition(custy.current, false)
    RemovePedElegantly(custy.current)
    SetEntityAsNoLongerNeeded(bag)
    DeleteEntity(cash)
    ClearGpsMultiRoute()
    RemoveBlip(MeetBlip)
    custy.current = nil
    isBusy = false
    SetModelAsNoLongerNeeded(bagModel)
    SetModelAsNoLongerNeeded(cashModel)
    RemoveAnimDict(animDict1)
    RemoveAnimDict(animDict2)
end

local function bulkSale()
    local player = PlayerPedId()
    local pedModel = Cfg.BulkPeds[math.random(1, #Cfg.BulkPeds)]
    local phoneProp = 'prop_phone_ing'
    local animDict = 'cellphone@'
    if not ClInvCheck() or drugData.qty < Cfg.BulkSale.Min then
        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        ClNotify('You don\'t have enough drugs to sell.', 'error')
        ClearPedTasks(player)
        return
    end
    isBusy = true
    local meetup = Cfg.MeetupCoords[math.random(1, #Cfg.MeetupCoords)]
    lib.requestAnimDict(animDict, 100)
    lib.requestModel(pedModel, 100)
    lib.requestModel(phoneProp, 100)
    ClearPedTasksImmediately(player)
    local phone = CreateObject(phoneProp, 0, 0, 0, true, false, false)
    PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
    TaskPlayAnim(player, animDict, 'cellphone_call_listen_base', 8.0, 8.0, -1, 1, 0.0, false, false, false)
    AttachEntityToEntity(phone, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    Wait(5000)
    PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
    custy.current = CreatePed(0, pedModel, meetup.x, meetup.y, meetup.z, meetup.w, true, true)
    SetEntityInvincible(custy.current, true)
    FreezeEntityPosition(custy.current, true)
    SetBlockingOfNonTemporaryEvents(custy.current, true)
    ox_target:addLocalEntity(custy.current, {
        {
            label = 'Sell ' .. drugData.label .. '',
            name = 'bulksale',
            icon = 'fas fa-cannabis',
            distance = 1.0,
            onSelect = function()
                bulkSell()
            end
        },
    })
    setRoute(meetup.x, meetup.y, meetup.z)
    ClNotify('Check GPS for the meetup spot.', 'info')
    ClearPedTasks(player)
    DeleteEntity(phone)
    SetModelAsNoLongerNeeded(phoneProp)
    SetModelAsNoLongerNeeded(PedModel)
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
            PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
            ClearPedTasks(player)
        end,
        options = {
            {
                title = 'Street Sales',
                description = 'Sell to clients on the streets.',
                icon = 'joint',
                onSelect = function()
                    if not inZone then
                        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
                        ClNotify('You can only sell in the hood.', 'error')
                        ClearPedTasks(player)
                    else
                        PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
                        ClearPedTasks(player)
                        if Cfg.StreetSelling == 'spawn' then
                            spawnStreetSale()
                        elseif Cfg.StreetSelling == 'pool' then
                            poolStreetSale()
                        end
                    end
                end,
                metadata = {
                    { label = 'High Risk ', value = 'High Reward' }
                },
            },
            {
                title = 'Bulk Sale',
                description = 'Sell to a bulk buyer at a meetup.',
                icon = 'truck-ramp-box',
                onSelect = function()
                    bulkSale()
                end,
                metadata = {
                    { label = 'Low Risk ', value = 'Low Reward' }
                },
            },
        }
    })
    PlaySound(-1, 'Click_Special', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
    lib.showContext('dealermenu')
end

function GetData(drug, label, qty)
    if drug == nil then return end
    drugData.drug = drug
    drugData.label = label
    drugData.qty = qty
end

CreateThread(function()
    if Cfg.SellZone.Enabled then
        lib.zones.poly({
            points = Cfg.SellZone.ZoneCoords,
            thickness = 30,
            onEnter = function()
                inZone = true
            end,
            onExit = function()
                inZone = false
            end,
            debug = Cfg.SellZone.Debug
        })
    end
end)

RegisterNetEvent('r_drugsales:openDealerMenu')
AddEventHandler('r_drugsales:openDealerMenu', function()
    local cop = ClJobCheck()
    local copcount = lib.callback.await('r_drugsales:getCopsOnline', false)
    if cop then
        ClNotify('Nice try narc!', 'error')
        return
    end
    if isBusy then
        ClNotify('You are already selling!', 'error')
        return
    end
    if copcount < Cfg.MinPolice then
        ClNotify('There aren\'t enough police on duty!', 'error')
        return
    end
    OpenDealerMenu()
end)


if Cfg.Interaction == 'command' then
    RegisterCommand('dealer', function()
        TriggerEvent('r_drugsales:openDealerMenu')
    end, false)
end
