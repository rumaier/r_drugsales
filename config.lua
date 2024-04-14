--          _                            _
-- _ __  __| |_ __ _   _  __ _ ___  __ _| | ___  ___
-- | '__|/ _` | '__| | | |/ _` / __|/ _` | |/ _ \/ __|
-- | |  | (_| | |  | |_| | (_| \__ \ (_| | |  __/\__ \
-- |_|___\__,_|_|   \__,_|\__, |___/\__,_|_|\___||___/
--  |_____|               |___/
Cfg = {
    -- Server options
    Notification = 'default', -- Determines the notification system. ('default', 'ox', 'custom': can be customized in bridge/"FRAMEWORK")
    Interaction = 'item',     -- Determines how players will open the Dealer Menu. ('item' or 'command')

    -- Dispatch Options
    Dispatch = 'linden_outlawalert', -- Determines your dispatch system. ('linden_outlawalert', 'cd_dispatch', 'rcore_dispatch', 'core_dispatch', 'custom': can be customized in bridge/dispatch. false to disable. )
    ReportOdds = 10,                 -- Determines the percentage chance of the police being notified when a sale occurs. (Default: 10)

    -- Selling Options
    Drugs = {                                -- Determines drugs that can be sold. Add as many as you like.
        ['cannabis'] = {                     -- Item Name
            Street = { Min = 15, Max = 20 }, -- Street Price
            Bulk = { Min = 5, Max = 10 },    -- Bulk Price
        },
        ['cocaine'] = {
            Street = { Min = 25, Max = 30 },
            Bulk = { Min = 10, Max = 20 },
        },
        ['meth'] = {
            Street = { Min = 40, Max = 60 },
            Bulk = { Min = 15, Max = 25 },
        }
    },

    StreetSelling = 'pool',                -- Determines the street selling method. ('pool': grabs nearest NPC, 'spawn': spawns a ped 20 units away.)
    PoolDistance = 100,                    -- Determines the distance it will pull peds from when in StreetSelling = 'pool'. Wouldn't recommend going over 100.
    PedFrequency = { Min = 15, Max = 20 }, -- Determines how many seconds between either a ped is grabbed or spawned.
    StreetSale = { Min = 1, Max = 5 },     -- Determines the max amount of drugs sold per street sale.
    BulkSale = { Min = 750, Max = 1000 },  -- Determines the minimum amount needed for a bulk sale.

    MeetupCoords = {                       -- Determines where the ped will spawn when meeting for bulk sales. Can add as many as you like.
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

    -- Sell Zone Options
    SellZone = {
        Enabled = true,                    -- Toggles the sellzone players can sell in.
        ZoneCoords = {                     -- Polyzone coords for zone. MAKE ALL Z VALUES MATCH!
            vec3(123.16, -1937.44, 20.72), -- Default zone covers Grove St. (https://overextended.dev/ox_lib/Modules/Zones/Shared#zone-creation-script)
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
        Debug = false -- If you don't know what this is, leave it false.
    },

    -- Ped Options
    StreetPeds = { -- Ped models for street sales when StreetSelling = 'spawn'.
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

    BulkPeds = { -- Ped models for bulk sales
        'a_m_m_malibu_01',
        'a_m_m_og_boss_01',
        'cs_lamardavis',
        'csb_hao',
        'csb_g',
        'g_m_y_korlieut_01',
        'g_m_y_salvaboss_01',
        's_m_y_dealer_01',
    }
}
