Core = exports['r_bridge']:returnCoreObject()

function SendWebhook(src, event, ...)
    if not Cfg.Webhook.Enabled then return end
    local name = '' if src > 0 then name = GetPlayerName(src) end
    local identifier = Core.Framework.GetPlayerIdentifier(src) or ''
    PerformHttpRequest(Cfg.Webhook.Url, function(err, text, headers)
    end, 'POST', json.encode({
        username = 'Resource Logs',
        avatar_url = 'https://i.ibb.co/z700S5H/square.png',
        embeds = {
            {
                color = 0x2C1B47,
                title = event,
                author = {
                    name = GetCurrentResourceName(),
                    icon_url = 'https://i.ibb.co/z700S5H/square.png',
                    url = 'https://discord.gg/r-scripts'
                },
                thumbnail = {
                    url = 'https://i.ibb.co/z700S5H/square.png'
                },
                fields = {
                    { name = _L('player_id'),  value = src,        inline = true },
                    { name = _L('username'),   value = name,       inline = true },
                    { name = _L('identifier'), value = identifier, inline = false },
                },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
                footer = {
                    text = 'r_scripts',
                    icon_url = 'https://i.ibb.co/z700S5H/square.png',
                },
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

local function checkVersion()
    if not Cfg.Server.VersionCheck then return end
    local url = 'https://api.github.com/repos/rumaier/r_drugsales/releases/latest'
    local current = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    PerformHttpRequest(url, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            local latest = data.tag_name
            if latest ~= current then
                print('[^3WARNING^0] '.. _L('update', GetCurrentResourceName()))
                print('[^3WARNING^0] https://github.com/rumaier/r_drugsales/releases/tag/2.0.4 ^0')
            end
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
    SetTimeout(3600000, checkVersion)
end

function debug(...)
    if Cfg.Debug then
        print(...)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if (GetCurrentResourceName() == resource) then
        print('------------------------------')
        print(_L('version', resource, GetResourceMetadata(resource, 'version', 0)))
        if GetResourceState('r_bridge') ~= 'started' then
            print('^1Bridge not detected, please ensure it is running.^0')
        else
            print('^2Bridge detected and loaded.^0')
        end
        print('------------------------------')
        checkVersion()
    end
end)