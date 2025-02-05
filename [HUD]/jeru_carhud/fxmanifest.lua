fx_version 'cerulean'
game 'gta5'

lua54 'yes'

files {
    'interface/fonts/oxanium.ttf',
    'interface/hud.css',
    'interface/hud.html',
    'interface/hud.js',
    'interface/reboot.css',
}

ui_page 'interface/hud.html'

client_scripts {
    'client/hud.lua',
}

exports {
    'registerSeatbeltFunction',
    'registerSpeedLimitFunction',
}
