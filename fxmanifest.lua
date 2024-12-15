fx_version 'cerulean'
game 'gta5'

author 'EJJ_04'
description 'Telefon Tracking'
version '1.0.0'

files {
    'locales/*.json'
}

shared_scripts {
    '@es_extended/imports.lua', 
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
    'es_extended',  
    'ox_lib',
    'lb-phone',        
}

lua54 'yes' 