local postalFile = 'postals.json'
fx_version 'cerulean'
game 'gta5'

version '1.0'
lua54 'yes'

shared_scripts {
	'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'
lua54 'yes'
use_fxv2_oal 'yes'

ui_page 'assets/index.html'

escrow_ignore {
    'config.lua',
	'client.lua',
	'server.lua',
}

file(postalFile)
postal_file(postalFile)

files {
	'assets/*',
	'assets/sounds/*',
}

dependency '/assetpacks'