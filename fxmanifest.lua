fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'
version '2.0.0'

author 'devyn'

client_script 'client/client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/server.lua",
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}

