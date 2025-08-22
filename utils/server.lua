Core = exports.r_bridge:returnCoreObject()

local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)
local bridgeStarted = GetResourceState('r_bridge') == 'started'

DatabaseBuilt = false

local function buildDatabase()
  local built = MySQL.query.await('SHOW TABLES LIKE "'.. resource .. '"')
  if #built > 0 then DatabaseBuilt = true return end
  built = MySQL.query.await('CREATE TABLE `'.. resource .. '` ( `unit` tinyint(4) NOT NULL, PRIMARY KEY (`unit`) )')
  if not built then print('[^8ERROR^0] - Failed to create database table for '.. resource) end
  print('[^2SUCCESS^0] - Database table for '.. resource .. ' created.')
  DatabaseBuilt = true
end

local function checkResourceVersion()
  if not Cfg.Server.VersionCheck then return end
  Core.VersionCheck(resource)
  SetTimeout(3600000, checkResourceVersion)
end

function _debug(...)
  if not Cfg.Debug then return end
  print('[^6DEBUG^0] -', ...)
end

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= resource then return end
  print('------------------------------')
  print(_L('resource_version', resource, version))
  if bridgeStarted then print(_L('bridge_detected'))
  else print(_L('bridge_not_detected')) end
  print('------------------------------')
  checkResourceVersion()
  -- buildDatabase()
end)

function SendWebhook(src, event, fields)
  if not Cfg.Webhook.Enabled then return end
  local srcName = src > 0 and GetPlayerName(src) or 'Server'
  local srcId = src > 0 and Core.Framework.GetPlayerIdentifier(src) or 'N/A'

  PerformHttpRequest(Cfg.Webhook.Url, function()
  end, 'POST', json.encode({
    username = 'Resource Logs', 
    avatar_url = 'https://i.ibb.co/N62P014g/logo-2.jpg', 
    embeds = {
      {
        title = event,
        color = 0x2C1B47, 
        fields = { 
          { name = _L('player_id'),   value = src,   inline = true }, 
          { name = _L('username'),    value = srcName, inline = true }, 
          { name = _L('identifier'),  value = srcId,   inline = false },
          table.unpack(fields or {}) 
        },
        footer = { text = GetCurrentResourceName() },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S') 
      }
    }
  }), { ['Content-Type'] = 'application/json' })
end