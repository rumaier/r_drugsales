---@diagnostic disable: undefined-global

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'resource-name'
description 'fivem-react-mantine'
author 'rumaier'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'utils/shared.lua',
  'core/shared/*.lua',
  'locales/*.lua',
  'configs/*.lua'
}

server_scripts {
  -- '@oxmysql/lib/MySQL.lua',
  'utils/server.lua',
  'core/server/*.lua',
}

client_scripts {
  'utils/client.lua',
  'core/client/*.lua',
}

-- ui_page 'nui/build/index.html' --// TODO: uncomment and delete below line when for production
ui_page 'http://localhost:5173/'
files {
  'nui/build/index.html',
  'nui/build/**/*'
}

dependencies {
  'ox_lib',
  'r_bridge',
  -- 'oxmysql'
}

escrow_ignore {
  'install/**/*.*',
  'locales/*.*',
  'configs/*.lua',
}