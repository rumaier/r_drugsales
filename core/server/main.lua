local bulkOrders = {}
local bulkCooldowns = {}
local robberies = {}
local streetSessions = {}
local customerPedOwners = {}
local cooldowns = {}

local SALE_PROXIMITY = 5.0
local MEETUP_RADIUS = 25.0
local CUSTOMER_REGISTER_BUFFER = 5.0
local MENU_COOLDOWN_MS = 1000
local STREET_OFFER_COOLDOWN_MS = 500
local BULK_REQUEST_COOLDOWN_MS = 1000
local BULK_SALE_COOLDOWN_MS = 500
local RETRIEVAL_COOLDOWN_MS = 500
local GET_DRUGS_COOLDOWN_MS = 500

local function warn(src, message)
    print(('^1[r_drugsales]^0 Player %s %s'):format(src, message))
end

local function getCooldownKey(src, action)
    return ('%s:%s'):format(src, action)
end

local function isOnCooldown(src, action, duration)
    local last = cooldowns[getCooldownKey(src, action)]
    return last and GetGameTimer() - last < duration
end

local function setCooldown(src, action)
    cooldowns[getCooldownKey(src, action)] = GetGameTimer()
end

local function clearPlayerState(src)
    local session = streetSessions[src]
    if session then
        customerPedOwners[session.netId] = nil
        streetSessions[src] = nil
    end
    bulkOrders[src] = nil
    bulkCooldowns[src] = nil
    for key in pairs(cooldowns) do
        if key:match('^' .. src .. ':') then
            cooldowns[key] = nil
        end
    end
end

local function getPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    return GetEntityCoords(ped)
end

local function getPoliceCount()
    local count = 0
    for _, id in pairs(GetPlayers()) do
        local playerId = tonumber(id)
        if playerId then
            local job = bridge.framework.getPlayerJob(playerId) or {}
            if lib.table.contains(Cfg.PoliceJobs, job.name) then
                count = count + 1
            end
        end
    end
    return count
end

local function requireSaleAccess(src)
    local job = bridge.framework.getPlayerJob(src) or {}
    if lib.table.contains(Cfg.PoliceJobs, job.name) then
        return false
    end
    local minPolice = Cfg.MinPoliceRequired
    if minPolice and getPoliceCount() < minPolice then
        return false
    end
    return true
end

local function isPlayerInSellZone(src)
    if not Cfg.EnableZones then return true end
    local coords = getPlayerCoords(src)
    if not coords then return false end
    local inside = isPointInZones(coords, Cfg.Zones)
    if Cfg.ZoneBehavior == 'whitelist' then
        return inside
    end
    return not inside
end

local function giveMoney(src, amount)
    local currency = Cfg.Currency
    if Cfg.CurrencyType == 'item' then
        bridge.inventory.addItem(src, currency, amount)
    else
        bridge.framework.addBalance(src, currency, amount)
    end
end

local function getPlayerDrugs(src)
    local drugs = {}
    local inventory = bridge.inventory.getInventory(src) or {}
    for _, item in pairs(inventory) do
        if Cfg.DrugItems[item.name] then
            table.insert(drugs, item)
        end
    end
    return drugs
end

local function copyDrugItemsForClient(drugItems)
    local copied = {}
    for name, data in pairs(drugItems or {}) do
        copied[name] = {
            street = {
                maxOffer = data.street.maxOffer,
                maxPrice = data.street.maxPrice,
            },
        }
    end
    return copied
end

local function getAcceptOdds(itemName, price)
    local cfg = Cfg.DrugItems[itemName].street
    local max = cfg.maxPrice
    return math.floor(((max - price + 1) / max) * 100) / 100
end

local function validateStreetOffer(src, offer)
    if type(offer) ~= 'table' then return end
    local itemName = offer.item
    local count = offer.count
    local price = offer.price
    if type(itemName) ~= 'string' then return end
    if type(count) ~= 'number' or count ~= math.floor(count) or count < 1 then return end
    if type(price) ~= 'number' or price ~= math.floor(price) or price < 1 then return end
    local drugCfg = Cfg.DrugItems[itemName]
    if not drugCfg or not drugCfg.street then return end
    if count > drugCfg.street.maxOffer then return end
    if price > drugCfg.street.maxPrice then return end
    local owned = bridge.inventory.getItemCount(src, itemName) or 0
    if count > owned then return end
    return { item = itemName, count = count, price = price }
