fx_version 'adamant'
games { 'gta5' };


client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",

    "src/components/*.lua",

    "src/menu/elements/*.lua",

    "src/menu/items/*.lua",

    "src/menu/panels/*.lua",

    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",

}



client_scripts {
	'NativeUI.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'serveur/serveur_garage.lua',
}

client_scripts {
	'config.lua',
	'client/client_garage.lua',
	'client/cl_gestion.lua',
	'client/cl_menu.lua',
	'client/cl_damage.lua',
    'client/cl_instance.lua',
    'client/cl_pc.lua',
}

client_scripts {
    "AC-Sync.lua",
}
