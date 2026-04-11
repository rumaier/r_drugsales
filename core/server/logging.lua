--  _                      _             
-- | |    ___   __ _  __ _(_)_ __   __ _ 
-- | |   / _ \ / _` |/ _` | | '_ \ / _` |
-- | |__| (_) | (_| | (_| | | | | | (_| |
-- |_____\___/ \__, |\__, |_|_| |_|\__, |
--             |___/ |___/         |___/ 
--
--
local resource = GetCurrentResourceName()
Cfg.LogsEnabled = true -- Enable or disable logging (true: enabled, false: disabled)
Cfg.WebhookUrl = ''    -- Discord webhook URL

function SendLog(src, info)
    if not Cfg.LogsEnabled then return end
    if not Cfg.WebhookUrl or Cfg.WebhookUrl == '' then return end
    local isServer = (src == 0)
    local name = isServer and 'Server' or GetPlayerName(src)

    -- Discord Webhook by default:
    PerformHttpRequest(Cfg.WebhookUrl, function()
    end, 'POST', json.encode({
        username = resource,
        avatar_url = 'https://i.ibb.co/N62P014g/logo-2.jpg',
        embeds = {
            {
                title = info.action,
                color = 0x2C1B47,
                image = {
                    url = 'https://i.ibb.co/vVMnc6Y/wide.png'
                },
                fields = {
                    {
                        name = locale('server_id'),
                        value = '`' .. src .. '`',
                        inline = true
                    },
                    {
                        name = locale('username'),
                        value = '`' .. name .. '`', 
                        inline = true
                    },
                    {
                        name = utf8.char(0x200B),
                        value = utf8.char(0x200B),
                        inline = true
                    },
                    table.unpack(info.fields or {})
                },
                footer = {
                    text = resource
                },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end