end

local function isNearEntity(src, entity, maxDistance)
    local player = GetPlayerPed(src)
    if not player or player == 0 then return false end
    if not entity or not DoesEntityExist(entity) then return false end
    return #(GetEntityCoords(player) - GetEntityCoords(entity)) <= maxDistance
end

local function isBulkOnCooldown(src)
    local untilTime = bulkCooldowns[src]
    return untilTime and os.time() < untilTime
end

local function getBulkEligibleDrugs(src)
    local eligible = {}
    for itemName, drugCfg in pairs(Cfg.DrugItems or {}) do
        local bulkCfg = drugCfg.bulk
        if bulkCfg then
            local total = bridge.inventory.getItemCount(src, itemName) or 0
            if total >= bulkCfg.minRequest then
                table.insert(eligible, { name = itemName, count = total })
            end
        end
    end
    return eligible
end

local function setBulkCooldown(src)
    bulkCooldowns[src] = os.time() + ((Cfg.BulkSaleCooldown or 0) * 60)
end

lib.callback.register('r_drugsales:getClientConfig', function()
    return {
        Language = Cfg.Language,
        NuiColor = Cfg.NuiColor,
        Debug = Cfg.Debug,
        BulkSalesEnabled = Cfg.BulkSalesEnabled,
        DrugItems = copyDrugItemsForClient(Cfg.DrugItems),
        EnableZones = Cfg.EnableZones,
        ZoneBehavior = Cfg.ZoneBehavior,
        Zones = Cfg.Zones,
        StreetPedMethod = Cfg.StreetPedMethod,
        StreetPedFrequency = Cfg.StreetPedFrequency,
        StreetFetchDistance = Cfg.StreetFetchDistance,
        StreetPedWalkSpeed = Cfg.StreetPedWalkSpeed,
        StreetAbandonDistance = Cfg.StreetAbandonDistance,
        StreetDispatchOdds = Cfg.StreetDispatchOdds,
        StreetRobberyChance = Cfg.StreetRobberyChance,
        StreetPedModels = Cfg.StreetPedModels,
        BulkPedModels = Cfg.BulkPedModels,
        BulkMeetupTimer = Cfg.BulkMeetupTimer,
        BulkSaleCooldown = Cfg.BulkSaleCooldown,
        ForceCleanup = Cfg.ForceCleanup,
        InteractMethod = Cfg.InteractMethod,
        InteractItem = Cfg.InteractItem,
        InteractCommand = Cfg.InteractCommand,
        DispatchResource = Cfg.DispatchResource,
        PoliceJobs = Cfg.PoliceJobs,
        VersionCheck = Cfg.VersionCheck,
    }
end)

lib.callback.register('r_drugsales:getPlayerDrugs', function(src)
    if isOnCooldown(src, 'getDrugs', GET_DRUGS_COOLDOWN_MS) then
        warn(src, 'rate limited getPlayerDrugs')
        return {}
    end
    setCooldown(src, 'getDrugs')
    if not requireSaleAccess(src) then
        warn(src, 'blocked getPlayerDrugs without sale access')
        return {}
    end
    return getPlayerDrugs(src)
end)

lib.callback.register('r_drugsales:registerStreetCustomer', function(src, netId)
    if isOnCooldown(src, 'registerCustomer', STREET_OFFER_COOLDOWN_MS) then
        warn(src, 'rate limited registerStreetCustomer')
        return false
    end
    if not requireSaleAccess(src) then
        warn(src, 'blocked registerStreetCustomer without sale access')
        return false
    end
    if not isPlayerInSellZone(src) then
        warn(src, 'blocked registerStreetCustomer outside sell zone')
        return false
    end
    if type(netId) ~= 'number' then
        warn(src, 'invalid netId for registerStreetCustomer')
        return false
    end
    if customerPedOwners[netId] and customerPedOwners[netId] ~= src then
        warn(src, 'attempted to register customer already owned by another player')
        return false
    end
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        warn(src, 'attempted to register non-existent customer ped')
        return false
    end
    local maxDistance = (Cfg.StreetFetchDistance or 25.0) + CUSTOMER_REGISTER_BUFFER
    if not isNearEntity(src, customer, maxDistance) then
        warn(src, 'attempted to register customer ped too far away')
        return false
    end
    if streetSessions[src] then
        customerPedOwners[streetSessions[src].netId] = nil
    end
    streetSessions[src] = { netId = netId, startedAt = os.time() }
    customerPedOwners[netId] = src
    Entity(customer).state:set('drugCustomer', true, true)
    setCooldown(src, 'registerCustomer')
    return true
end)

