fx_version 'cerulean'
game 'gta5'

author 'EJJ_04'
description 'Telefon Tracking'
version '1.0.0'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'          
}

client_scripts {
    'client.lua'               
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', 
    'server.lua'                 
}

dependencies {
    'ox_lib',
    'lb-phone',        
}

lua54 'yes' 
