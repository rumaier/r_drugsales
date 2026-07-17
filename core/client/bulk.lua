local onMeetup = false
local onCooldown = false
local currentSale = nil -- { point: lib point, blip: blip id, order: { item: item object, count: number, price: number } } 
local entities = {}
local orderInterfaceResponse = nil

RegisterNUICallback('orderInterfaceResponse', function(data, cb)
    _debug('response: ' .. tostring(data))
    orderInterfaceResponse = data
    cb(true)
end)

local function setCooldown()
    local time = Cfg.BulkSaleCooldown * 60000
    onCooldown = true
    SetTimeout(time, function()
        onCooldown = false
    end)
end

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
    if not entities.customer or not DoesEntityExist(entities.customer) then
        entities.customer = nil
        return
    end
    local customer = entities.customer
    entities.customer = nil
    bridge.target.removeLocalEntity(customer)
    bridge.natives.setPedInert(customer, false)
    TaskWanderStandard(customer, 10.0, 10)
    SetEntityAsNoLongerNeeded(customer)
    setEntityForCleanup(customer)
end

local function cancelMeetup()
    releaseCustomer()
    if not currentSale then return end
    TriggerServerEvent('r_drugsales:clearBulkOrder')
    bridge.natives.removeBlip(currentSale.blip)
    bridge.natives.clearGpsRoute()
    currentSale.point:remove()
    orderInterfaceResponse = nil
    onMeetup = false
    currentSale = nil
end

local function taskExchangeAnimation()
    local pedHand = GetPedBoneIndex(entities.customer, 28422)
    bridge.natives.setPedInert(entities.customer, false)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, -1)
    TaskTurnPedToFaceEntity(entities.customer, cache.ped, -1)
    repeat Wait(100) until IsPedFacingPed(cache.ped, entities.customer, 10.0) and IsPedFacingPed(entities.customer, cache.ped, 10.0)
    entities.bag = bridge.natives.createObject('xm_prop_x17_bag_01d', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.bag, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    entities.money = bridge.natives.createObject('prop_anim_cash_pile_01', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.money, entities.customer, pedHand, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
    bridge.natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', -1, 16, 0.0)
    bridge.natives.playAnimation(entities.customer, 'mp_common', 'givetake1_b', -1, 16, 0.0)
    Wait(1500)
    AttachEntityToEntity(entities.bag, entities.customer, pedHand, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    bridge.natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', -1, 16, 0.0)
    SetEntityAsNoLongerNeeded(entities.bag)
    DeleteEntity(entities.money)
    entities.money = nil
end

local function makeExchange()
    if not currentSale then return end
    bridge.target.removeLocalEntity(entities.customer)
    taskExchangeAnimation()
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:processBulkSale', false, netId)
    if not success then
        error('Failed to process bulk sale, check server console for more information')
    else
        bridge.interface.notify(locale('drug_sales'), locale('sale_completed', currentSale.order.count, currentSale.order.item.label, currentSale.order.price), 'success')
        PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
        cancelMeetup()
    end
end

local function spawnCustomer(point)
    if entities.customer then return end
    local model = Cfg.BulkPedModels[math.random(#Cfg.BulkPedModels)]
    entities.customer = bridge.natives.createPed(model, point.coords, point.heading, true)
    bridge.natives.setPedInert(entities.customer, true)
    TaskStartScenarioInPlace(entities.customer, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    bridge.target.addLocalEntity(entities.customer, {
        {
            label = locale('make_exchange'),
            icon = 'fas fa-handshake',
            onSelect = makeExchange,
            canInteract = function()
                return not IsEntityDead(entities.customer) and onMeetup
            end
        }
    })
    _debug('Customer spawned at ' .. point.coords)
end

local function startBulkSale()
    if not currentSale then return end
    local coords = Cfg.BulkMeetupLocations[math.random(#Cfg.BulkMeetupLocations)]
    local timeLimit = GetGameTimer() + Cfg.BulkMeetupTimer * 60000
    currentSale.point = lib.points.new({
        coords = coords.xyz,
        heading = coords.w,
        distance = 150.0,
        onEnter = spawnCustomer,
    })
    currentSale.blip = bridge.natives.createBlip(coords.xyz, 143, 2, 0.7, locale('meetup_location'), false)
    bridge.interface.notify(locale('drug_sales'), locale('head_to_meetup'), 'info')
    bridge.natives.setGpsRoute(coords.xyz, 18)
    CreateThread(function()
        while onMeetup do
            if GetGameTimer() > timeLimit then
                bridge.interface.notify(locale('drug_sales'), locale('took_too_long'), 'error')
                cancelMeetup()
                break
            end
            if DoesEntityExist(entities.customer) and IsEntityDead(entities.customer) then
                cancelMeetup()
                break
            end
            Wait(500)
        end
    end)
end

local function openOrderInterface()
    if not currentSale then return end
    bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_to_call', -1, 16, 0.0)
    Wait(300)
    bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_listen_base', -1, 17, 0.0)
    SendNUIMessage({ action = 'openOrderInterface', data = currentSale.order })
    Wait(300)
    PlayPedRingtone('REMOTE_RING', cache.ped, true)
    SetTimeout(4000, function()
        StopPedRingtone(cache.ped)
    end)
    SetNuiFocus(true, true)
    while orderInterfaceResponse == nil and IsNuiFocused() do
        if orderInterfaceResponse ~= nil then
            break
        end
        Wait(100)
    end
    bridge.natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_out', -1, 16, 0.0)
    PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
    SetTimeout(750, CleanupPhoneProp)
    SetNuiFocus(false, false)
    if orderInterfaceResponse == 'accept' then
        onMeetup = true
        setCooldown()
        startBulkSale()
    else
        onMeetup = false
        currentSale = nil
        orderInterfaceResponse = nil
    end
end

---@param cb fun(success: boolean)?
function InitBulkOrder(cb)
    if onMeetup then
        bridge.interface.notify(locale('drug_sales'), locale('already_selling'), 'error')
        return cb and cb(false)
    end
    if onCooldown then
        bridge.interface.notify(locale('drug_sales'), locale('bulk_cooldown', Cfg.BulkSaleCooldown), 'error')
        return cb and cb(false)
    end
    local items, order = lib.callback.await('r_drugsales:bulkOrderRequest', false)
    if #items == 0 or not order then
        bridge.interface.notify(locale('drug_sales'), locale('no_drugs'), 'error')
        return cb and cb(false)
    end
    currentSale = { order = order }
    if cb then cb(true) end
    openOrderInterface()
end

RegisterNUICallback('initBulkOrder', function(_, cb)
    InitBulkOrder(cb)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, entity in pairs(entities) do DeleteEntity(entity) end
end)