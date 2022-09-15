fx_version 'cerulean'
games { 'gta5' }

author 'devyn'

client_script "client/Main.lua"
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/Main.lua",
}

shared_script "shared/Config.lua"
lua54 'yes'