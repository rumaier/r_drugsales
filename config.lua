--          _                            _
-- _ __  __| |_ __ _   _  __ _ ___  __ _| | ___  ___
-- | '__|/ _` | '__| | | |/ _` / __|/ _` | |/ _ \/ __|
-- | |  | (_| | |  | |_| | (_| \__ \ (_| | |  __/\__ \
-- |_|___\__,_|_|   \__,_|\__, |___/\__,_|_|\___||___/
--  |_____|               |___/
Cfg = {
    --  ___  ___ _ ____   _____ _ __
    -- / __|/ _ \ '__\ \ / / _ \ '__|
    -- \__ \  __/ |   \ V /  __/ |
    -- |___/\___|_|    \_/ \___|_|
    Server = {
        language = 'en',          -- Determines the language. ('en': English, 'es': Spanish, 'fr': French, 'de': German, 'pt': Portuguese, 'zh': Chinese)
        notification = 'default', -- Determines the notification system. ('default', 'ox', 'custom': can be customized in bridge/framework/YOURFRAMEWORK)
        interaction = 'item',     -- Determines wether opening the trap phone is through an item or command. ('item' or 'command')
        command = 'dealer',       -- Determines the command to open the trap phone. (e.g. 'dealer')
        versionCheck = true,      -- Enables version checking to see if the resource is up to date.
    },
    --      _ _                 _       _
    --   __| (_)___ _ __   __ _| |_ ___| |__
    --  / _` | / __| '_ \ / _` | __/ __| '_ \
    -- | (_| | \__ \ |_) | (_| | || (__| | | |
    --  \__,_|_|___/ .__/ \__,_|\__\___|_| |_|
    --             |_|
    Dispatch = {
        notifyOnReject = true,           -- Determines if police are notified on bad sales.
        reportOdds = 50,                 -- Determines the percent chance of a bad sale resulting in police being notified. (1-100)
        policeJobs = {                   -- Determines the police jobs that can be notified. (e.g. 'police', 'sheriff')
            'police',
            -- 'sheriff',
        },
    },
    --           _ _ _
    --  ___  ___| | (_)_ __   __ _
    -- / __|/ _ \ | | | '_ \ / _` |
    -- \__ \  __/ | | | | | | (_| |
    -- |___/\___|_|_|_|_| |_|\__, |
    --                       |___/
    Selling = {
        minPolice = 0,                -- Determines the minimum police required to sell drugs.
        streetSales = 'pool',         -- Determines if street sale peds are fetched from the pool or spawned. ('pool' or 'spawn')
        poolDistance = 100,           -- Determines the distance from the player to fetch street sale peds. Would recommend 100.
        pedFrequency = { 5, 10 },     -- Determines the frequency of ped spawning/fetching in seconds. (min, max)
        rejectChance = 10,            -- Determines the percent chance of a rejected sale. (1-100)
        robberyChance = 10,           -- Determines the percent chance of a robbery attempt, if sale is rejected. (1-100)
        streetQuantity = { 1, 3 },    -- Determines the quantity of drugs bought by street sale peds. (min, max)
        bulkQuantity = { 750, 1000 }, -- Determines the quantity of drugs bought by bulk sale peds. (min, max)
        bulkMeetTime = 10,            -- Determines the time in minutes you have to reach the meetup location.
        account = 'black_money',      -- Determines the account to deposit money into.
        drugs = {                     -- Determines drugs that can be sold. Add as many as you like.
            ['weed'] = {              -- Item Name
                street = { 15, 20 },  -- Street Price (min, max)
                bulk = { 5, 10 },     -- Bulk Price (min, max)
            },
            ['cocaine'] = {
                street = { 25, 30 },
                bulk = { 10, 15 },
            },
            ['meth'] = {
                street = { 35, 40 },
                bulk = { 15, 20 },
            },
        },
        meetupCoords = { -- Determines the coordinates of the meetup locations on bulk sales.
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
        },
    },
    --  _______  _ __   ___  ___
    -- |_  / _ \| '_ \ / _ \/ __|
    --  / / (_) | | | |  __/\__ \
    -- /___\___/|_| |_|\___||___/
    Zones = {
        enabled = true,                        -- Determines if the sell zones feature is enabled.
        zoneCoords = {                         -- You can add as many zones as you like, following formatting. (https://overextended.dev/ox_lib/Modules/Zones/Shared#zone-creation-script)
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
        },
    },
    --                 _
    --  _ __   ___  __| |___
    -- | '_ \ / _ \/ _` / __|
    -- | |_) |  __/ (_| \__ \
    -- | .__/ \___|\__,_|___/
    -- |_|
    Peds = {
        streetPeds = {
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
        },
        bulkPeds = {
            'a_m_m_malibu_01',
            'a_m_m_og_boss_01',
            'cs_lamardavis',
            'csb_hao',
            'csb_g',
            'g_m_y_korlieut_01',
            'g_m_y_salvaboss_01',
            's_m_y_dealer_01',
        },
    },
    --      _      _
    --   __| | ___| |__  _   _  __ _
    --  / _` |/ _ \ '_ \| | | |/ _` |
    -- | (_| |  __/ |_) | |_| | (_| |
    --  \__,_|\___|_.__/ \__,_|\__, |
    --                         |___/
    Debug = true -- Enables debug mode. (DO NOT ENABLE IN PRODUCTION)
}
