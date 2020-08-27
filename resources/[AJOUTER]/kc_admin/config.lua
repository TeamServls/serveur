
Groups = {}
Permissions = {}
Lang = {}
Lang.Global = {}
Config = {}

-- Config --

Config.AmbulanceJob = true

Config.WarnPerma = 10
Config.WarnWeek = 6
Config.WarnDays = 3

Config.Jails = {
    {x = 1641.64, y = 2571.08, z = 45.56},
    {x = 1651.03, y = 2570.78, z = 45.56}
}
Config.ExitFromJail = {["x"] = 1873.51, ["y"] = 2600.2, ["z"] = 45.67}
Config.MaxJailDistance = 20
Config.JailWarns = 2
Config.JailWarnsMinutes = 20

Config.CheckJobType = "false" -- esx/sql/false
Config.DefaultJob = {"unemployed", 0}

Config.SecurityCode = "674521"

-- Config --


Groups.Server       = "server" -- Comandos ejecutados desde el servidor
Groups.SuperAdmin   = "superadmin" -- Mas alto
Groups.Admin        = "admin"
Groups.Mod          = "mod"
Groups.Helper       = "helper"
Groups.User         = "user" -- Mas bajo


Groups.Levels = {[Groups.User] = 0, [Groups.Helper] = 1, [Groups.Mod] = 2, [Groups.Admin] = 3, [Groups.SuperAdmin] = 4, [Groups.Server] = 5}

-- Establecer los permisos de menos nivel a mas nivel --

-- Permisos --

Permissions.OpenMenu        = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.GetWarns        = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Warn            = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.DeleteWarn      = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Kick            = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Ban             = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.GetBans         = {Groups.SuperAdmin, Groups.Server}
Permissions.Bring           = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Goto            = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Return          = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Noclip          = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Visibility      = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Slay            = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Revive          = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Freeze          = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Jail            = {Groups.Mod, Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.UnJail          = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Money           = {Groups.SuperAdmin, Groups.Server}
Permissions.Jobs            = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Group           = {Groups.Admin, Groups.SuperAdmin, Groups.Server}
Permissions.Report          = {Groups.Mod, Groups.Admin, Groups.SuperAdmin}

-- Permisos --

-- Lenguaje --

Lang.Error                      = "Error"
Lang.Success                    = "Succès"
Lang.Minutes                    = "minutes"
Lang.Plus                       = "Plus"

Lang.Kicked                     = "L'utilisateur a été kick "
Lang.BannedSuccessfully         = "L'utilisateur a été banni correctement"
Lang.Warn                       = "Warn correctement appliqué à "
Lang.WarnDeleted                = "Warn supprimé avec succès par "
Lang.UnBan                      = "Le Ban a été supprimée"
Lang.ReturnPlayer               = " vous a ramené à votre emplacement précédent"
Lang.NoclipOn                   = "le noclip a été ^2activé^0"
Lang.NoclipOff                  = "le noclip a été ^1désactivé^0"
Lang.Noclip                     = "Noclip a été attribué/affecté à: "
Lang.Slay                       = "Tu es mort mystérieusement ;)"
Lang.Revive                     = "Tu es ressuscité des morts"
Lang.FreezeMsg                  = "Vous avez été ^1gelé^0"
Lang.UnFreezeMsg                = "Vous avez été ^2décongelé^0"
Lang.Warned                     = " ^1Il a appliqué un avertissement pour: "
Lang.WarnAccumulation           = "28/5000Accumulation d'avertissements. Warn: "
Lang.BannedFor                  = "Banni par: %s | Date d'expiration: %s | Appliqué par: %s"
Lang.PermaBan                   = "Banni par: %s | Date d'expiration: Jamais | Appliqué par: %s"
Lang.Banned                     = "Banni"
Lang.Bringed                    = "Vous avez été téléporté vers "
Lang.Goto                       = " vous a téléporté"
Lang.GotoN                      = "Vous avez été téléporté vers "
Lang.Return                     = "Le joueur a été renvoyé à son emplacement précédent"
Lang.Visibility                 = "Le joueur est visible/invisible pour les joueurs"
Lang.Slay                       = "Le joueur est décédé dans des circonstances étranges"
Lang.ReviveN                    = "Le joueur a été guéri et réanimé"
Lang.Freeze                     = "Le joueur a été congelé/décongelé correctement"
Lang.JailError                  = "Le lecteur n'a pas été verrouillé en raison d'une erreur interne"
Lang.UnJail                     = "Le joueur a été libéré de sa peine"
Lang.UnjailError                = "Le lecteur n'a pas été libéré en raison d'une erreur interne"
Lang.Jailed                     = "Vous avez été enfermé par "
Lang.UnJailed                   = "Vous avez purgé votre peine. Pas de ^1mensonges^0 en plus"
Lang.Jail                       = "Le joueur a été mis en Jail"
Lang.JailMaxWarns               = "Votre peine a été augmentée " .. tostring(Config.JailWarnsMinutes) .. " " .. Lang.Minutes .. " pour violation de celui-ci"
Lang.JailMaxDistance            = "N'essayez pas de vous échapper ou votre peine sera augmentée"
Lang.WarnError                  = "L'avertissement n'a pas pu être appliqué en raison d'une erreur interne"
Lang.WarnDeletedError           = "L'avertissement n'a pas pu être supprimé en raison d'une erreur interne"
Lang.BanError                   = "Échec de l'application du bannissement en raison d'une erreur interne"
Lang.UnBanError                 = "L'interdiction n'a pas pu être supprimée en raison d'une erreur interne"
Lang.ReturnError                = "Impossible de revenir à l'emplacement précédent car il n'existe pas"
Lang.Cash                       = "De l'argent a été ajouté au joueur de type: "
Lang.ESX                        = "Une erreur s'est produite lors de la connexion avec ESX"
Lang.JobFail                    = "Le job n'existe pas"
Lang.Job                        = "Travail changé en "
Lang.Money                      = "Le joueur a reçu de l'argent de type: "
Lang.JobFailKick                = "Il a été expulsé du serveur car son travail n'était pas valide"
Lang.GroupUpgraded              = "Le groupe a été créé: ^1"
Lang.Group                      = "Le groupe a été créé: "
Lang.GroupError                 = "Une erreur inattendue s'est produite et le groupe n'a pas pu être modifié"
Lang.FixJob                     = "Le travail par défaut a été défini sur "
Lang.JailedTime                 = "%s secondes pour purger ta peine"
Lang.ArgumentNeeded             = "Arguments manquants"
Lang.MySQL                      = "La base de données n'est pas encore connectée."
Lang.Report                     = "^0[^1Report^0] ^3%s^0 (^2%s^0) | %s"

Lang.InsufficientPrivileges     = "Vous ne disposez pas de privilèges suffisants"
Lang.SecurityGodMode            = "Il a été détecté que vous utilisez illégalement la fonction native SetPlayerInvincible"
Lang.SecurityWeapons            = "Il a été détecté que vous avez une arme non autorisée par le serveur"


Lang.Global.PlayerJailed        = "^1%s^0 est entré en prison pour %s minutes."
Lang.Global.PlayerBanned        = "^1%s^0 a été banni du serveur par: ^1%s^0."

-- Lenguaje --