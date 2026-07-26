--           _                            _
--  _ __  __| |_ __ _   _  __ _ ___  __ _| | ___  ___
-- | '__|/ _` | '__| | | |/ _` / __|/ _` | |/ _ \/ __|
-- | |  | (_| | |  | |_| | (_| \__ \ (_| | |  __/\__ \
-- |_|___\__,_|_|   \__,_|\__, |___/\__,_|_|\___||___/
--  |_____|               |___/
--
--  Need support? Join our Discord server for help: https://discord.gg/TR38cZFdQk
--
Cfg = {}

Cfg.Language = 'en'     -- Languages: 'en': English, 'es': Spanish, 'fr': French, 'de': German, 'pt': Portuguese, 'zh': Chinese
Cfg.NuiColor = 'violet' -- Colors: 'dark', 'gray', 'red', 'pink', 'grape', 'violet', 'indigo', 'blue', 'cyan', 'teal', 'green', 'lime', 'yellow', 'orange'
Cfg.VersionCheck = true -- Intermittent version checking (boolean)
Cfg.Debug = false        -- Debug prints, not recommended for live servers (boolean)

Cfg.InteractMethod = 'item'       -- Sets the method for opening the menu ('item' or 'command')
Cfg.InteractCommand = 'dealer'    -- The command to open the menu (only used if InteractMethod is 'command')
Cfg.InteractItem = 'dealer_phone' -- The item to open the menu (only used if InteractMethod is 'item')

Cfg.MinPoliceRequired = false     -- Minimum number of police required to sell drugs (false to disable)
Cfg.DispatchResource = false      -- Dispatch resource to use for police notifications ('linden_outlawalert', 'ps-dispatch', 'cd_dispatch', 'rcore_dispatch', 'custom', or false to disable)
Cfg.PoliceJobs = {                -- Table of police jobs to check for MinPoliceRequired
    'police',
    -- 'sheriff'
}

Cfg.DrugItems = { -- Table of drug items that can be sold
    ['weed'] = {                                                                   -- Drug item name
        street = { maxOffer = 5, maxPrice = 15 },                                  -- Street options (maxOffer: Maximum offer amount, maxPrice: Maximum price offer per item)
        bulk = { minRequest = 50, maxRequest = 100, minPrice = 5, maxPrice = 10 }, -- Bulk options (minRequest: Minimum request amount, maxRequest: Maximum request amount, minPrice: Minimum price per item, maxPrice: Maximum price per item)
    },
    ['cocaine'] = {
        street = { maxOffer = 3, maxPrice = 30 },
        bulk = { minRequest = 50, maxRequest = 100, minPrice = 10, maxPrice = 20 },
    },
    ['meth'] = {
        street = { maxOffer = 2, maxPrice = 50 },
        bulk = { minRequest = 50, maxRequest = 100, minPrice = 20, maxPrice = 30 },
    },
    ['xtc'] = {
        street = { maxOffer = 4, maxPrice = 25 },
        bulk = { minRequest = 50, maxRequest = 100, minPrice = 10, maxPrice = 15 },
    }   
}

Cfg.StreetPedMethod = 'fetch'       -- Method for getting street peds to sell to ('fetch': grab from game pool, 'spawn': spawn a new ped)
Cfg.StreetPedFrequency = { 10, 15 } -- Frequency of street peds to spawn in seconds
Cfg.StreetFetchDistance = 50.0      -- Distance to fetch street peds from if StreetPedMethod is 'fetch'
Cfg.StreetPedWalkSpeed = 1.5        -- Sets how fast peds walk up to the player selling
Cfg.StreetAbandonDistance = 20.0    -- Sets the distance at which a player can go before the ped abandons the sale
Cfg.StreetDispatchOdds = 50         -- Sets the odds of a dispatch notification being sent when a player sells drugs to a street ped (0-100)
Cfg.StreetRobberyChance = 5         -- Sets the odds of a robbery happening when a player sells drugs to a street ped (0-100)

Cfg.BulkSalesEnabled = true         -- Enables bulk sales (boolean)
Cfg.BulkMeetupTimer = 10            -- Sets how long a player has to meet up with a bulk buyer ped in minutes
Cfg.BulkSaleCooldown = 30           -- Sets how long a player has to wait before they can sell to another bulk buyer in minutes
Cfg.BulkMeetupLocations = {         -- Table of locations for bulk buyers to meet up at (vector4)
    vec4(201.06, -2000.82, 17.86, 230.26),
    vec4(414.41, -2051.13, 21.22, 141.53),
    vec4(-40.83, -773.20, 32.09, 166.32),
    vec4(362.78, -1649.05, 26.25, 137.77),
    vec4(438.06, -1318.53, 30.06, 231.25),
    vec4(485.18, -1504.54, 28.29, 212.42),
    vec4(696.86, -1010.63, 21.81, 92.86),
    vec4(1113.79, -637.59, 55.81, 30.81),
    vec4(1050.93, -791.13, 57.22, 102.52),
    vec4(1112.31, -330.16, 66.06, 125.32),
    vec4(1114.68, 2641.64, 37.14, 8.76),
    vec4(634.57, 2779.24, 41.02, 273.88),
    vec4(1718.71, 3294.62, 40.21, 169.61),
    vec4(2536.57, 2640.39, 36.95, 275.86),
    vec4(-1578.73, -969.49, 12.01, 142.17)
}

Cfg.CurrencyType = 'account'   -- Currency type ('account' or 'item')
Cfg.Currency = 'black_money'   -- Currency account or item name

Cfg.EnableZones = true         -- Enables zones (boolean)
Cfg.ZoneBehavior = 'whitelist' -- Zone behavior ('whitelist': only sell in zones, 'blacklist': only sell outside zones)
Cfg.Zones = {
    {
        vec3(123.16, -1937.44, 20.72), -- This zone covers most of the Grove area.
        vec3(122.71, -1945.11, 20.72),
        vec3(118.69, -1952.93, 20.72),
        vec3(111.18, -1957.89, 20.72),
        vec3(99.19, -1960.02, 20.72),
        vec3(88.68, -1960.49, 20.72),
        vec3(80.69, -1936.04, 20.72),
        vec3(24.11, -1888.61, 20.72),
        vec3(-34.69, -1838.39, 20.72),
        vec3(-53.20, -1860.54, 20.72),
        vec3(-84.18, -1834.83, 20.72),
        vec3(-65.35, -1812.30, 20.72),
        vec3(-77.55, -1801.90, 20.72),
        vec3(-61.91, -1784.16, 20.72),
        vec3(-36.63, -1805.29, 20.72),
        vec3(-10.51, -1774.11, 20.72),
        vec3(8.06, -1797.15, 20.72),
        vec3(-16.08, -1823.65, 20.72),
        vec3(-5.08, -1832.54, 20.72),
        vec3(15.73, -1803.63, 20.72),
        vec3(27.53, -1813.63, 20.72),
        vec3(10.47, -1832.35, 20.72),
        vec3(14.07, -1835.61, 20.72),
        vec3(7.84, -1843.39, 20.72),
        vec3(59.44, -1886.51, 20.72),
        vec3(82.79, -1858.61, 20.72),
        vec3(104.94, -1870.88, 20.72),
        vec3(78.16, -1902.18, 20.72),
        vec3(95.83, -1916.55, 20.72),
        vec3(117.83, -1926.10, 20.72),
    },
    {
        vec3(249.31, -2070.76, 15.00), -- This zone covers The Rancho Projects
        vec3(353.30, -1947.66, 15.00),
        vec3(420.45, -2015.37, 15.00),
        vec3(408.63, -2027.32, 15.00),
        vec3(391.39, -2063.07, 15.00),
        vec3(358.018, -2100.51, 15.00),
        vec3(311.77, -2129.07, 15.00)
    },
}

Cfg.StreetPedModels = { -- Table of models used for street sale peds (string)
    'a_f_m_downtown_01',
    'a_f_m_salton_01',
    'a_f_m_tramp_01',
    'a_f_m_trampbeac_01',
    'a_m_m_hillbilly_02',
    'a_m_m_rurmeth_01',
    'a_m_m_salton_01',
    'a_m_m_salton_03',
    'a_m_m_skidrow_01',
    'a_m_m_soucent_01',
    'a_m_m_soucent_03',
    'a_m_m_tramp_01',
    'a_m_m_trampbeac_01',
    'a_m_o_acult_02',
    'a_m_o_soucent_02',
    'a_m_o_soucent_03',
    'a_m_o_tramp_01',
    'a_m_y_juggalo_01',
    'a_m_y_methhead_01',
    'a_m_y_salton_01',
    'cs_ashley',
    'cs_nervousron',
    'cs_omega',
    'cs_taocheng',
    'g_m_importexport_01',
    'cs_wade'
}

Cfg.BulkPedModels = { -- Table of models used for bulk sale peds (string)
    'a_m_m_malibu_01',
    'a_m_m_og_boss_01',
    'cs_lamardavis',
    'csb_hao',
    'csb_g',
    'g_m_y_korlieut_01',
    'g_m_y_salvaboss_01',
    's_m_y_dealer_01',
}

Cfg.ForceCleanup = true       -- Force cleanup a ped 30s after a sale if true, otherwise it will let the game engine handle it
