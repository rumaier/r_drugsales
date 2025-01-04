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

local function checkResourceVersion()
    if not Cfg.Server.VersionCheck then return end
    Core.VersionCheck(GetCurrentResourceName())
    SetTimeout(3600000, checkResourceVersion)
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
        checkResourceVersion()
    end
end)