---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'A Simple Drug Selling Script'
author 'rumaier'
version '3.2.0'

shared_scripts {
    '@ox_lib/init.lua',
    'core/shared/*.lua',
    'locales/*.lua',
    'config.lua'
}

server_scripts {
    'core/server/*.lua'
}

client_scripts {
    'core/client/*.lua'
}

ui_page 'web/dist/index.html'
files {
    'web/dist/index.html',
    'web/dist/**/*',
}

dependencies {
    'r_bridge'
}

escrow_ignore {
    'install/**/*.*',
    'locales/*.*',
    'config.lua'
}
