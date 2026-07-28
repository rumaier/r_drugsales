local zones = {}
local entities = {}
local isSelling = false
local canSell = false
local offerInterfaceResponse = nil

local function refreshCanSell()
    if not Cfg.EnableZones then
        canSell = true
        return
    end
    if not Cfg.Zones then
        canSell = false
        return
    end
    local inside = isPointInZones(GetEntityCoords(cache.ped), Cfg.Zones)
    if Cfg.ZoneBehavior == 'whitelist' then
        canSell = inside
    else
        canSell = not inside
    end
    _debug('canSell: ' .. tostring(canSell))
end

RegisterNUICallback('offerInterfaceResponse', function(data, cb)
    _debug('response: ' .. json.encode(data))
    offerInterfaceResponse = data
    cb(true)
end)

local function setEntityForCleanup(entity)
    if not entity or not Cfg.ForceCleanup then return end
    _debug('Cleaning up entity ' .. tostring(entity) .. ' in 30 seconds')
    SetTimeout(30000, function()
        DeleteEntity(entity)
        for k, v in pairs(entities) do
            if v == entity then entities[k] = nil break end
        end
    end)
end

local function releaseCustomer()
    local customer = entities.customer
    entities.customer = nil
    if not customer or not DoesEntityExist(customer) then return end
    bridge.target.removeLocalEntity(customer)
    TaskWanderStandard(customer, 10.0, 10)
    SetEntityAsNoLongerNeeded(customer)
    setEntityForCleanup(customer)
end

local function cancelSale()
    offerInterfaceResponse = nil
    isSelling = false
    releaseCustomer()
end

local function restartStreetSale()
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    cancelSale()
    return InitStreetSale()
end

local function isPedQualified(ped)
    return ped ~= cache.ped
    and not IsPedInAnyVehicle(ped, true)
    and not IsEntityDead(ped)
    and GetPedType(ped) ~= 28
    and not Entity(ped).state.drugCustomer
    and NetworkGetEntityIsNetworked(ped)
end

local function getNearestPed(coords)
    local ped = nil
    local maxDistance = Cfg.StreetFetchDistance
    local pool = lib.getNearbyPeds(coords, maxDistance)
    if not pool or #pool == 0 then return false end
    for _, p in pairs(pool) do
        local distance = #(coords - p.coords)
        if distance < maxDistance and isPedQualified(p.ped) then
            maxDistance = distance
            ped = p.ped
        end
    end
    if not ped then return false end
    local netId = NetworkGetNetworkIdFromEntity(ped)
    local registered = lib.callback.await('r_drugsales:registerStreetCustomer', false, netId)
    if not registered then return false end
    SetEntityAsMissionEntity(ped, true, true)
    return ped
end

