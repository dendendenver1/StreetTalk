fx_version 'cerulean'
game 'gta5'

author 'GeoHUD'
description 'NPC Interaction System - Talk to NPCs with randomized outcomes using ox_lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib'
}
