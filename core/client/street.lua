local zones = {}
local isSelling = false
local inZone = not Cfg.Options.ZonesEnabled
local entities = {}

function IsStreetSelling()
    return isSelling
end

local function taskExchangeAnimation(robbery)
    local customerRightHand = GetPedBoneIndex(entities.customer, 28422)
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    entities.drugProp = Core.Natives.createObject('prop_meth_bag_01', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.drugProp, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    if not robbery then
        entities.moneyProp = Core.Natives.createObject('prop_anim_cash_note', vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(entities.moneyProp, entities.customer, customerRightHand, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    end
    Core.Natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Core.Natives.playAnimation(entities.customer, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Wait(1500)
    AttachEntityToEntity(entities.drugProp, entities.customer, customerRightHand, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    if not robbery then
        AttachEntityToEntity(entities.moneyProp, cache.ped, 90, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        Core.Natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', 500, 16, 0.0)
        DeleteEntity(entities.moneyProp)
    end
    Core.Natives.playAnimation(entities.customer, 'weapons@holster_fat_2h', 'holster', 500, 16, 0.0)
    DeleteEntity(entities.drugProp)
end

local function cancelSelling()
    isSelling = false
    if not entities.customer or not DoesEntityExist(entities.customer) then return end
    TaskWanderStandard(entities.customer, 10.0, 10)
    RemovePedElegantly(entities.customer)
    Core.Target.removeLocalEntity(entities.customer)
    entities.customer = nil
end

local function retrieveStolenDrugs()
    Core.Target.removeLocalEntity(entities.customer)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
    SetTimeout(500, function()
        Core.Natives.playAnimation(cache.ped, 'pickup_object', 'pickup_low', 1000, 0, 0.0)
        Wait(500)
        entities.drugProp = Core.Natives.createObject('prop_meth_bag_01', vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(entities.drugs, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        Wait(500)
        Core.Natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', 500, 16, 0.0)
        DeleteEntity(entities.drugProp)
        local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
        local success = lib.callback.await('r_drugsales:retrieveStolenDrugs', false, customerNetId)
        if success then
            Core.Interface.notify(_L('notify_title'), _L('robber_caught'), 'success')
            RemovePedElegantly(entities.customer)
            entities.customer = nil
            InitializeStreetSale()
        else
            _debug('[^1ERROR^0] - Retrieving stolen drugs failed, check server console for details')
            cancelSelling()
        end
    end)
end

local function taskCustomerFlee()
    SetPedAsEnemy(entities.customer, true)
    SetPedHasAiBlip(entities.customer, true)
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Insult_High', 'Speech_Params_Force')
    TaskSmartFleePed(entities.customer, cache.ped, 100.0, -1, false, false)
    local distance = 0
    local robberDead = false
    repeat
        Wait(100)
        local playerCoords = GetEntityCoords(cache.ped)
        local customerCoords = GetEntityCoords(entities.customer)
        distance = #(playerCoords - customerCoords)
        robberDead = IsEntityDead(entities.customer)
    until distance > 50 or robberDead
    if distance > 50 then
        Core.Interface.notify(_L('notify_title'), _L('robber_escaped'), 'error')
        RemovePedElegantly(entities.customer)
        entities.customer = nil
    elseif robberDead then
        Core.Target.addLocalEntity(entities.customer, {
            {
                label = _L('robbery_target'),
                icon = 'fas fa-cannabis',
                onSelect = retrieveStolenDrugs,
                canInteract = function()
                    return IsEntityDead(entities.customer)
                end
            }
        })
    end
end

local function triggerRobbery(offer)
    _debug('[^6DEBUG^0] - Sale turned into a robbery')
    taskExchangeAnimation(true)
    local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:processRobbery', false, customerNetId, offer)
    if success then
        Core.Interface.notify(_L('notify_title'), _L('sale_robbed'), 'error')
        taskCustomerFlee()
    else
        _debug('[^1ERROR^0] - Robbery processing failed, check server console for details')
        cancelSelling()
    end
end

local function triggerAcceptedSale(offer)
    _debug('[^6DEBUG^0] - Sale accepted by customer')
    taskExchangeAnimation()
    local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:processStreetSale', false, customerNetId, offer)
    if success then
        Core.Interface.notify(_L('notify_title'), _L('sale_finished', offer.amount, offer.drug, offer.price), 'success')
    else
        _debug('[^1ERROR^0] - Sale processing failed, check server console for details')
        cancelSelling()
    end
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
    TaskWanderStandard(entities.customer, 10.0, 10)
    RemovePedElegantly(entities.customer)
    entities.customer = nil
    InitializeStreetSale()
end

local function triggerDeniedSale()
    Core.Interface.notify(_L('notify_title'), _L('sale_denied'), 'error')
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Insult_High', 'Speech_Params_Force')
    TaskWanderStandard(entities.customer, 10.0, 10)
    RemovePedElegantly(entities.customer)
    local reportRoll = math.random()
    _debug('[^6DEBUG^0] - report roll:', reportRoll, 'Report odds:', (Cfg.Options.ReportOdds / 100))
    if reportRoll <= (Cfg.Options.ReportOdds / 100) then TriggerDispatch() end
    InitializeStreetSale()
end

local function getOfferAcceptChance(offer)
    local offerPer = math.floor(offer.price / offer.amount)
    local maxPricePer = Cfg.Options.DrugItems[offer.drug].street.maxPricePer
    return math.floor(((maxPricePer - offerPer + 1) / maxPricePer) * 100)
end

local function rollRobbery()
    local chance = Cfg.Options.RobberyChance / 100 or 0.0
    if chance <= 0 then return false end
    local roll = math.random()
    _debug('[^6DEBUG^0] - Robbery chance:', chance, 'Roll:', roll)
    return roll <= chance
end

local function triggerOfferDrugs(offer)
    local roll = math.random()
    local acceptChance = getOfferAcceptChance(offer) / 100
    _debug('[^6DEBUG^0] - Offer accept chance:', acceptChance, 'Roll:', roll)
    if roll <= acceptChance then
        TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
        TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
        SetTimeout(500, function()
            triggerAcceptedSale(offer)
        end)
    else
        _debug('[^6DEBUG^0] - Sale denied by customer')
        local robbery = rollRobbery()
        if robbery then
            TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
            TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
            SetTimeout(500, function()
                triggerRobbery(offer)
            end)
        else
            triggerDeniedSale()
        end
    end
    print(json.encode(offer))
end

local saleUiResponse = nil

RegisterNUICallback('saleUiResponse', function(data, cb)
    saleUiResponse = data
    cb(true)
end)

RegisterNUICallback('getPlayerDrugs', function(_, cb)
    local inventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    local drugItems = Cfg.Options.DrugItems
    local drugs = {}
    for _, item in pairs(inventory) do
        if drugItems[item.name] then
            for _, drug in pairs(drugs) do
                if drug.name == item.name then
                    drug.count = drug.count + item.count
                    goto existed
                end
            end
            table.insert(drugs, item)
            ::existed::
        end
    end
    cb(drugs)
end)

local function openStreetSaleUI()
    _debug('[^6DEBUG^0] - Opening street sale UI')
    Core.Natives.playAnimation(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', -1, 1, 0.0)
    Core.Natives.playAnimation(entities.customer, 'anim@amb@casino@hangout@ped_male@stand@02b@base', 'base', -1, 1, 0.0)
    SendNUIMessage({ action = 'openStreetSale' })
    SetNuiFocus(true, true)
    local data = nil
    while not data do
        Wait(100)
        if IsPedWalking(entities.customer) or IsPedRunning(entities.customer) then TaskStandStill(entities.customer, 1000) end
        if saleUiResponse then
            data = saleUiResponse
            break
        end
    end
    saleUiResponse = nil
    SetNuiFocus(false, false)
    --// TODO: add a timer here to cancel sale if player takes too long
    -- notification that says you took too long and they left?
    if type(data) == 'table' then
        _debug('[^6DEBUG^0] - Player offered drugs:', json.encode(data))
        triggerOfferDrugs(data)
    else
        StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
        PlayPedAmbientSpeechNative(entities.customer, 'Generic_Insult_High', 'Speech_Params_Force')
        TaskWanderStandard(entities.customer, 10.0, 10)
        RemovePedElegantly(entities.customer)
        InitializeStreetSale()
    end
end

local function setupSaleInteraction()
    if not entities.customer or not DoesEntityExist(entities.customer) then return end
    Core.Target.addLocalEntity(entities.customer, {
        {
            label = _L('offer_drugs'),
            icon = 'fas fa-cannabis',
            onSelect = function()
                Core.Target.removeLocalEntity(entities.customer)
                TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
                TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
                SetTimeout(500, openStreetSaleUI)
            end,
            canInteract = function()
                return not IsPedInMeleeCombat(entities.customer) and not IsEntityDead(entities.customer) and isSelling
            end
        }
    })
    PlayPedAmbientSpeechNative(entities.customer, 'Generic_Hi', 'Speech_Params_Force')
    while isSelling and not IsNuiFocused() do
        local playerCoords = GetEntityCoords(cache.ped)
        local customerCoords = GetEntityCoords(entities.customer)
        local distance = #(playerCoords - customerCoords)
        if IsEntityDead(entities.customer) then
            Core.Target.removeLocalEntity(entities.customer)
            entities.customer = nil
            InitializeStreetSale()
            break
        end
        if IsPedWalking(entities.customer) or IsPedRunning(entities.customer) then TaskStandStill(entities.customer, 1000) end
        if distance > Cfg.Options.AbandonDistance then
            _debug('[^6DEBUG^0] - Sale abandoned during interaction')
            Core.Interface.notify(_L('notify_title'), _L('abandoned_sale'), 'error')
            cancelSelling()
            break
        end
        Wait(250)
    end
end

local function getNearestPed()
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = Cfg.Options.FetchDistance
    _debug('[^6DEBUG^0] - Fetching nearest ped within', distance)
    local pedPool = lib.getNearbyPeds(playerCoords, distance)
    local nearestPed = nil
    if not pedPool or #pedPool == 0 then return false end
    for _, ped in pairs(pedPool) do
        local pedDistance = #(playerCoords - ped.coords)
        local isNetworked = NetworkGetEntityIsNetworked(ped.ped)
        local inCar, isDead, pedType = IsPedInAnyVehicle(ped.ped, false), IsEntityDead(ped.ped), GetPedType(ped.ped)
        if isNetworked and pedDistance < distance and ped.ped ~= cache.ped and not inCar and not isDead and pedType ~= 28 and not Entity(ped.ped).state.drug_customer then
            distance = pedDistance
            nearestPed = ped.ped
        end
    end
    if nearestPed then
        _debug('[^6DEBUG^0] - Nearest ped found:', nearestPed, distance)
        TriggerServerEvent('r_drugsales:setPedAsCustomer', NetworkGetNetworkIdFromEntity(nearestPed))
    end
    return nearestPed or false
end

local function taskNewSale()
    local startCoords = GetEntityCoords(cache.ped)
    local delay = math.random(table.unpack(Cfg.Options.StreetPedFrequency)) * 1000
    SetTimeout(delay, function()
        local method = Cfg.Options.StreetPedMethod
        if method == 'fetch' then
            entities.customer = getNearestPed()
            repeat Wait(10) until entities.customer ~= nil
            if not entities.customer then
                _debug('[^1ERROR^0] - No valid ped found, cancelling sale')
                Core.Interface.notify(_L('notify_title'), _L('no_customers_found'), 'error')
                cancelSelling()
                return
            end
            SetEntityAsMissionEntity(entities.customer, true, true)
        elseif method == 'spawn' then
            local model = Cfg.Options.StreetPeds[math.random(#Cfg.Options.StreetPeds)]
            local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 25.0, 0.0)
            local heading = GetEntityHeading(cache.ped) + 180.0
            entities.customer = Core.Natives.createPed(model, coords, heading, true)
        end
        repeat Wait(10) until DoesEntityExist(entities.customer)
        _debug('[^6DEBUG^0] - Sale ready, tasking customer')
        local speed = Cfg.Options.PedWalkSpeed or 1.5
        TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, speed, 1073741824, 0)
        while isSelling do
            local playerCoords = GetEntityCoords(cache.ped)
            local customerCoords = GetEntityCoords(entities.customer)
            local customerDistance = #(playerCoords - customerCoords)
            local startDistance = #(startCoords - playerCoords)
            _debug('[^6DEBUG^0] - Customer distance:', customerDistance)
            if (not IsPedWalking(entities.customer) and not IsPedRunning(entities.customer)) and customerDistance > 1.5 then
                TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, speed, 1073741824, 0)
            end
            --// TODO: add a timer here to cancel sale if ped takes too long
            -- notification that says the ped got lost?
            if startDistance >= Cfg.Options.AbandonDistance then
                _debug('[^6DEBUG^0] - Sale abandoned, customer walked away')
                Core.Interface.notify(_L('notify_title'), _L('abandoned_sale'), 'error')
                cancelSelling()
                break
            end
            if customerDistance <= 2.0 then
                _debug('[^6DEBUG^0] - Customer reached player, setting interaction')
                TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
                setupSaleInteraction()
                break
            end
            Wait(250)
        end
    end)
end

function InitializeStreetSale()
    local zoneBehavior = Cfg.Options.ZoneBehavior
    if IsPedInAnyVehicle(cache.ped, false) then
        _debug('[^1ERROR^0] - Player is in a vehicle')
        Core.Interface.notify(_L('notify_title'), _L('cant_in_vehicle'), 'error')
        cancelSelling()
        return false
    elseif (Cfg.Options.ZonesEnabled and ((zoneBehavior == 'whitelist' and not inZone) or (zoneBehavior == 'blacklist' and inZone))) then
        _debug('[^1ERROR^0] - Not in a valid zone')
        Core.Interface.notify(_L('notify_title'), _L('not_in_zone'), 'error')
        cancelSelling()
        return false
    else
        local drugItems = Cfg.Options.DrugItems
        local inventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
        for _, item in pairs(inventory) do
            if drugItems[item.name] then
                _debug('[^6DEBUG^0] - Starting street selling')
                Core.Interface.notify(_L('notify_title'), _L('wait_for_customers'), 'info', 5000)
                isSelling = true
                taskNewSale()
                return true
            end
        end
        _debug('[^1ERROR^0] - No drugs to sell')
        Core.Interface.notify(_L('notify_title'), _L('not_enough_drugs'), 'error')
        return false
    end
end

function InitializeStreetZones()
    if not Cfg.Options.ZonesEnabled then return end
    for _, zone in pairs(Cfg.Options.Zones) do
        table.insert(zones, lib.zones.poly({
            points = zone,
            thickness = 50.0,
            onEnter = function()
                inZone = (Cfg.Options.ZoneBehavior == 'whitelist')
                _debug('[^6DEBUG^0] - inZone:', inZone)
            end,
            onExit = function()
                inZone = (Cfg.Options.ZoneBehavior == 'blacklist')
                _debug('[^6DEBUG^0] - inZone:', inZone)
            end,
            debug = Cfg.Debug
        }))
    end
    _debug('[^6DEBUG^0] - Initialized ' .. #zones .. ' zones')
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, entity in pairs(entities) do DeleteEntity(entity) end
    for _, zone in pairs(zones) do zone:remove() end
end)
