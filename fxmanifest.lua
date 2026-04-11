---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'A Simple Drug Selling Script'
author 'rumaier'
version '4.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'core/shared/*.lua',
    'locales/*.lua',
    'config.lua',
}

server_scripts {
    'core/server/*.lua',
}

client_scripts {
    'core/client/*.lua',
}

-- ui_page 'web/dist/index.html' -- uncomment if resource has nui built
ui_page 'http://localhost:5173/'
files {
    'web/dist/index.html',
    'web/dist/**/*',
}

dependencies {
    'r_bridge'
}

escrow_ignore {
    'core/server/logging.lua',
    'install/**/*.*',
    'locales/*.*',
    'config.lua'    
}