fx_version 'cerulean'
games { 'gta5' }

author 'Dexvo and Badger'
description 'BetterDonationRewards'
version '1.0.0'

client_scripts {
	"client.lua"
}
shared_scripts {
	"config.lua"
}
server_scripts {
	"server.lua",
	"@mysql-async/lib/MySQL.lua"
}

dependency 'Badger_Discord_API'