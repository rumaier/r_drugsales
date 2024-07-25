local entities = {}
local meetBlip = nil
local state = LocalPlayer.state
local saleStep = 0

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
    entities.bag = CreateProp(bagModel, GetEntityCoords(cache.ped), 0.0, false)
    AttachEntityToEntity(entities.bag, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    SetNPCFrozen(entities.customer, false, true, true)
    SetTimeout(500, function()
        entities.cash = CreateProp(cashModel, vec3(0, 0, 0), 0.0, false)
        AttachEntityToEntity(entities.cash, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        PlayAnim(cache.ped, animDict, animName, -1, 32, 0.0)
        PlayAnim(entities.customer, animDict, animName, -1, 32, 0.0)
        Wait(1500)
        AttachEntityToEntity(entities.bag, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.cash, cache.ped, 90, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        PlayAnim(cache.ped, animDict2, animName2, 1500, 32, 0.0)
        StopAnimTask(entities.customer, animDict, animName, 1.0)
        Wait(500)
        DeleteEntity(entities.cash)
        local paid, quantity, pay = lib.callback.await('r_drugsales:bulkSale', false, playerNetId, customerNetId, slot)
        if not paid then debug('[DEBUG] - Sale failed:', paid, quantity, pay) return CancelSelling() end
        Framework.notify(_L('sold_drugs', quantity, slot.label, pay * quantity), 'success')
        PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
        SetEntityAsNoLongerNeeded(entities.bag)
        TaskWanderStandard(entities.customer, 10.0, 10)
        RemovePedElegantly(entities.customer)
        debug('[DEBUG] - Sale successful:', quantity, slot.label, pay)
        saleStep = 0
    end)
end

local function setupBulkSale(slot, coords)
    saleStep = 2
    local pedModel = Cfg.Peds.bulkPeds[math.random(#Cfg.Peds.bulkPeds)]
    entities.customer = CreateNPC(pedModel, coords.xyz, coords.w, true)
    while not DoesEntityExist(entities.customer) do Wait(0) end
    SetNPCFrozen(entities.customer, true, true, true)
    Target.addLocalEntity(entities.customer, {
        {
            label = _L('sell_drug', slot.label),
            icon = 'fas fa-joint',
            onSelect = function()
                initiateBulkSale(slot)
                Target.removeLocalEntity(entities.customer)
            end
        }
    })
    debug('[DEBUG] - Bulk customer spawned:', entities.customer)
    while state.sellingDrugs and saleStep == 2 do
        local playerCoords = GetEntityCoords(cache.ped)
        local pedCoords = GetEntityCoords(entities.customer)
        local pedDistance = #(playerCoords - pedCoords)
        if pedDistance <= 5.0 then
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Hows_It_Going', 'Speech_Params_Force')
            SetGpsRoute(false, vec3(0, 0, 0), 1)
            RemoveBlip(meetBlip)
            debug('[DEBUG] - Ped approached meetup')
            break
        end
        Wait(100)
    end
end

local function startBulkSaleTimer()
    CreateThread(function()
        local timer = Cfg.Selling.bulkMeetTime * 60000
        local start = GetGameTimer()
        while state.sellingDrugs and saleStep > 0 do
            local elapsed = GetGameTimer() - start
            local remaining = timer - elapsed
            if remaining <= 0 then
                Framework.notify(_L('no_show'), 'error')
                return CancelSelling()
            end
            Wait(100)
        end
    end)
end

local function taskBulkSale(slot, coords)
    startBulkSaleTimer()
    meetBlip = CreateBlip(coords.xyz, 143, 0.7, 2, 2, _L('meetup_location'))
    SetGpsRoute(true, coords.xyz, 18)
    saleStep = 1
    while state.sellingDrugs and saleStep == 1 do
       local playerCoords = GetEntityCoords(cache.ped)
       local distance = #(playerCoords - coords.xyz)
       if distance <= 300 then return setupBulkSale(slot, coords) end
       Wait(100)
    end
end

local function initializeBulkSale()
    local playerInventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    for _, slot in pairs(playerInventory) do
        if Cfg.Selling.drugs[slot.name] then
            if slot.count >= Cfg.Selling.bulkQuantity[1] then
                PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
                PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_to_call', 500, 48, 0.0)
                Wait(500)
                PlayAnim(cache.ped, 'cellphone@', 'cellphone_call_listen_base', 5000, 48, 0.0)
                SetTimeout(5000, function()
                    local coords = Cfg.Selling.meetupCoords[math.random(#Cfg.Selling.meetupCoords)]
                    PlayAnim(cache.ped, 'cellphone@', 'cellphone_call_out', 1000, 17, 0.0)
                    PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
                    Framework.notify(_L('go_meet_customer'), 'info')
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
    PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
    Framework.notify(_L('not_enough_drugs'), 'error')
    return CloseDealerMenu()
end

local function retrieveDrugs(slot, quantity)
    local drugProp = 'prop_meth_bag_01'
    local animDict, animName = 'random@domestic', 'pickup_low'
    local animDict2, animName2 = 'weapons@holster_fat_2h', 'holster'
    local playerNetId = NetworkGetNetworkIdFromEntity(cache.ped)
    local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    SetTimeout(500, function()
        PlayAnim(cache.ped, animDict, animName, 1000, 32, 0.0)
        Wait(500)
        entities.drugs = CreateProp(drugProp, GetEntityCoords(entities.customer), 0.0, false)
        AttachEntityToEntity(entities.drugs, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        Wait(500)
        PlayAnim(cache.ped, animDict2, animName2, 500, 32, 0.0)
        DeleteEntity(entities.drugs)
        local retrieved = lib.callback.await('r_drugsales:retrieveDrugs', false, slot, quantity, playerNetId, customerNetId)
        if not retrieved then return CancelSelling() end
        Framework.notify(_L('retrieved_drugs', quantity, slot.label), 'success')
        if state.inSellZone then TaskStreetSale(slot) end
    end)
end

local function initiateRobbery(slot, quantity)
    SetPedAsEnemy(entities.customer, true)
    SetPedHasAiBlip(entities.customer, false)
    TaskSmartFleePed(entities.customer, cache.ped, 100.0, -1, false, false)
    Framework.notify(_L('robbed'), 'error')
    while state.sellingDrugs and saleStep == 3 do
        local isDead = IsEntityDead(entities.customer)
        local playerCoords = GetEntityCoords(cache.ped)
        local pedCoords = GetEntityCoords(entities.customer)
        local pedDistance = #(playerCoords - pedCoords)
        if pedDistance >= 50 then Framework.notify(_L('got_away'), 'error') return CancelSelling() end
        if isDead then break end
        Wait(100)
    end
    Target.addLocalEntity(entities.customer, {
        {
            label = _L('retrieve_drugs'),
            icon = 'fas fa-box',
            canInteract = function()
                return state.sellingDrugs
            end,
            onSelect = function()
                retrieveDrugs(slot, quantity)
                Target.removeLocalEntity(entities.customer)
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
    local customerDead = IsEntityDead(entities.customer)
    if customerDead then Framework.notify(_L('customer_dead'), 'error') return TaskStreetSale(slot) end
    local animDict, animName = 'mp_common', 'givetake1_a'
    local animDict2, animName2 = 'weapons@holster_fat_2h', 'holster'
    local drugProp, moneyProp = 'prop_meth_bag_01', 'prop_anim_cash_note'
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    SetTimeout(500, function()
        entities.drugs = CreateProp(drugProp, GetEntityCoords(cache.ped), 0.0, false)
        entities.money = CreateProp(moneyProp, GetEntityCoords(entities.customer), 0.0, false)
        AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.money, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        PlayAnim(cache.ped, animDict, animName, -1, 32, 0.0)
        PlayAnim(entities.customer, animDict, animName, -1, 32, 0.0)
        Wait(1500)
        AttachEntityToEntity(entities.drugs, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.money, cache.ped, 90, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        PlayAnim(cache.ped, animDict2, animName2, 500, 32, 0.0)
        PlayAnim(entities.customer, animDict2, animName2, 500, 32, 0.0)
        DeleteEntity(entities.drugs)
        DeleteEntity(entities.money)
        if not reject then
            local playerNetId = NetworkGetNetworkIdFromEntity(cache.ped)
            local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
            local paid, quantity, pay = lib.callback.await('r_drugsales:streetSale', false, playerNetId, customerNetId, slot)
            if not paid then return CancelSelling() end
            Framework.notify(_L('sold_drugs', quantity, slot.label, pay), 'success')
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
            TaskWanderStandard(entities.customer, 10.0, 10)
            RemovePedElegantly(entities.customer)
            debug('[DEBUG] - Sale successful:', quantity, slot.label, pay)
            saleStep = 0
            return TaskStreetSale(slot)
        end
        if reject and not robbery then
            local roll = math.random(1, 100)
            if roll <= Cfg.Dispatch.reportOdds then TriggerPoliceDispatch() end
            Framework.notify(_L('rejected_sale'), 'error')
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Insult_High', 'Speech_Params_Force')
            TaskWanderStandard(entities.customer, 10.0, 10)
            RemovePedElegantly(entities.customer)
            debug('[DEBUG] - Sale rejected:', slot.label)
            return TaskStreetSale(slot)
        end
        if reject and robbery then
            local robbed, quantity = lib.callback.await('r_drugsales:robPlayer', false, slot)
            if not robbed then return CancelSelling() end
            initiateRobbery(slot, quantity)
            debug('[DEBUG] - Robbery initiated:', slot.label)
        end
    end)
end

local function setupStreetSale(slot)
    Target.addLocalEntity(entities.customer, {
        {
            label = _L('sell_drug', slot.label),
            icon = 'fas fa-joint',
            onSelect = function()
                initiateStreetSale(slot)
                Target.removeLocalEntity(entities.customer)
            end
        }
    })
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    saleStep = 2
    debug('[DEBUG] - Ped approached player')
    while state.sellingDrugs and saleStep == 2 do
        local playerCoords = GetEntityCoords(cache.ped)
        local pedCoords = GetEntityCoords(entities.customer)
        local pedDistance = #(playerCoords - pedCoords)
        TaskStandStill(entities.customer, 1000)
        if pedDistance >= 20 then Framework.notify(_L('too_far'), 'error') return CancelSelling() end
        Wait(100)
    end
end

function TaskStreetSale(slot)
    local wait = math.random(table.unpack(Cfg.Selling.pedFrequency)) * 1000
    local startCoords = GetEntityCoords(cache.ped)
    local customerModel = Cfg.Peds.streetPeds[math.random(#Cfg.Peds.streetPeds)]
    local customerCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 25.0, 0.0)
    local customerHeading = GetEntityHeading(cache.ped) - 180.0
    local type = Cfg.Selling.streetSales
    SetTimeout(wait, function()
        if not state.sellingDrugs then return end
        if type == 'pool' then entities.customer = GetNearbyPed() SetEntityAsMissionEntity(entities.customer, true, true) end
        if type == 'spawn' then entities.customer = CreateNPC(customerModel, customerCoords, customerHeading, true) end
        while not DoesEntityExist(entities.customer) do Wait(0) end
        saleStep = 1
        debug('[DEBUG] - Customer ready, tasking to player', entities.customer)
        while state.sellingDrugs and saleStep == 1 do
            local playerCoords = GetEntityCoords(cache.ped)
            local pedCoords = GetEntityCoords(entities.customer)
            local pedDistance = #(playerCoords - pedCoords)
            local startDistance = #(playerCoords - startCoords)
            TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, 1.4, 1073741824, 0)
            if startDistance >= 20.0 then Framework.notify(_L('too_far'), 'error') return CancelSelling() end
            if pedDistance <= 2.0 then return setupStreetSale(slot) end
            Wait(100)
        end
    end)
end

local function initializeStreetSelling()
    if IsPedInAnyVehicle(cache.ped, false) then Framework.notify(_L('no_vehicle'), 'error') return CloseDealerMenu() end
    if not state.inSellZone then
        PlaySound(-1, 'Click_Fail', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        Framework.notify(_L('no_zone'), 'error') 
        return CloseDealerMenu()
    end
    local playerInventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    for _, slot in pairs(playerInventory) do
        if Cfg.Selling.drugs[slot.name] then
            PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)
            Framework.notify(_L('wait_for_customer'), 'info')
            state.sellingDrugs = true
            debug('[DEBUG] - Selling drugs:', json.encode(slot, { indent = true }))
            CloseDealerMenu()
            return TaskStreetSale(slot)
        end
    end
end

local function openDealerMenu()
    local phoneProp = 'prop_prologue_phone'
    entities.phone = CreateProp(phoneProp, GetPedBoneCoords(cache.ped, 28422, 0.0, 0.0, 0.0), true)
    AttachEntityToEntity(entities.phone, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_in', 750, 17, 0.0)
    SetTimeout(750, function()
        PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_read_base', -1, 17, 0.0)
        PlaySound(-1, 'Click_Special', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
        lib.showContext('dealermenu')
    end)
end

local function initializeDealerMenu()
    local isCop = lib.callback.await('r_drugsales:checkIfPolice', false)
    local copCount = lib.callback.await('r_drugsales:getPoliceOnline', false)
    if state.sellingDrugs then return Framework.notify(_L('already_selling'), 'error') end
    if isCop then return Framework.notify(_L('no_narcs'), 'error') end
    if copCount < Cfg.Selling.minPolice then return Framework.notify(_L('no_police'), 'error') end
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

function CloseDealerMenu()
    PlaySound(-1, 'CLICK_BACK', 'WEB_NAVIGATION_SOUNDS_PHONE', false, 0, true)
    PlayAnim(cache.ped, 'cellphone@', 'cellphone_text_out', 750, 17, 0.0)
    SetTimeout(750, function()
        DeleteEntity(entities.phone)
    end)
    debug('[DEBUG] - Dealer menu closed')
end

function CancelSelling()
    state.sellingDrugs = false
    RemovePedElegantly(entities.customer)
    Target.removeLocalEntity(entities.customer)
    entities.customer = nil
    saleStep = 0
    SetGpsRoute(false, vec3(0, 0, 0), 1)
    RemoveBlip(meetBlip)
end

function GetNearbyPed()
    local pedPool = GetGamePool('CPed')
    local playerCoords = GetEntityCoords(cache.ped)
    local maxDistance = Cfg.Selling.poolDistance
    local nearbyPed = nil
    for i = 1, #pedPool do
        local ped = pedPool[i]
        local pedCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - pedCoords)
        local inCar, isDead, type = IsPedInAnyVehicle(ped, false), IsEntityDead(ped), GetPedType(ped)
        if distance <= maxDistance and ped ~= cache.ped and ped ~= entities.customer and not inCar and not isDead and type ~= 28 then
            maxDistance = distance
            nearbyPed = ped
        end
    end
    debug('[DEBUG] - nearby ped found:', nearbyPed)
    return nearbyPed
end

RegisterNetEvent('r_drugsales:openDealerMenu', function()
    initializeDealerMenu()
end)

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
                debug = Cfg.Debug.zones
            })
        end
    else state.inSellZone = true end 
end)

---@param display integer -- [2: Map and minimap] [4: Only map]
function CreateBlip(coords, sprite, scale, color, display, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipDisplay(blip, display)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

---@param color integer -- [1: White] [2: Black] [6: Red] [9: Light Blue] [12: Yellow] [21: Purple] [25: Green] [30: Pink]
function SetGpsRoute(render, coords, color)
    if not render then return ClearGpsMultiRoute() end
    ClearGpsMultiRoute()
    StartGpsMultiRoute(color, true, true)
    AddPointToGpsMultiRoute(coords.x, coords.y, coords.z)
    SetGpsMultiRouteRender(true)
end

function CreateProp(model, coords, heading, isNetwork)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local entity = CreateObject(model, coords.x, coords.y, coords.z, isNetwork, false, false)
    SetEntityHeading(entity, heading)
    SetModelAsNoLongerNeeded(model)
    return entity
end

function CreateNPC(model, coords, heading, isNetwork)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z, heading, isNetwork, false)
    SetModelAsNoLongerNeeded(model)
    return ped
end

function SetNPCFrozen(entity, freeze, invincible, oblivious)
    FreezeEntityPosition(entity, freeze)
    SetEntityInvincible(entity, invincible)
    SetBlockingOfNonTemporaryEvents(entity, oblivious)
end

function PlayAnim(ped, dict, anim, duration, flag, playbackRate)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(ped, dict, anim, 8.0, 8.0, duration, flag, playbackRate, false, false, false)
end

function debug(...)
    if Cfg.Debug.prints then
        print(...)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CancelSelling()
        state.inSellZone = false
    end
end)