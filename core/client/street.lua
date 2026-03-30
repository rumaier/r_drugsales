local peds = Cfg.StreetPeds
local zones = {}
local entities = {}
local isSelling = false
local inZone = not Cfg.SaleZones
local cleanup = Cfg.ForceCleanup
local abandonDist = Cfg.AbandonDistance
local uiResp = nil

function IsStreetSelling()
    return isSelling
end

local function setEntityForCleanup(entity)
    if not cleanup then return end
    SetTimeout(30000, function()
        DeleteEntity(entity)
    end)
end

local function canSellHere()
    local zones = Cfg.Zones
    local behavior = Cfg.ZoneBehavior
    return zones and (behavior == 'whitelist' and inZone or behavior == 'blacklist' and not inZone) or not zones
end

local function hasDrugs()
    local drugs = Cfg.Drugs
    local inventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    for _, item in pairs(inventory) do
        if drugs[item.name] then
            return true
        end
    end
    return false
end

RegisterNUICallback('getDrugs', function(_, cb)
    local items = {}
    local drugs = Cfg.Drugs
    local inventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    for _, item in pairs(inventory) do
        if drugs[item.name] then
            for _, drug in pairs(items) do
                if drug.name == item.name then
                    drug.count = drug.count + item.count
                    goto added
                end
            end
            table.insert(items, item)
            ::added::
        end
    end
    cb(items)
end)

RegisterNUICallback('streetUiResp', function(data, cb)
    uiResp = data
    cb(true)
end)

local function getNearestPed()
    local ped = nil
    local coords = GetEntityCoords(cache.ped)
    local radius = Cfg.FetchDistance
    local pool = lib.getNearbyPeds(coords, radius)
    if not pool or #pool == 0 then return false end
    for _, p in pairs(pool) do
        local self = p.ped == cache.ped
        local dist = #(coords - p.coords)
        local networked = NetworkGetEntityIsNetworked(p.ped)
        local inCar = IsPedInAnyVehicle(p.ped, false)
        local isDead = IsEntityDead(p.ped)
        local type = GetPedType(p.ped)
        local customer = Entity(p.ped).state.drug_customer
        if not self and dist < radius and networked and not inCar and not isDead and type ~= 28 and not customer then
            radius = dist
            ped = p.ped
        end
    end
    if not ped then return false end
    local netId = NetworkGetNetworkIdFromEntity(ped)
    TriggerServerEvent('r_drugsales:setCustomer', netId)
    return ped
end

local function cancelSelling()
    isSelling = false
    if not entities.customer then return end
    TaskWanderStandard(entities.customer, 10.0, 10)
    SetEntityAsNoLongerNeeded(entities.customer)
    if cleanup then
        setEntityForCleanup(entities.customer)
    end
    Core.Target.removeLocalEntity(entities.customer)
    entities.customer = nil
    return false
end

local function getAcceptChance(offer)
    local per = math.floor(offer.total / offer.count)
    local maxPer = Cfg.Drugs[offer].drug.street.maxPricePer
    return math.floor(((maxPer - per + 1) / maxPer) * 100)
end