local function taskExchangeAnimation(isRobbery)
    local pedHand = GetPedBoneIndex(entities.customer, 28422)
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    entities.drugs = bridge.natives.createObject('prop_meth_bag_01', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    if not isRobbery then
        entities.money = bridge.natives.createObject('prop_anim_cash_note', vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(entities.money, entities.customer, pedHand, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    end
    bridge.natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', -1, 16, 0.0)
    bridge.natives.playAnimation(entities.customer, 'mp_common', 'givetake1_b', -1, 16, 0.0)
    Wait(1500)
    AttachEntityToEntity(entities.drugs, entities.customer, pedHand, 0.07, 0, -0.01, 18.12, 7.21, -12.44, true, true, false, true, 1, true)
    if not isRobbery then
        AttachEntityToEntity(entities.money, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
        bridge.natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', -1, 16, 0.0)
        DeleteEntity(entities.money)
    end
    bridge.natives.playAnimation(entities.customer, 'weapons@holster_fat_2h', 'holster', -1, 16, 0.0)
    DeleteEntity(entities.drugs)
    entities.drugs = nil
    entities.money = nil
end

local function retrieveDrugs(self)
    self = NormalizeTarget(self)
    bridge.target.removeLocalEntity(entities.customer)
    TaskTurnPedToFaceEntity(entities.customer, cache.ped, -1)
    repeat Wait(100) until IsPedFacingPed(cache.ped, entities.customer, 10.0)
    bridge.natives.playAnimation(cache.ped, 'pickup_object', 'pickup_low', -1, 0, 0.0)
    Wait(500)
    entities.drugs = bridge.natives.createObject('prop_meth_bag_01', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.drugs, cache.ped, 90, 0.07, 0.01, -0.01, 136.33, 50.23, -50.26, true, true, false, true, 1, true)
    bridge.natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', -1, 16, 0.0)
    DeleteEntity(entities.drugs)
    entities.drugs = nil
    local netId = NetworkGetNetworkIdFromEntity(self.entity)
    local success = lib.callback.await('r_drugsales:processStreetRetrieval', false, netId)
    if success then
        bridge.interface.notify(locale('drug_sales'), locale('robber_caught'), 'success')
        cancelSale()
    end
end

local function taskChaseCustomer()
    local distance, dead = 0, false
    repeat
        dead = IsEntityDead(entities.customer)
        distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(entities.customer))
        Wait(100)
    until distance > 50.0 or dead
    if distance > 50.0 then
        bridge.interface.notify(locale('drug_sales'), locale('robber_escaped'), 'error')
        cancelSale()
    elseif dead then
        bridge.target.addLocalEntity(entities.customer, {
            {
                label = locale('retrieve_drugs'),
                icon = 'fas fa-cannabis',
                onSelect = retrieveDrugs,
                canInteract = function()
                    return IsEntityDead(entities.customer)
                end
            }
        })
    end
end

local function taskCustomerRobPlayer()
    taskExchangeAnimation(true)
    bridge.interface.notify(locale('drug_sales'), locale('sale_robbed'), 'error')
    SetPedAsEnemy(entities.customer, true)
    SetPedHasAiBlip(entities.customer, true)
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
    TaskSmartFleePed(entities.customer, cache.ped, 100.0, -1, false, false)
    taskChaseCustomer()
end

local function taskAcceptedOffer(offer, payout)
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    taskExchangeAnimation()
    local itemInfo = bridge.inventory.getItemInfo(offer.item)
    local itemLabel = (itemInfo and itemInfo.label) or offer.item
    bridge.interface.notify(locale('drug_sales'), locale('sale_completed', offer.count, itemLabel, payout), 'success')
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
    restartStreetSale()
end

local function taskRejectedOffer()
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    bridge.interface.notify(locale('drug_sales'), locale('offer_rejected'), 'error')
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
    releaseCustomer()
    if math.random() <= Cfg.StreetDispatchOdds / 100 then
        TriggerDispatch()
    end
    restartStreetSale()
end

local function resolveOffer(offer)
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success, result = lib.callback.await('r_drugsales:resolveStreetOffer', false, netId, offer)
    if not success or not result then return end
    if result.outcome == 'accept' then
        taskAcceptedOffer(result.offer, result.payout)
    elseif result.outcome == 'robbery' then
        taskCustomerRobPlayer()
    else
        taskRejectedOffer()
    end
end

local function canOpenOfferInterface()
    return isSelling
    and not IsPedInMeleeCombat(entities.customer)
    and not IsEntityDead(entities.customer)
end

local function openOfferInterface()
    offerInterfaceResponse = nil
    bridge.target.removeLocalEntity(entities.customer)
    local timeLimit = GetGameTimer() + 30000
    local items = lib.callback.await('r_drugsales:getPlayerDrugs', false)
    SendNUIMessage({ action = 'openOfferInterface', data = { items = items }})
    TaskTurnPedToFaceEntity(entities.customer, cache.ped, -1)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, -1)
    repeat Wait(100) until IsPedFacingPed(cache.ped, entities.customer, 10.0) and IsPedFacingPed(entities.customer, cache.ped, 10.0)
    bridge.natives.playAnimation(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', -1, 1, 0.0)
    bridge.natives.playAnimation(entities.customer, 'anim@amb@casino@hangout@ped_male@stand@02b@base', 'base', -1, 1, 0.0)
    bridge.natives.setPedInert(entities.customer, true)
    SetNuiFocus(true, true)
    while isSelling and offerInterfaceResponse == nil and IsNuiFocused() do
        if GetGameTimer() > timeLimit then
            bridge.interface.notify(locale('drug_sales'), locale('took_too_long'), 'error')
            SendNUIMessage({ action = 'closeOfferInterface'})
            SetNuiFocus(false, false)
            releaseCustomer()
            restartStreetSale()
            break
        end
        if offerInterfaceResponse ~= nil then
            break
        end
        Wait(100)
    end
    StopAnimTask(cache.ped, 'anim@amb@casino@hangout@ped_male@stand@03b@idles_convo', 'idle_d', 1.0)
    bridge.natives.setPedInert(entities.customer, false)
    SetNuiFocus(false, false)
    if not offerInterfaceResponse then
        PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE')
        releaseCustomer()
        restartStreetSale()
    else
        resolveOffer(offerInterfaceResponse)
    end
end

local function taskCustomerAwaitOffer()
    local timeLimit = GetGameTimer() + 30000
    if not entities.customer or not DoesEntityExist(entities.customer) then return end
    bridge.target.addLocalEntity(entities.customer, {
        {
            label = locale('offer_drugs'),
            icon = 'fas fa-cannabis',
            onSelect = openOfferInterface,
            canInteract = canOpenOfferInterface,
        }
    })
    PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_HI', 'SPEECH_PARAMS_FORCE')
    while isSelling and not IsNuiFocused() do
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        if GetGameTimer() > timeLimit then
            bridge.interface.notify(locale('drug_sales'), locale('took_too_long'), 'error')
            releaseCustomer()
            restartStreetSale()
            break
        end
        if IsEntityDead(entities.customer) then
            _debug('customer is dead, cancelling sale...')
            return cancelSale()
        end
        if IsPedWalking(entities.customer) or IsPedRunning(entities.customer) then
            TaskStandStill(entities.customer, -1)
        end
        if #(pCoords - cCoords) >= Cfg.StreetAbandonDistance then
            bridge.interface.notify(locale('drug_sales'), locale('sale_abandoned'), 'error')
            return cancelSale()
        end
        Wait(250)
    end
end

local function taskCustomerApproachPlayer(homePos)
    local timeLimit = GetGameTimer() + 30000
    TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, 1.5, 1073741824, 0)
    while isSelling do
        local pCoords = GetEntityCoords(cache.ped)
        local cCoords = GetEntityCoords(entities.customer)
        if GetGameTimer() > timeLimit then
            _debug('customer timed out')
            return restartStreetSale()
        end
        if (not IsPedWalking(entities.customer) and not IsPedRunning(entities.customer)) and #(pCoords - cCoords) > 1.5 then
            TaskGoToEntity(entities.customer, cache.ped, -1, 1.5, Cfg.StreetPedWalkSpeed or 1.5, 1073741824, 0)
        end
        if #(pCoords - homePos) >= Cfg.StreetAbandonDistance then
            bridge.interface.notify(locale('drug_sales'), locale('sale_abandoned'), 'error')
            return cancelSale()
        end
        if #(pCoords - cCoords) <= 2.0 then
            TaskTurnPedToFaceEntity(entities.customer, cache.ped, -1)
            taskCustomerAwaitOffer()
            break
        end
        Wait(250)
    end
end

local function startStreetSale()
    isSelling = true
    local pedMethod = Cfg.StreetPedMethod
    local homePos = GetEntityCoords(cache.ped)
    bridge.interface.notify(locale('drug_sales'), locale('wait_for_customer'), 'info')
    SetTimeout(math.random(table.unpack(Cfg.StreetPedFrequency)) * 1000, function()
        if pedMethod == 'fetch' then
            entities.customer = getNearestPed(homePos)
            if not entities.customer then
                bridge.interface.notify(locale('drug_sales'), locale('no_customers_found'), 'error')
                return cancelSale()
            end
            _debug('found customer: ' .. tostring(entities.customer))
        elseif pedMethod == 'spawn' then
            local models = Cfg.StreetPedModels
            local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 25.0, 0.0)
            local heading = GetEntityHeading(cache.ped) + 180.0
            entities.customer = bridge.natives.createPed(models[math.random(#models)], coords, heading, true)
            local netId = NetworkGetNetworkIdFromEntity(entities.customer)
            if not lib.callback.await('r_drugsales:registerStreetCustomer', false, netId) then
                bridge.interface.notify(locale('drug_sales'), locale('no_customers_found'), 'error')
                return cancelSale()
            end
            _debug('spawned customer: ' .. tostring(entities.customer))
        end
        taskCustomerApproachPlayer(homePos)
    end)
end

function IsStreetSelling()
    return isSelling
end

function CancelStreetSale()
    if not isSelling then return end
    cancelSale()
    bridge.interface.notify(locale('drug_sales'), locale('sale_cancelled'), 'info')
end

---@param cb fun(success: boolean)?
function InitStreetSale(cb)
    if isSelling then
        return cb and cb(false)
    end
    refreshCanSell()
    if Cfg.EnableZones == nil then
        return cb and cb(false)
    end
    local zoneBehavior = Cfg.ZoneBehavior
    if (Cfg.EnableZones and ((zoneBehavior == 'whitelist' and not canSell) or (zoneBehavior == 'blacklist' and canSell))) then
        bridge.interface.notify(locale('drug_sales'), locale('not_in_zone'), 'error')
        cancelSale()
        return cb and cb(false)
    end
    if IsPedInAnyVehicle(cache.ped, true) then
        bridge.interface.notify(locale('drug_sales'), locale('cant_in_vehicle'), 'error')
        cancelSale()
        return cb and cb(false)
    end
    if #lib.callback.await('r_drugsales:getPlayerDrugs', false) == 0 then
        bridge.interface.notify(locale('drug_sales'), locale('no_drugs'), 'error')
        cancelSale()
        return cb and cb(false)
    end
    startStreetSale()
    return cb and cb(true)
end

RegisterNUICallback('initStreetSale', function(_, cb)
    InitStreetSale(cb)
end)

RegisterNUICallback('cancelStreetSale', function(_, cb)
    CancelStreetSale()
    cb(true)
end)

local function initZones()
    if not Cfg.EnableZones then
        refreshCanSell()
        return
    end
    for _, zone in pairs(Cfg.Zones) do
        table.insert(zones, lib.zones.poly({
            points = zone,
            thickness = 100.0,
            debug = Cfg.Debug,
            onEnter = refreshCanSell,
            onExit = refreshCanSell,
        }))
    end
    refreshCanSell()
    _debug('Initialized ' .. #zones .. ' zones')
end

local function tryInitZones()
    if not Cfg.EnableZones then
        refreshCanSell()
        return
    end
    if #zones > 0 then return end
    if not Cfg.Zones then return end
    initZones()
end

AddEventHandler('r_drugsales:clientConfigLoaded', tryInitZones)

AddEventHandler('r_bridge:playerLoaded', function()
    tryInitZones()
end)

CreateThread(function()
    Wait(500)
    tryInitZones()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, entity in pairs(entities) do DeleteEntity(entity) end
    for _, zone in pairs(zones) do zone:remove() end
end)