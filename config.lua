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
Cfg.Debug = true        -- Debug prints, not recommended for live servers (boolean)

Cfg.Interaction = 'item'  -- Interaction method ('command' or 'item')
Cfg.Command = 'dealer'    -- Command to open the menu if above is set to 'command'
Cfg.Item = 'dealer_phone' -- Item used to open the menu if above is set to 'item'

Cfg.PoliceNeeded = 0      -- Number of police required to sell drugs (number)
Cfg.PoliceJobs = {        -- List of jobs that are considered LEO
    'police',
    -- 'sheriff'
}
Cfg.Dispatch = false -- Dispatch resource ('linden_outlawalert', 'ps-dispatch', 'cd_dispatch', 'rcore_dispatch', 'custom' or false to disable)
-- CUSTOMIZE YOUR DISPATCH SYSTEM IN CORE/CLIENT/DISPATCH.LUA --

Cfg.Drugs = {
    ['weed'] = {                                                   -- Item Name
        street = { maxAmount = 5, maxPricePer = 15 },              -- Street sale (max amount player can offer, max price per item)
        bulk = { min = 50, max = 150, price = { 5, 10 } },         -- Bulk order (min and max amount to sell, price range per item)
    },
    ['cocaine'] = {
        street = { maxAmount = 3, maxPricePer = 35 },
        bulk = { min = 100, max = 250, price = { 10, 20 } },
    },
    ['meth'] = {
        street = { maxAmount = 2, maxPricePer = 45 },
        bulk = { min = 75, max = 200, price = { 12, 25 } },
    },
    ['xtc'] = {
        street = { maxAmount = 4, maxPricePer = 25 },
        bulk = { min = 40, max = 125, price = { 8, 15 } },
    },
}

Cfg.CurrencyType = 'account' -- Currency type ('item' or 'account')
Cfg.Currency = 'cash'        -- Name of the item or account to payout to

Cfg.StreetMethod = 'fetch'   -- Method for getting street peds ('fetch' or 'spawn')
Cfg.PedFrequency = { 5, 10 } -- Frequency range (min and max) for spawning/fetching street peds
Cfg.FetchDistance = 50.0     -- Distance to fetch street peds from player (number in game units)
Cfg.PedWalkSpeed = 1.4       -- Walk speed for street peds (number, default 1.4)
Cfg.AbandonDistance = 30.0   -- Distance at which a player will abandon a sale (number)
Cfg.ForceCleanup = false     -- Force cleanup of spawned/fetched peds after interaction (boolean)
Cfg.DispatchOdds = 80        -- Percent chance a denied sale will trigger a dispatch alert (number)
Cfg.RobberyOdds = 5          -- Percent chance a denied sale attempt will result in a robbery (number)

Cfg.BulkSales = true         -- Enable or disable bulk sales (boolean)
Cfg.BulkMeetTime = 10        -- Time in minutes a player has to meet the buyer (number)
Cfg.BulkCooldown = 15        -- Cooldown time in minutes before a player can attempt another bulk sale (number)
Cfg.BulkMeetups = {          -- Locations where bulk sale meetups can occur (vec4)
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

Cfg.SaleZones = true -- Enable or disable sale zones (boolean)
Cfg.ZoneBehavior = 'whitelist' -- 'whitelist' to only allow sales in the zones listed, 'blacklist' to disallow sales in the zones listed
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
    }
}

Cfg.StreetPeds = {
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

Cfg.BulkPeds = {
    'a_m_m_malibu_01',
    'a_m_m_og_boss_01',
    'cs_lamardavis',
    'csb_hao',
    'csb_g',
    'g_m_y_korlieut_01',
    'g_m_y_salvaboss_01',
    's_m_y_dealer_01'
}
