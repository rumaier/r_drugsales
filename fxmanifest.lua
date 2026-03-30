---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'resource_name'
description 'resource_description'
author 'author_name'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'core/shared/*.lua',
    'locales/*.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Uncomment if resource uses oxmysql
    'core/server/*.lua',
}

client_scripts {
    'core/client/*.lua',
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
    'core/server/logging.lua',
    'install/**/*.*',
    'locales/*.*',
    'config.lua'    
}