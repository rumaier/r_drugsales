---@diagnostic disable: undefined-global

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'fivem-react-mantine'
author 'rumaier'
version '3.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'utils/shared.lua',
  'locales/*.lua',
  'configs/*.lua'
}

server_scripts {
  'utils/server.lua',
  'core/server/*.lua',
}

client_scripts {
  'utils/client.lua',
  'core/client/*.lua',
}

ui_page 'nui/build/index.html'
files {
  'nui/build/index.html',
  'nui/build/**/*'
}

dependencies {
  'ox_lib',
  'r_bridge',
}

escrow_ignore {
  'install/**/*.*',
  'locales/*.*',
  'configs/*.lua',
}