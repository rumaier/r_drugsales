Core = exports.r_bridge:returnCoreObject()

local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)
local bridgeStarted = GetResourceState('r_bridge') == 'started'

local function checkResourceVersion()
  if not Cfg.Server.VersionCheck then return end
  Core.VersionCheck(resource)
  SetTimeout(3600000, checkResourceVersion)
end

function _debug(...)
  if not Cfg.Debug then return end
  print(...)
end

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= resource then return end
  print('------------------------------')
  print(_L('resource_version', resource, version))
  if bridgeStarted then print(_L('bridge_detected'))
  else print(_L('bridge_not_detected')) end
  if Cfg.Debug then print(_L('debug_enabled')) end
  print('------------------------------')
  checkResourceVersion()
end)