local function exchangeAnimation(isRobbery)
    local hand = GetPedBoneIndex(entities.customer, 28422)
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    entities.drugs = Core.Natives.createObject(`prop_meth_bag_01`, vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    if not isRobbery then
        entities.cash = Core.Natives.createObject(`prop_anim_cash_note`, vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(entities.cash, entities.customer, hand, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    end
    Core.Natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Core.Natives.playAnimation(entities.customer, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Wait(1000)
    AttachEntityToEntity(entities.drugs, entities.customer, hand, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    if not isRobbery then
        AttachEntityToEntity(entities.cash, cache.ped, 28422, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
        Core.Natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', -1, 16, 0.0)
        DeleteEntity(entities.cash)
        entities.cash = nil
    end
    Core.Natives.playAnimation(entities.customer, 'weapon@holster_fat_2h', 'holster', -1, 16, 0.0)
    DeleteEntity(entities.drugs)
    entities.drugs = nil
end

local function retrieveAnimation()
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
    Wait(500)
    Core.Natives.playAnimation(cache.ped, 'pickup_object', 'pickup_low', 1000, 0, 0.0)
    Wait(500)
    entities.drugs = Core.Natives.createObject(`prop_meth_bag_01`, vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    Wait(500)
    Core.Natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', 500, 16, 0.0)
    DeleteEntity(entities.drugs)
    entities.drugs = nil
end

local function retrieveDrugs()
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    Core.Target.removeLocalEntity(entities.customer)
    retrieveAnimation()
    local success = lib.callback.await('r_drugsales:retrieve', false, netId)
    if success then
        Core.Interface.notify(locale('notify_title'), locale('robber_caught'), 'success')
        SetEntityAsNoLongerNeeded(entities.customer)
        if cleanup then
            setEntityForCleanup(entities.customer)
        end
        entities.customer = nil
        StreetSale()
    else
        _error('Failed to retrieve drugs from robber, check server console for details')
        cancelSelling()
    end
end

local function robberFlee()
    local dist = 0
    local dead = false
    SetPedAsEnemy(entities.customer, true)
    SetPedHasAiBlip(entities.customer, true)
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
    TaskSmartFleePed(entities.customer, cache.ped, 100.0, -1, false, false)
    repeat
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        dist = #(pCoords - cCoords)
        dead = IsEntityDead(entities.customer)
        Wait(100)
    until dist > 50 or dead
    if dead then
        Core.Target.addLocalEntity(entities.customer, {
            {
                label = locale('robbery_target'),
                icon = 'fas fa-cannabis',
                distance = 2.0,
                onSelect = retrieveDrugs
            }
        })
    else
        Core.Interface.notify(locale('notify_title'), locale('robber_escaped'), 'error')
        SetEntityAsNoLongerNeeded(entities.customer)
        if cleanup then
            setEntityForCleanup(entities.customer)
        end
        entities.customer = nil
        StreetSale()
    end
end

local function robbery(offer)
    exchangeAnimation(true)
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:robbery', false, netId, offer)
    if success then
        Core.Interface.notify(locale('notify_title'), locale('sale_robbed'), 'info')
        robberFlee()
    else
        _error('Robbery attempt failed, check server console for details')
        cancelSelling()
    end
end

local function deniedSale()
    Core.Interface.notify(locale('notify_title'), locale('sale_denied'), 'error')
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
    TaskWanderStandard(entities.customer, 10.0, 10)
    SetEntityAsNoLongerNeeded(entities.customer)
    if cleanup then
        setEntityForCleanup(entities.customer)
    end
    entities.customer = nil
    local dispatch = Cfg.DispatchOdds / 100
    if roll(dispatch) then
        TriggerDispatch()
    end
    StreetSale()
end

local function acceptedSale(offer)
    TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
    Wait(500)
    exchangeAnimation()
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:street', false, netId, offer)
    if success then
        Core.Interface.notify(locale('notify_title'), locale('sale_finished', offer.count, offer.drug, offer.total), 'success')
        PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
        TaskWanderStandard(entities.customer, 10.0, 10)
        SetEntityAsNoLongerNeeded(entities.customer)
        if cleanup then
            setEntityForCleanup(entities.customer)
        end
        entities.customer = nil
        StreetSale()
    else
        _error('Street sale failed, check server console for details')
        cancelSelling()
    end
end

local function offerDrugs(offer)
    local odds = getAcceptChance(offer) / 100
    local rob = Cfg.RobberyOdds / 100
    if not roll(odds) then
        if not roll(rob) then
            deniedSale()
        else
            robbery(offer)
        end
    else
        acceptedSale(offer)
    end
end

local function processOffer(offer)
    uiResp = nil
    SetNuiFocus(false, false)
    if type(offer) ~= 'table' then
        StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
        PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
        TaskWanderStandard(entities.customer, 10.0, 10)
        SetEntityAsNoLongerNeeded(entities.customer)
        if cleanup then
            setEntityForCleanup(entities.customer)
        end
        entities.customer = nil
        StreetSale()
    else
        offerDrugs(offer)
    end
end

local function waitForOffer()
    local data = nil
    local timeout = GetGameTimer() + 30000
    while not data do
        local onMove = IsPedWalking(entities.customer) or IsPedRunning(entities.customer)
        if GetGameTimer() >= timeout then
            Core.Interface.notify(locale('notify_title'), locale('took_too_long'), 'error')
            SendNUIMessage({ action = 'closeOfferUi' })
        end
        if onMove then
            TaskStandStill(entities.customer, 1000)
        end
        if uiResp then
            data = uiResp
            break
        end
        Wait(100)
    end
    processOffer(data)
end

local function openOfferUi()
    TaskTurnPedToFaceEntity(entities.customer, cache.ped, 1000)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
    Core.Target.removeLocalEntity(entities.customer)
    Wait(500)
    Core.Natives.playAnimation(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', -1, 1, 0.0)
    Core.Natives.playAnimation(entities.customer, 'anim@amb@casino@hangout@ped_male@stand@02b@base', 'base', -1, 1, 0.0)
    SendNUIMessage({ action = 'openOfferUi' })
    SetNuiFocus(true, true)
    waitForOffer()
end

local function waitForSale()
    while isSelling and not IsNuiFocused() do
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        local dist = #(pCoords - cCoords)
        local dead = IsEntityDead(entities.customer)
        local onMove = IsPedWalking(entities.customer) or IsPedRunning(entities.customer)
        if dist > abandonDist then
            Core.Interface.notify(locale('notify_title'), locale('abandoned_sale'), 'error')
            return cancelSelling()
        end
        if dead then
            Core.Target.removeLocalEntity(entities.customer)
            entities.customer = nil
            return StreetSale()
        end
        if onMove then
            TaskStandStill(entities.customer, -1)
        end
        Wait(250)
    end
end

local function canCompleteSale()
    local combat = IsPedInMeleeCombat(entities.customer)
    local dead = IsEntityDead(entities.customer)
    return not combat and not dead and isSelling
end

local function setInteraction()
    if not entities.customer then return end
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_HI', 'SPEECH_PARAMS_FORCE')
    Core.Target.addLocalEntity(entities.customer, {
        {
            label = locale('offer_drugs'),
            icon = 'fas fa-cannabis',
            canInteract = canCompleteSale,
            onSelect = openOfferUi
        }
    })
    waitForSale()
end

local function getCustomer()
    local method = Cfg.StreetMethod
    if method == 'fetch' then
        entities.customer = getNearestPed()
    else
        local model = joaat(peds[math.random(#peds)])
        local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 25.0, 0.0)
        local heading = GetEntityHeading(cache.ped) + 180.0
        entities.customer = Core.Natives.createPed(model, coords, heading, true)
    end
end

local function taskNewSale()
    local delay = math.random(table.unpack(Cfg.PedFrequency)) * 1000
    Core.Interface.notify(locale('notify_title'), locale('wait_for_customers'), 'info')
    SetTimeout(delay, function()
        repeat
            getCustomer()
            Wait(100)
        until entities.customer and DoesEntityExist(entities.customer)
        SetEntityAsMissionEntity(entities.customer, true, true)
        local speed = Cfg.PedWalkSpeed or 1.5
        local timeout = GetGameTimer() + 30000
        TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, speed, 1073741824, 0)
        while isSelling and entities.customer do
            local pCoords = GetEntityCoords(cache.ped)
            local cCoords = GetEntityCoords(entities.customer)
            local dist = #(pCoords - cCoords)
            local onMove = IsPedWalking(entities.customer) or IsPedRunning(entities.customer)
            if not onMove and dist > 1.5 then
                TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, speed, 1073741824, 0)
            end
            if GetGameTimer() >= timeout then
                _error('Street sale timed out, retrying...')
                return StreetSale()
            end
            if dist >= abandonDist then
                Core.Interface.notify(locale('notify_title'), locale('abandoned_sale'), 'error')
                return cancelSelling()
            end
            if dist <= 1.5 then
                setInteraction()
                return true
            end
            Wait(250)
        end
    end)
end

function StreetSale()
    if IsPedInAnyVehicle(cache.ped, false) then
        Core.Interface.notify(locale('notify_title'), locale('cant_in_vehicle'), 'error')
        return cancelSelling()
    end
    if not canSellHere() then
        Core.Interface.notify(locale('notify_title'), locale('not_in_zone'), 'error')
        return cancelSelling()
    end
    if not hasDrugs() then
        Core.Interface.notify(locale('notify_title'), locale('not_enough_drugs'), 'error')
        return cancelSelling()
    end
    isSelling = true
    return taskNewSale()
end

function InitializeZones()
    if not Cfg.SaleZones then return end
    for _, zone in pairs(Cfg.Zones) do
        table.insert(zones, lib.zones.poly({
            points = zone,
            thickness = 50.0,
            onEnter = function()
                inZone = Cfg.ZoneBehavior == 'whitelist'
            end,
            onExit = function()
                inZone = Cfg.ZoneBehavior == 'blacklist'
            end,
            debug = Cfg.Debug
        }))
    end
end