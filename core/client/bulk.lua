local saleCooldown = false
local onSale = false
local currentSale = nil
local meetPoint = nil
local meetBlip = nil
local entities = {}

function IsBulkSelling()
    return onSale
end

function IsBulkOnCooldown()
    return saleCooldown
end

local function setBulkCooldown()
    local cooldownTime = Cfg.Options.BulkCooldown * 60000
    saleCooldown = true
    SetTimeout(cooldownTime, function()
        saleCooldown = false
    end)    
end

local function cancelSale()
    _debug('[^6DEBUG^0] - Cancelling bulk sale and cleaning up entities')
    TaskWanderStandard(entities.customer, 10.0, 10)
    RemovePedElegantly(entities.customer)
    Core.Target.removeLocalEntity(entities.customer)
    entities.customer = nil
    if onSale then
        onSale = false
        currentSale = nil
        Core.Natives.removeBlip(meetBlip)
        Core.Natives.setGpsRoute(false)
        meetBlip = nil
        meetPoint:remove()
        meetPoint = nil
    end
end

local function triggerBulkExchange()
    entities.bagProp = Core.Natives.createObject('xm_prop_x17_bag_01d', vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.bagProp, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 500)
    Core.Natives.setEntityProperties(entities.customer, false, false, false)
    SetTimeout(500, function()
        entities.cashProp = Core.Natives.createObject('prop_anim_cash_pile_01', vec3(0, 0, 0), 0, true)
        AttachEntityToEntity(entities.cashProp, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        Core.Natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
        Core.Natives.playAnimation(entities.customer, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
        Wait(1500)
        AttachEntityToEntity(entities.bagProp, entities.customer, GetPedBoneIndex(entities.customer, 28422), 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
        AttachEntityToEntity(entities.cashProp, cache.ped, 90, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
        Core.Natives.playAnimation(cache.ped, 'weapons@holster_fat_2h', 'holster', 500, 16, 0.0)
        SetEntityAsNoLongerNeeded(entities.bagProp)
        DeleteEntity(entities.cashProp)
        local customerNetId = NetworkGetNetworkIdFromEntity(entities.customer)
        local success = lib.callback.await('r_drugsales:processBulkSale', false, customerNetId, currentSale)
        if success then
            PlayPedAmbientSpeechNative(entities.customer, 'Generic_Thanks', 'Speech_Params_Force')
            Core.Interface.notify(_L('notify_title'), _L('sale_finished', currentSale.amount, currentSale.label, currentSale.price), 'success')
            cancelSale()
        else
            _debug('[^1ERROR^0] - Sale processing failed, check server console for details')
            cancelSale()
        end
    end)
end

local function spawnCustomer()
    local pedModel = Cfg.Options.BulkPeds[math.random(#Cfg.Options.BulkPeds)]
    entities.customer = Core.Natives.createPed(pedModel, currentSale.coords, currentSale.coords.w, true)
    Core.Natives.setEntityProperties(entities.customer, true, true, true)
    Core.Target.addLocalEntity(entities.customer, {
        {
            label = _L('make_exchange'),
            icon = 'fa-solid fa-handshake',
            onSelect = triggerBulkExchange,
            canInteract = function()
                return not IsEntityDead(entities.customer) and onSale and currentSale
            end
        }
    })
    _debug('[^6DEBUG^0] - Bulk customer spawned')
end

local function startMeetupTimer()
    local endTime = GetGameTimer() + (Cfg.Options.BulkMeetupTime * 60000)
    CreateThread(function() 
        while onSale and currentSale do
            local timeLeft = endTime - GetGameTimer()
            _debug('[^6DEBUG^0] - Time left to meet bulk buyer: ' .. math.ceil(timeLeft / 600) .. ' seconds')
            if (DoesEntityExist(entities.customer) and IsEntityDead(entities.customer)) then
                cancelSale()
                return
            end
            if timeLeft <= 0 then
                Core.Interface.notify(_L('notify_title'), _L('meetup_missed'), 'error')
                cancelSale()
                return
            end
            Wait(500)
        end
    end)
end

local function setupMeetPoint()
    if type(currentSale) ~= 'table' then return end
    currentSale.coords = Cfg.Options.MeetupCoords[math.random(#Cfg.Options.MeetupCoords)]
    meetPoint = lib.points.new({
        coords = currentSale.coords.xyz,
        distance = 100.0,
        onEnter = spawnCustomer,
    })
    meetBlip = Core.Natives.createBlip(currentSale.coords.xyz, 143, 2, 0.7, _L('meetup_location'), false)
    Core.Natives.setGpsRoute(true, currentSale.coords.xyz, 18)
    Core.Interface.notify(_L('notify_title'), _L('head_to_meetup'), 'info', 5000)
    startMeetupTimer()
    _debug('[^6DEBUG^0] - Meetup point set at coords: ' .. json.encode(currentSale.coords))
end

RegisterNUICallback('getCurrentOffer', function(_, cb)
    StopPedRingtone(cache.ped)
    cb(currentSale)
end)

local bulkUiResponse = nil

RegisterNUICallback('bulkUiResponse', function(data, cb)
    cb(true)
    bulkUiResponse = data
end)

local function openBulkSaleUi()
    SetTimeout(250, function()
        PlayPedRingtone('Remote_Ring', cache.ped, true)
        SendNUIMessage({ action = 'openBulkSale' })
        SetNuiFocus(true, true)
        local data = nil
        while not data do
            Wait(100)
            _debug('[^6DEBUG^0] - Waiting for bulk sale UI response...')
            if bulkUiResponse then
                data = bulkUiResponse
            end
        end
        bulkUiResponse = nil
        SetNuiFocus(false, false)
        PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
        Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_out', 1000, 16, 0.0)
        SetTimeout(750, CleanupPhone)
        _debug('[^6DEBUG^0] - Bulk sale UI response received: ' .. tostring(data))
        if data == 'accept' then
            onSale = true
            setupMeetPoint()
        end
    end)
end

function InitializeBulkSale()
    local drugItems = Cfg.Options.DrugItems
    local inventory = lib.callback.await('r_drugsales:getPlayerInventory', false)
    local drugs = {}
    for _, item in pairs(inventory) do
        if drugItems[item.name] and item.count >= drugItems[item.name].bulk.min then
            table.insert(drugs, item)
        end
    end
    if #drugs == 0 then return false, Core.Interface.notify(_L('notify_title'), _L('not_enough_drugs'), 'error') end
    local selectedDrug = drugs[math.random(#drugs)]
    local bulkInfo = drugItems[selectedDrug.name].bulk
    local amount = math.random(bulkInfo.min, math.min(bulkInfo.max, selectedDrug.count))
    local pricePer = math.random(bulkInfo.price[1], bulkInfo.price[2])
    local totalPrice = amount * pricePer
    currentSale = { drug = selectedDrug.name, label = selectedDrug.label, amount = amount, price = totalPrice }
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_to_call', 300, 16, 0.0)
    Wait(300)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_listen_base', -1, 17, 0.0)
    _debug('[^6DEBUG^0] - Bulk sale built, opening UI...')
    setBulkCooldown()
    openBulkSaleUi()
    return true
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, entity in pairs(entities) do DeleteEntity(entity) end
    end
end)