local entities = {}
local meetBlip = nil
local saleStep = 0

local state = LocalPlayer.state

lib.callback.register('r_drugsales:getSaleStep', function()
    return saleStep
end)

local function initiateBulkSale(slot)
    saleStep = 3
    local bagModel, cashModel = 'xm_prop_x17_bag_01d', 'prop_anim_cash_pile_01'
    local animDict, animName = 'mp_common', 'givetake1_a'
    local animDict2, animName2 = 'weapons@holster_fat_2h', 'holster'
    local playerNetId = NetworkGetNetworkIdFromEntity(cache.ped)
    local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
    entities.bag = Core.Natives.CreateProp(bagModel, GetEntityCoords(cache.ped), 0.0, true)
    AttachEntityToEntity(entities.bag, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    Core.Natives.SetEntityProperties(entities.customer, false, true, true)
    SetTimeout(500, function()
        entities.cash = Core.Natives.CreateProp(cashModel, vec3(0, 0, 0), 0.0, false)
        AttachEntityToEntity(entities.cash, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        Core.Natives.PlayAnim(cache.ped, animDict, animName, -1, 32, 0.0)
        Core.Natives.PlayAnim(entities.customer, animDict, animName, -1, 32, 0.0)
        Wait(1500)
        AttachEntityToEntity(entities.bag, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.cash, cache.ped, 90, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        Core.Natives.PlayAnim(cache.ped, animDict2, animName2, 1500, 32, 0.0)
        StopAnimTask(entities.customer, animDict, animName, 1.0)
        Wait(500)
        DeleteEntity(entities.cash)
        local paid, quantity, pay = lib.callback.await('r_drugsales:bulkSale', false, playerNetId, customerNetId, slot)
        if not paid then debug('[DEBUG] - Sale failed:', paid, quantity, pay) return CancelSelling() end
        Core.Framework.Notify(_L('sold_drugs', quantity, slot.label, pay * quantity), 'success')
        PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
        SetEntityAsNoLongerNeeded(entities.bag)
        TaskWanderStandard(entities.customer, 10.0, 10)
        RemovePedElegantly(entities.customer)
        debug('[DEBUG] - Sale successful:', quantity, slot.label, pay)
        state.sellingDrugs = false
        saleStep = 0
    end)
end

local function setupBulkSale(slot, coords)
    saleStep = 2
    local pedModel = Cfg.Peds.bulkPeds[math.random(#Cfg.Peds.bulkPeds)]
    entities.customer = Core.Natives.CreateNpc(pedModel, coords.xyz, coords.w, true)
    while not DoesEntityExist(entities.customer) do Wait(100) end
    Core.Natives.SetEntityProperties(entities.customer, true, true, true)
    Core.Target.AddLocalEntity(entities.customer, {
        {
            label = _L('sell_drug', slot.label),
            icon = 'fas fa-joint',
            onSelect = function()
                Core.Target.RemoveLocalEntity(entities.customer)
                initiateBulkSale(slot)
            end
        }
    })
    debug('[DEBUG] - Bulk customer spawned', entities.customer)
    while state.sellingDrugs and saleStep == 2 do
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        local distance = #(pCoords - cCoords)
        if distance <= 5.0 then
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Hows_It_Going', 'Speech_Params_Force')
            Core.Natives.SetGpsRoute(false)
            RemoveBlip(meetBlip)
            debug('[DEBUG] - Player approached meetup')
            break
        end
        Wait(100)
    end
end

local function startBulkSaleTimer()
    CreateThread(function()
        local timer = Cfg.Selling.bulkMeetTime * 60000
        local startTime = GetGameTimer()
        while state.sellingDrugs and saleStep > 0 do
            local elapsedTime = GetGameTimer() - startTime
            local remainingTime = timer - elapsedTime
            if remainingTime <= 0 then
                Core.Framework.Notify(_L('no_show'), 'error')
                CancelSelling()
                return
            end
            Wait(100)
        end
    end)
end

local function taskBulkSale(slot, coords)
    startBulkSaleTimer()
    meetBlip = Core.Natives.CreateBlip(coords.xyz, 143, 2, 0.7, _L('meetup_location'), false)
    Core.Natives.SetGpsRoute(true, coords.xyz, 18)
    saleStep = 1
    while state.sellingDrugs and saleStep == 1 do
        local pCoords = GetEntityCoords(cache.ped)
        local distance = #(pCoords - coords.xyz)
        if distance <= 300 then return setupBulkSale(slot, coords) end
        Wait(100)
    end
end

local function initializeBulkSale()
    local playerItems = lib.callback.await('r_drugsales:getPlayerItems', false)
    for _, slot in pairs(playerItems) do
        if Cfg.Selling.drugs[slot.name] then
            PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
            Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_to_call', 500, 48, 0.0)
            Wait(500)
            Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_call_listen_base', 5000, 48, 0.0)
            SetTimeout(5000, function()
                local coords = Cfg.Selling.meetupCoords[math.random(#Cfg.Selling.meetupCoords)]
                Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_call_out', 1000, 17, 0.0)
                PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
                Core.Framework.Notify(_L('go_meet_customer'), 'info')
                state.sellingDrugs = true
                SetTimeout(750, function()
                    DeleteEntity(entities.phone)
                end)
                taskBulkSale(slot, coords)
                debug('[DEBUG] - Bulk Selling:', coords, json.encode(slot, { indent = true }))
            end)
            return
        end
    end
end

local function retrieveDrugs(slot, quantity)
    local drugProp = 'prop_meth_bag_01'
    local animDict, animName = 'pickup_object', 'pickup_low'
    local animDict2, animName2 = 'weapons@holster_fat_2h', 'holster'
    local playerNetId = NetworkGetNetworkIdFromEntity(cache.ped)
    local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    SetTimeout(500, function()
        Core.Natives.PlayAnim(cache.ped, animDict, animName, 1000, 32, 0.0)
        Wait(500)
        entities.drugs = Core.Natives.CreateProp(drugProp, GetEntityCoords(entities.customer), 0.0, false)
        AttachEntityToEntity(entities.drugs, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        Wait(500)
        Core.Natives.PlayAnim(cache.ped, animDict2, animName2, 500, 32, 0.0)
        DeleteEntity(entities.drugs)
        local retrieved = lib.callback.await('r_drugsales:retrieveDrugs', false, slot, quantity, playerNetId, customerNetId)
        if not retrieved then return CancelSelling() end
        Core.Framework.Notify(_L('retrieved_drugs', quantity, slot.label), 'success')
        if state.inSellZone then TaskStreetSale(slot) end
    end)
end

local function initiateRobbery(slot, quantity)
    SetPedAsEnemy(entities.customer, true)
    SetPedHasAiBlip(entities.customer, true)
    TaskSmartFleePed(entities.customer, cache.ped, 100.0, -1, false, false)
    Core.Framework.Notify(_L('robbed'), 'error')
    while state.sellingDrugs and saleStep == 3 do
        local isDead = IsEntityDead(entities.customer)
        local playerCoords = GetEntityCoords(cache.ped)
        local pedCoords = GetEntityCoords(entities.customer)
        local pedDistance = #(playerCoords - pedCoords)
        if pedDistance >= 50 then Core.Framework.Notify(_L('got_away'), 'error') return CancelSelling() end
        if isDead then break end
        Wait(100)
    end
    Core.Target.AddLocalEntity(entities.customer, {
        {
            label = _L('retrieve_drugs'),
            icon = 'fas fa-box',
            canInteract = function()
                return state.sellingDrugs
            end,
            onSelect = function()
                retrieveDrugs(slot, quantity)
                Core.Target.RemoveLocalEntity(entities.customer)
            end
        }
    })
end

local function initiateStreetSale(slot)
    saleStep = 3
    local roll = math.random(1, 100)
    local reject = roll <= Cfg.Selling.rejectChance
    local robbery = false
    if reject then robbery = math.random(1, 100) <= Cfg.Selling.robberyChance end
    local isDead = IsEntityDead(entities.customer)
    if isDead then Core.Framework.Notify(_L('customer_dead'), 'error') return TaskStreetSale(slot) end
    local animDict, animName = 'mp_common', 'givetake1_a'
    local animDict2, animName2 = 'weapons@holster_fat_2h', 'holster'
    local drugProp, moneyProp = 'prop_meth_bag_01', 'prop_anim_cash_note'
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    SetTimeout(500, function()
        entities.drugs = Core.Natives.CreateProp(drugProp, GetEntityCoords(cache.ped), 0.0, true)
        entities.money = Core.Natives.CreateProp(moneyProp, GetEntityCoords(entities.customer), 0.0, true)
        AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.money, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        Core.Natives.PlayAnim(cache.ped, animDict, animName, -1, 32, 0.0)
        Core.Natives.PlayAnim(entities.customer, animDict, animName, -1, 32, 0.0)
        Wait(1500)
        AttachEntityToEntity(entities.drugs, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.money, cache.ped, 90, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        Core.Natives.PlayAnim(cache.ped, animDict2, animName2, 500, 32, 0.0)
        Core.Natives.PlayAnim(entities.customer, animDict2, animName2, 500, 32, 0.0)
        DeleteEntity(entities.drugs)
        DeleteEntity(entities.money)
        if not reject then
            local playerNetId = NetworkGetNetworkIdFromEntity(cache.ped)
            local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
            local paid, quantity, pay = lib.callback.await('r_drugsales:streetSale', false, playerNetId, customerNetId, slot)
            if not paid then return CancelSelling() end
            Core.Framework.Notify(_L('sold_drugs', quantity, slot.label, pay * quantity), 'success')
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
            TaskWanderStandard(entities.customer, 10.0, 10)
            RemovePedElegantly(entities.customer)
            debug('[DEBUG] - Sale successful:', quantity, slot.label, pay)
            saleStep = 0
            return TaskStreetSale(slot)
        elseif reject and not robbery then
            local roll = math.random(1, 100)
            if roll <= Cfg.Dispatch.reportOdds then Core.Dispatch.TriggerDispatch(Cfg.Dispatch.policeJobs) end
            Core.Framework.Notify(_L('rejected_sale'), 'error')
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Insult_High', 'Speech_Params_Force')
            TaskWanderStandard(entities.customer, 10.0, 10)
            RemovePedElegantly(entities.customer)
            debug('[DEBUG] - Sale rejected:', slot.label)
            return TaskStreetSale(slot)
        elseif reject and robbery then
            local robbed, quantity = lib.callback.await('r_drugsales:robPlayer', false, slot)
            if not robbed then return CancelSelling() end
            debug('[DEBUG] - Robbery initiated:', slot.label)
            initiateRobbery(slot, quantity)
        end
    end)
end

local function setupStreetSale(slot)
    Core.Target.AddLocalEntity(entities.customer, {
        {
            label = _L('sell_drug', slot.label),
            icon = 'fas fa-joint',
            iconColor = 'white',
            onSelect = function()
                Core.Target.RemoveLocalEntity(entities.customer)
                initiateStreetSale(slot)
            end
        }
    })
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    saleStep = 2
    debug('[DEBUG] - Customer ready to buy, waiting for player to sell')
    while state.sellingDrugs and saleStep == 2 do
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        local cDistance = #(pCoords - cCoords)
        TaskStandStill(entities.customer, 1000)
        if cDistance >= 20.0 then Core.Framework.Notify(_L('too_far'), 'error') return CancelSelling() end
        Wait(100)
    end
end

function TaskStreetSale(slot)
    local type = Cfg.Selling.streetSales
    local wait = math.random(table.unpack(Cfg.Selling.pedFrequency)) * 1000
    local startCoords = GetEntityCoords(cache.ped)
    local customerModel = Cfg.Peds.streetPeds[math.random(#Cfg.Peds.streetPeds)]
    local customerCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 25.0, 0.0)
    local customerHeading = GetEntityHeading(cache.ped) + 180.0
    SetTimeout(wait, function()
        if not state.sellingDrugs then return end
        if type == 'pool' then 
            entities.customer = GetNearbyPed() 
            while not entities.customer do Wait(100) end
            SetEntityAsMissionEntity(entities.customer, true, true)
        elseif type == 'spawn' then
            entities.customer = Core.Natives.CreateNpc(customerModel, customerCoords, customerHeading, true)
        end
        while not DoesEntityExist(entities.customer) do Wait(100) end
        saleStep = 1
        debug('[DEBUG] - Customer ready, tasking to player', entities.customer)
        while state.sellingDrugs and saleStep == 1 do
            local pCoords = GetEntityCoords(cache.ped)
            local cCoords = GetEntityCoords(entities.customer)
            local cDistance = #(pCoords - cCoords)
            local sDistance = #(pCoords - startCoords)
            TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, 1.4, 1073741824, 0)
            if sDistance >= 20.0 then Core.Framework.Notify(_L('too_far'), 'error') return CancelSelling() end
            if cDistance <= 2.0 then setupStreetSale(slot) return end
            Wait(100)
        end
    end)
end

local function initializeStreetSelling()
    if IsPedInAnyVehicle(cache.ped, false) then Core.Framework.Notify(_L('no_vehicle'), 'error') return CloseDealerMenu() end
    if not state.inSellZone then
        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        Core.Framework.Notify(_L('no_zone'), 'error') 
        return CloseDealerMenu()
    end
    local playerItems = lib.callback.await('r_drugsales:getPlayerItems', false)
    for _, slot in pairs(playerItems) do
        if Cfg.Selling.drugs[slot.name] then
            PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
            Core.Framework.Notify(_L('wait_for_customer'), 'info')
            state.sellingDrugs = true
            debug('[DEBUG] - Selling drugs:', json.encode(slot, { indent = true }))
            CloseDealerMenu()
            return TaskStreetSale(slot)
        end
    end
end

local function openDealerMenu() 
    entities.phone = Core.Natives.CreateProp('prop_prologue_phone', vec3(0, 0, 0), 0, true)
    while not DoesEntityExist(entities.phone) do print('spawning phone') Wait(100) end
    AttachEntityToEntity(entities.phone, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_in', 750, 17, 0.0)
    SetTimeout(750, function()
        Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_read_base', -1, 17, 0.0)
        PlaySound(-1, 'Click_Special', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        lib.showContext('dealermenu')
    end)
end

local function initializeDealerMenu()
    local isCop = lib.callback.await('r_drugsales:checkIfPolice', false)
    local copCount = lib.callback.await('r_drugsales:getPoliceOnline', false)
    if isCop then Core.Framework.Notify(_L('no_narcs'), 'error') return end
    if state.sellingDrugs then Core.Framework.Notify(_L('already_selling'), 'error') return end
    if copCount < Cfg.Selling.minPolice then Core.Framework.Notify(_L('no_police'), 'error') return end
    lib.registerContext({
        id = 'dealermenu',
        title = _L('dealer_menu'),
        onExit = CloseDealerMenu,
        options = {
            {
                title = _L('street_sales'),
                description = _L('street_sales_desc'),
                icon = 'fas fa-joint',
                onSelect = function()
                    initializeStreetSelling()
                end
            },
            {
                title = _L('bulk_sales'),
                description = _L('bulk_sales_desc'),
                icon = 'fas fa-box',
                onSelect = function()
                    initializeBulkSale()
                end
            }
        }
    })
    debug('[DEBUG] - Dealer menu built, opening menu')
    openDealerMenu()
end

RegisterNetEvent('r_drugsales:openDealerMenu', function()
    initializeDealerMenu()
end)

function CloseDealerMenu()
    PlaySound(-1, 'CLICK_BACK', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
    Core.Natives.PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_out', 750, 17, 0.0)
    SetTimeout(750, function()
        DeleteEntity(entities.phone)
    end)
    debug('[DEBUG] - Dealer menu closed')
end

function CancelSelling()
    state.sellingDrugs = false
    RemovePedElegantly(entities.customer)
    Core.Target.RemoveLocalEntity(entities.customer)
    entities.customer = nil
    saleStep = 0
    Core.Natives.SetGpsRoute(false)
    RemoveBlip(meetBlip)
end

function GetNearbyPed()
    local pedPool = GetGamePool('CPed')
    local pCoords = GetEntityCoords(cache.ped)
    local maxDistance = Cfg.Selling.poolDistance
    local nearbyPed = nil
    for i = 1, #pedPool do
        local ped = pedPool[i]
        local pedCoords = GetEntityCoords(ped)
        local distance = #(pCoords - pedCoords)
        local inCar, isDead, type = IsPedInAnyVehicle(ped, false), IsEntityDead(ped), GetPedType(ped)
        if distance <= maxDistance and ped ~= cache.ped and ped ~= entities.customer and not inCar and not isDead and type ~= 28 then
            nearbyPed = ped
            break
        end
    end
    debug('[DEBUG] - Nearby ped: ' .. tostring(nearbyPed))
    return nearbyPed
end

CreateThread(function()
    if Cfg.Zones.enabled then
        for _, coords in pairs(Cfg.Zones.zoneCoords) do
            lib.zones.poly({
                points = coords,
                thickness = 50,
                onEnter = function()
                    state.inSellZone = true
                    debug('[DEBUG] - Entered sell zone')
                end,
                onExit = function()
                    state.inSellZone = false
                    debug('[DEBUG] - Exited sell zone')
                end,
                debug = Cfg.Debug
            })
        end
    else state.inSellZone = true end 
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CancelSelling()
        state.inSellZone = false
        for _, entity in pairs(entities) do
            if DoesEntityExist(entity) then DeleteEntity(entity) end
        end
    end
end)