lib.callback.register('r_drugsales:resolveStreetOffer', function(src, netId, offer)
    if isOnCooldown(src, 'streetOffer', STREET_OFFER_COOLDOWN_MS) then
        warn(src, 'rate limited resolveStreetOffer')
        return false
    end
    if not requireSaleAccess(src) then
        warn(src, 'blocked resolveStreetOffer without sale access')
        return false
    end
    if not isPlayerInSellZone(src) then
        warn(src, 'blocked resolveStreetOffer outside sell zone')
        return false
    end
    local session = streetSessions[src]
    if not session or session.netId ~= netId then
        warn(src, 'resolveStreetOffer without matching street session')
        return false
    end
    local validatedOffer = validateStreetOffer(src, offer)
    if not validatedOffer then
        warn(src, 'invalid street offer payload')
        return false
    end
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not isNearEntity(src, customer, SALE_PROXIMITY) then
        warn(src, 'resolveStreetOffer customer too far away')
        return false
    end
    setCooldown(src, 'streetOffer')

    local acceptOdds = getAcceptOdds(validatedOffer.item, validatedOffer.price)
    local roll = math.random()
    if roll <= acceptOdds then
        if not bridge.inventory.removeItem(src, validatedOffer.item, validatedOffer.count) then
            warn(src, 'failed to remove items for accepted street sale')
            return false
        end
        local payout = validatedOffer.price * validatedOffer.count
        giveMoney(src, payout)
        return true, {
            outcome = 'accept',
            offer = validatedOffer,
            payout = payout,
        }
    end

    if math.random() <= (Cfg.StreetRobberyChance / 100) then
        if not bridge.inventory.removeItem(src, validatedOffer.item, validatedOffer.count) then
            warn(src, 'failed to remove items for street robbery')
            return false
        end
        local identifier = bridge.framework.getPlayerIdentifier(src)
        if not identifier then
            warn(src, 'failed to get identifier for street robbery')
            return false
        end
        robberies[identifier] = {
            netId = netId,
            offer = validatedOffer,
        }
        return true, {
            outcome = 'robbery',
            offer = validatedOffer,
        }
    end

    return true, {
        outcome = 'reject',
        offer = validatedOffer,
    }
end)

