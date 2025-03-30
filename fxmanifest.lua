fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Authenticated Weapons Shop System with NPC Delivery'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/nui.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
