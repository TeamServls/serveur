Config                    = {}
Config.Locale             = 'fr' --use (fr-en-br-de-es-sv)

SystemAvatar = 'https://wiki.fivem.net/w/images/d/db/FiveM-Wiki.png'

UserAvatar = 'https://i.imgur.com/KIcqSYs.png'

SystemName = 'PRL Serv - LOG SYSTEM'


SpecialCommands = {
	{'/ooc', '**[OOC]:**'},
	{'/911', '**[911]: (CALLER ID: [ USERNAME_NEEDED_HERE | USERID_NEEDED_HERE ])**'},
   }

		 
-- These blacklisted commands will not be printed in discord
BlacklistedCommands = {
		'/AnyCommand',
		'/AnyCommand2',
	   }

-- These Commands will use their own webhook

-- These Commands will be sent as TTS messages
TTSCommands = {
'/Whatever',
'/Whatever2',
}