lib.callback.register('r_drugsales:bulkOrderRequest', function(src)
    if isOnCooldown(src, 'bulkRequest', BULK_REQUEST_COOLDOWN_MS) then
        warn(src, 'rate limited bulkOrderRequest')
        return {}, false
    end
    if not Cfg.BulkSalesEnabled then
        return {}, false, 'bulk_sales_disabled'
    end
    if not requireSaleAccess(src) then
        warn(src, 'blocked bulkOrderRequest without sale access')
        return {}, false
    end
    if isBulkOnCooldown(src) then
        return {}, false, 'bulk_sale_cooldown'
    end
    setCooldown(src, 'bulkRequest')

    local items = getBulkEligibleDrugs(src)
    if #items == 0 then return items, false, 'no_drugs' end

    local item = items[math.random(#items)]
    local cfg = Cfg.DrugItems[item.name].bulk
    local count = math.random(cfg.minRequest, math.min(cfg.maxRequest, item.count))
    local price = math.random(cfg.minPrice, cfg.maxPrice) * count
    bulkOrders[src] = {
        item = { name = item.name },
        count = count,
        price = price,
    }
    return items, bulkOrders[src]
end)

lib.callback.register('r_drugsales:bulkOrderAccept', function(src)
    local order = bulkOrders[src]
    if not order then
        warn(src, 'bulkOrderAccept without pending order')
        return false
    end
    if not requireSaleAccess(src) then
        warn(src, 'blocked bulkOrderAccept without sale access')
        return false
    end
    if not Cfg.BulkMeetupLocations or #Cfg.BulkMeetupLocations == 0 then
        warn(src, 'bulkOrderAccept with no meetup locations configured')
        return false, 'bulk_meetup_unavailable'
    end
    order.meetup = Cfg.BulkMeetupLocations[math.random(#Cfg.BulkMeetupLocations)]
    setBulkCooldown(src)
    return true, order.meetup
end)

lib.callback.register('r_drugsales:bulkOrderDecline', function(src)
    if bulkOrders[src] then
        bulkOrders[src] = nil
    end
    return true
end)

lib.callback.register('r_drugsales:processBulkSale', function(src, netId)
    if isOnCooldown(src, 'bulkSale', BULK_SALE_COOLDOWN_MS) then
        warn(src, 'rate limited processBulkSale')
        return false
    end
    local order = bulkOrders[src]
    if not order then
        warn(src, 'processBulkSale without pending order')
        return false
    end
    if not order.meetup then
        warn(src, 'processBulkSale without assigned meetup')
        return false
    end
    if not requireSaleAccess(src) then
        warn(src, 'blocked processBulkSale without sale access')
        return false
    end
    local player = GetPlayerPed(src)
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) then
        warn(src, 'processBulkSale customer does not exist')
        return false
    end
    local pCoords = GetEntityCoords(player)
    local cCoords = GetEntityCoords(customer)
    if #(pCoords - cCoords) > SALE_PROXIMITY then
        warn(src, 'processBulkSale customer too far away')
        return false
    end
    local meetupCoords = vector3(order.meetup.x, order.meetup.y, order.meetup.z)
    if #(pCoords - meetupCoords) > MEETUP_RADIUS then
        warn(src, 'processBulkSale seller not at assigned meetup')
        return false
    end
    if not bridge.inventory.removeItem(src, order.item.name, order.count) then
        warn(src, 'failed to remove items for bulk sale')
        return false
    end
    giveMoney(src, order.price)
    bulkOrders[src] = nil
    setCooldown(src, 'bulkSale')
    return true
end)

lib.callback.register('r_drugsales:processStreetRetrieval', function(src, netId)
    if isOnCooldown(src, 'retrieval', RETRIEVAL_COOLDOWN_MS) then
        warn(src, 'rate limited processStreetRetrieval')
        return false
    end
    local identifier = bridge.framework.getPlayerIdentifier(src)
    if not identifier then
        warn(src, 'processStreetRetrieval without identifier')
        return false
    end
    local robbery = robberies[identifier]
    if not robbery then
        warn(src, 'processStreetRetrieval without robbery record')
        return false
    end
    if robbery.netId ~= netId then
        warn(src, 'processStreetRetrieval netId mismatch')
        return false
    end
    local customer = NetworkGetEntityFromNetworkId(netId)
    if not customer or not DoesEntityExist(customer) or not IsEntityDead(customer) then
        warn(src, 'processStreetRetrieval invalid robbery ped')
        return false
    end
    if not isNearEntity(src, customer, SALE_PROXIMITY) then
        warn(src, 'processStreetRetrieval ped too far away')
        return false
    end
    if not bridge.inventory.addItem(src, robbery.offer.item, robbery.offer.count) then
        warn(src, 'failed to restore robbed items')
        return false
    end
    robberies[identifier] = nil
    setCooldown(src, 'retrieval')
    return true
end)

lib.callback.register('r_drugsales:menuRequest', function(src)
    if isOnCooldown(src, 'menu', MENU_COOLDOWN_MS) then
        warn(src, 'rate limited menuRequest')
        return false
    end
    setCooldown(src, 'menu')
    local job = bridge.framework.getPlayerJob(src) or {}
    if lib.table.contains(Cfg.PoliceJobs, job.name) then
        return false, 'no_police_allowed'
    end
    local minPolice = Cfg.MinPoliceRequired
    if minPolice and getPoliceCount() < minPolice then
        return false, 'not_enough_police'
    end
    return true
end)

local function registerInteractMethod()
    local method = Cfg.InteractMethod
    if method == 'item' then
        bridge.framework.registerUsableItem(Cfg.InteractItem, function(src)
            TriggerClientEvent('r_drugsales:openMenu', src)
        end)
    elseif method == 'command' then
        lib.addCommand(Cfg.InteractCommand, { help = locale('command_help') }, function(src)
            TriggerClientEvent('r_drugsales:openMenu', src)
        end)
    else
        error('Invalid interact method: ' .. method)
    end
end

AddEventHandler('playerDropped', function()
    clearPlayerState(source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    registerInteractMethod()
end)
