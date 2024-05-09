---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'r_drugsales'
description 'A Drug Selling System'
author 'r_scripts'
version '1.0.4'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'client/*.lua',
}

server_scripts {
    'bridge/**/server.lua',
    'server/*.lua',
}

dependencies {
    'ox_lib',
}