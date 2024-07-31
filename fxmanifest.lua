---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'A Drug Selling System'
author 'r_scripts'
version '2.0.2'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/*.lua',
    'src/shared/*.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/**/server.lua',
    'src/server/*.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'src/client/*.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
}

escrow_ignore {
    "bridge/**/**/*.*",
    'install/**/*.*',
    'locales/*.*',
    'config.*' 
}