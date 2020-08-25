fx_version 'adamant'
games { 'gta5' };


server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
    'sv.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    "pmenu.lua",
    "cl_charcreator.lua",
}
files {
    'html/ui.html',
    'html/img/image.png',
    'html/css/app.css',
    'html/scripts/app.js'
}

ui_page 'html/ui.html'