---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'A Simple Drug Selling Script for FiveM'
author 'rumaier'
version '3.2.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@r_bridge/init.lua',
    'core/shared/*.lua',
    'locales/*.lua',
}

server_scripts {
    'config.lua',
    'core/server/_util.lua',
    'core/server/main.lua',
}

client_scripts {
    'core/client/_util.lua',
    'core/client/dispatch.lua',
    'core/client/main.lua',
    'core/client/street.lua',
    'core/client/bulk.lua',
}

ui_page 'web/dist/index.html'
files {
    'web/dist/index.html',
    'web/dist/**/*',
}

dependencies {
    'ox_lib',
    'r_bridge',
}

escrow_ignore {
    'install/**/*.*',
    'locales/*.*',
    'config.lua'
}
