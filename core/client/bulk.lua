local entities = {}
local cooldown = false
local selling = false
local current = nil
local point = nil
local blip = nil
local uiResp = nil

function IsBulkSelling()
    return selling
end

function IsBulkCooldown()
    return cooldown
end

local function setCooldown()
    local duration = Cfg.BulkCooldown * 60000
    cooldown = true
    SetTimeout(duration, function()
        cooldown = false
    end)
end

local function getDrugs()
    local playerDrugs = {}
    local drugs = Cfg.Drugs
    local items = lib.callback.await('r_drugsales:getPlayerInventory', false)
    for _, item in pairs(items) do
        if drugs[item.name] and drugs[item.name].bulk.min <= item.count then
            table.insert(playerDrugs, item)
        end
    end
    return #playerDrugs > 0 and playerDrugs or nil
end

RegisterNUICallback('bulkUiResp', function(data, cb)
    uiResp = data
    cb(true)
end)

RegisterNUICallback('getOffer', function(_, cb)
    StopPedRingtone(cache.ped)
    cb(current)
end)

local function exchangeAnimation()
    local hand = GetPedBoneIndex(entities.customer, 28422)
    entities.bag = Core.Natives.createObject(`xm_prop_x17_bag_01d`, vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.bag, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    TaskTurnPedToFaceEntity(cache.ped, entities.customer, 1000)
    Wait(500)
    entities.cash = Core.Natives.createObject(`prop_anim_cash_pile_01`, vec3(0, 0, 0), 0, true)
    AttachEntityToEntity(entities.cash, entities.customer, hand, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
    Core.Natives.playAnimation(cache.ped, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Core.Natives.playAnimation(entities.customer, 'mp_common', 'givetake1_a', 1500, 16, 0.0)
    Wait(1000)
    AttachEntityToEntity(entities.cash, cache.ped, 90, 0.07, 0, -0.02, -83.09, -93.18, 86.26, true, true, false, true, 1, true)
    AttachEntityToEntity(entities.bag, cache.ped, 90, 0.39, -0.06, -0.06, -100.00, -180.00, -78.00, true, true, false, true, 1, true)
    Core.Natives.playAnimation(cache.ped, 'weapon@holster_fat_2h', 'holster', 500, 16, 0.0)
    DeleteEntity(entities.cash)
end

local function cancelSale()
    Core.Natives.setEntityProperties(entities.customer, false, false, false)
    TaskWanderStandard(entities.customer, 10.0, 10)
    SetEntityAsNoLongerNeeded(entities.customer)
    entities.customer = nil
    if selling then
        Core.Natives.removeBlip(blip)
        Core.Natives.setGpsRoute(false)
        selling = false
        current = nil
        point:remove()
        point = nil
        blip = nil
    end
end

local function completeSale()
    Core.Target.removeLocalEntity(entities.customer)
    exchangeAnimation()
    local netId = NetworkGetNetworkIdFromEntity(entities.customer)
    local success = lib.callback.await('r_drugsales:bulk', false, netId, current)
    if success then
        PlayPedAmbientSpeechNative(entities.customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
        Core.Interface.notify(locale('notify_title'), locale('sale_finished', current.count, current.label, current.price), 'success')
    else
        _error('Bulk sale failed, check server console for details')
        cancelSale()
    end
end

local function spawnCustomer()
    local models = Cfg.BulkPeds
    local model = models[math.random(#models)]
    entities.customer = Core.Natives.createPed(model, current.coords.xyz, current.coords.w, true)
    Core.Natives.setEntityProperties(entities.customer, true, true, true)
    TaskStartScenarioInPlace(entities.customer, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    Core.Target.addLocalEntity(entities.customer, {
        {
            label = locale('make_exchange'),
            icon = 'fa-solid fa-handshake',
            onSelect = completeSale,
        }
    })
end

local function taskMeetup()
    local wait = Cfg.BulkMeetTime * 60000
    local timeout = GetGameTimer() + wait
    CreateThread(function()
        while selling and current do
            if IsEntityDead(entities.customer) then
                return cancelSale()
            end
            if GetGameTimer() > timeout then
                Core.Interface.notify(locale('notify_title'), locale('meetup_missed'), 'error')
                return cancelSale()
            end
            Wait(500)
        end
    end)
end

local function initMeetup()
    if type(current) ~= 'table' then return end
    local spots = Cfg.BulkMeetups
    local coords = spots[math.random(#spots)]
    current.coords = coords
    point = lib.points.new({
        coords = coords.xyz,
        distance = 100.0,
        onEnter = spawnCustomer
    })
    blip = Core.Natives.createBlip(coords.xyz, 143, 2, 0.7, locale('meetup_location'), true)
    Core.Natives.setGpsRoute(true, coords.xyz, 18)
    setCooldown()
    taskMeetup()
end

local function waitForResponse()
    local data = nil
    while not data do
        if uiResp then
            data = uiResp
        end
        Wait(100)
    end
    uiResp = nil
    SetNuiFocus(false, false)
    PlaySound(-1, 'Hang_Up', 'Phone_SoundSet_Michael', false, 0, true)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_out', 1000, 16, 0.0)
    SetTimeout(750, function()
        DeletePhone()
    end)
    if data == 'accept' then
        selling = true
        initMeetup()
    end
end

local function openBulkUi()
    PlayPedRingtone('REMOTE_RING', cache.ped, true)
    SendNUIMessage({ action = 'openBulkUi' })
    SetNuiFocus(true, true)
    waitForResponse()
end

function BulkSale()
    local drugs = getDrugs()
    if not drugs then
        Core.Interface.notify(locale('notify_title'), locale('no_bulk_drugs'), 'error')
        return false
    end
    local drug = drugs[math.random(#drugs)]
    local info = Cfg.Drugs[drug.name].bulk
    local count = math.random(info.min, info.max)
    local price = count * math.random(info.price[1], info.price[2])
    current = {
        drug = drug.name,
        label = drug.label,
        count = count,
        price = price
    }
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_text_to_call', 300, 16, 0.0)
    Wait(300)
    Core.Natives.playAnimation(cache.ped, 'cellphone@', 'cellphone_call_listen_base', -1, 17, 0.0)
    return openBulkUi()
end