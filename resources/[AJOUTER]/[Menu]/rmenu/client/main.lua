ESX = nil

local PersonalMenu = {
	ItemSelected = {},
	ItemIndex = {},
	WeaponData = {},
	WalletIndex = {},
	WalletList = {_U('wallet_option_give')--[[,_U('wallet_option_drop')]]},
	BillData = {},
	ClothesButtons = {'tshirt', 'torso', 'pants', 'shoes', 'bag', 'bproof', 'watches', 'bracelet'},
	AccessoriesButtons = {'Ears', 'Glasses', 'Helmet', 'Mask'},
	DoorState = {
		FrontLeft = false,
		FrontRight = false,
		BackLeft = false,
		BackRight = false,
		Hood = false,
		Trunk = false
	},
	DoorIndex = 1,
	DoorList = {_U('vehicle_door_frontleft'), _U('vehicle_door_frontright'), _U('vehicle_door_backleft'), _U('vehicle_door_backright')},
	GPSIndex = 1,
	GPSList = {},
	VoiceIndex = 2,
	VoiceList = {}
}

Player = {
	isDead = false,
	inAnim = false,
	crouched = false,
	handsup = false,
	pointing = false,
	noclip = false,
	godmode = false,
	ghostmode = false,
	showCoords = false,
	showName = false,
	showblips = false,
	gamerTags = {},
	group = 'user'
}

---animation porter
local carryingBackInProgress = false
local carryAnimNamePlaying = ""
local carryAnimDictPlaying = ""
local carryControlFlagPlaying = 0

local societymoney, societymoney2 = nil, nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	if Config.DoubleJob then
		while ESX.GetPlayerData().job2 == nil do
			Citizen.Wait(10)
		end
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while actualSkin == nil do
		TriggerEvent('skinchanger:getSkin', function(skin)
			actualSkin = skin
		end)

		Citizen.Wait(10)
	end

	RefreshMoney()

	if Config.DoubleJob then
		RefreshMoney2()
	end

	PersonalMenu.WeaponData = ESX.GetWeaponList()

	for i = 1, #PersonalMenu.WeaponData, 1 do
		if PersonalMenu.WeaponData[i].name == 'WEAPON_UNARMED' then
			PersonalMenu.WeaponData[i] = nil
		else
			PersonalMenu.WeaponData[i].hash = GetHashKey(PersonalMenu.WeaponData[i].name)
		end
	end

	for i = 1, #Config.GPS, 1 do
		table.insert(PersonalMenu.GPSList, Config.GPS[i].label)
	end

	RMenu.Add('rageui', 'personal', RageUI.CreateMenu(Config.MenuTitle, _U('mainmenu_subtitle'), 0, 0, 'commonmenu1', 'interaction_bgd1', 255, 255, 255, 255))

	RMenu.Add('personal', 'inventory', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('inventory_title')))
	RMenu.Add('personal', 'loadout', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('loadout_title')))
	RMenu.Add('personal', 'wallet', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('wallet_title')))
	RMenu.Add('personal', 'billing', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('bills_title')))
	RMenu.Add('personal', 'clothes', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('clothes_title')))
	RMenu.Add('personal', 'accessories', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('accessories_title')))
	RMenu.Add('personal', 'animation', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('animation_title')))
	RMenu.Add('personal', 'vehicle', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('vehicle_title')), function()
		if IsPedSittingInAnyVehicle(plyPed) then
			if (GetPedInVehicleSeat(GetVehiclePedIsIn(plyPed, false), -1) == plyPed) then
				return true
			end
		end

		return false
	end)

	RMenu.Add('personal', 'boss', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('bossmanagement_title')), function()
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
			return true
		end

		return false
	end)

	if Config.DoubleJob then
		RMenu.Add('personal', 'boss2', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('bossmanagement2_title')), function()
			if Config.DoubleJob then
				if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
					return true
				end
			end

			return false
		end)
	end

	RMenu.Add('personal', 'divers', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), ('🔩 Divers')))
	RMenu.Add('personal', 'vision', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), ('🔩 Optimisation/Couleurs')))

	RMenu.Add('personal', 'admin', RageUI.CreateSubMenu(RMenu.Get('rageui', 'personal'), _U('admin_title')), function()
		if Player.group ~= nil and (Player.group == 'mod' or Player.group == 'admin' or Player.group == 'superadmin' or Player.group == 'owner' or Player.group == '_dev') then
			return true
		end

		return false
	end)

	RMenu.Add('inventory', 'actions', RageUI.CreateSubMenu(RMenu.Get('personal', 'inventory'), _U('inventory_actions_title')))
	RMenu.Get('inventory', 'actions').Closed = function()
		PersonalMenu.ItemSelected = nil
	end

	RMenu.Add('loadout', 'actions', RageUI.CreateSubMenu(RMenu.Get('personal', 'loadout'), _U('loadout_actions_title')))
	RMenu.Get('loadout', 'actions').Closed = function()
		PersonalMenu.ItemSelected = nil
	end

	for i = 1, #Config.Animations, 1 do
		RMenu.Add('animation', Config.Animations[i].name, RageUI.CreateSubMenu(RMenu.Get('personal', 'animation'), Config.Animations[i].label))
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

AddEventHandler('esx:onPlayerDeath', function()
	Player.isDead = true
	RageUI.CloseAll()
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('playerSpawned', function()
	Player.isDead = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		UpdateSocietyMoney(money)
	end
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		UpdateSociety2Money(money)
	end
end)

-- Weapon Menu --
RegisterNetEvent('KorioZ-PersonalMenu:munition')
AddEventHandler('KorioZ-PersonalMenu:munition', function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)

-- Admin Menu --
RegisterNetEvent('KorioZ-PersonalMenu:tele')
AddEventHandler('KorioZ-PersonalMenu:tele', function(plyCoords)
	SetEntityCoords(plyPed, plyCoords)
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSocietyMoney(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSociety2Money(money)
		end, ESX.PlayerData.job2.name)
	end
end

function UpdateSocietyMoney(money)
	societymoney = ESX.Math.GroupDigits(money)
end

function UpdateSociety2Money(money)
	societymoney2 = ESX.Math.GroupDigits(money)
end

--Message text joueur
function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.017, 0.977)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end

function startAttitude(lib, anim)
	ESX.Streaming.RequestAnimSet(anim, function()
		SetPedMotionBlur(plyPed, false)
		SetPedMovementClipset(plyPed, anim, true)
		RemoveAnimSet(anim)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
		RemoveAnimDict(lib)
	end)
end

function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		RemoveAnimDict(lib)
	end)
end

function setUniform(value, plyPed)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:getSkin', function(skina)
		if value == 'tshirt' then
			startAnimAction("clothingtie", "try_tie_neutral_a")
			Citizen.Wait(1000)
			Player.handsup, Player.pointing = false, false
			ClearPedTasks(plyPed)

			if skin.tshirt_1 ~= skina.tshirt_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['tshirt_1'] = skin.tshirt_1, ['tshirt_2'] = skin.tshirt_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['tshirt_1'] = 15, ['tshirt_2'] = 0})
				end
			elseif value == 'torso' then
				startAnimAction("clothingtie", "try_tie_neutral_a")
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

			if skin.torso_1 ~= skina.torso_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = skin.torso_1, ['torso_2'] = skin.torso_2, ['arms'] = skin.arms})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = 15, ['torso_2'] = 0, ['arms'] = 15})
				end
			elseif value == 'pants' then
				if skin.pants_1 ~= skina.pants_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = skin.pants_1, ['pants_2'] = skin.pants_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 61, ['pants_2'] = 1})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 15, ['pants_2'] = 0})
					end
				end
			elseif value == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = skin.shoes_1, ['shoes_2'] = skin.shoes_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 34, ['shoes_2'] = 0})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 35, ['shoes_2'] = 0})
					end
				end
			elseif value == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = skin.bags_1, ['bags_2'] = skin.bags_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = 0, ['bags_2'] = 0})
				end
			elseif value == 'bproof' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = skin.bproof_1, ['bproof_2'] = skin.bproof_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = 0, ['bproof_2'] = 0})
				end
			elseif value == 'watches' then
				startAnimAction("clothingtie", "try_tie_neutral_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.watches_1 ~= skina.watches_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['watches_1'] = skin.watches_1, ['watches_2'] = skin.watches_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['watches_1'] = -1, ['watches_2'] = -1})
				end
			elseif value == 'bracelet' then
				startAnimAction("clothingtie", "try_tie_neutral_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.bracelets_1 ~= skina.bracelets_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bracelets_1'] = skin.bracelets_1})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bracelets_1'] = -1})
				end
			end
		end)
	end)
end

function setAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = (accessory):lower()

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
					startAnimAction('mini@ears_defenders', 'takeoff_earsdefenders_idle')
					Citizen.Wait(250)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'glasses' then
					mAccessory = 0
					startAnimAction('clothingspecs', 'try_glasses_positive_a')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'mask' then
					mAccessory = 0
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(850)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Accessoires', _U('accessories_no_ears'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
			elseif _accessory == 'glasses' then
				TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Accessoires', _U('accessories_no_glasses'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
			elseif _accessory == 'helmet' then
				TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Accessoires', _U('accessories_no_helmet'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
			elseif _accessory == 'mask' then
				TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Accessoires', _U('accessories_no_mask'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
			end
		end
	end, accessory)
end

function CheckQuantity(number)
	number = tonumber(number)

	if type(number) == 'number' then
		number = ESX.Math.Round(number)

		if number > 0 then
			return true, number
		end
	end

	return false, number
end

function RenderPersonalMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #RMenu['personal'], 1 do
			if type(RMenu['personal'][i].Restriction) == 'function' then
				if RMenu['personal'][i].Restriction() then
					RageUI.Button(RMenu['personal'][i].Menu.Title, nil, {RightLabel = ""}, true, function() end, RMenu['personal'][i].Menu)
				else
					RageUI.Button(RMenu['personal'][i].Menu.Title, nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, function() end, RMenu['personal'][i].Menu)
				end
			else
				RageUI.Button(RMenu['personal'][i].Menu.Title, nil, {RightLabel = ""}, true, function() end, RMenu['personal'][i].Menu)
			end
		end

		RageUI.List(_U('mainmenu_gps_button'), PersonalMenu.GPSList, PersonalMenu.GPSIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
			if (Selected) then
				if Config.GPS[Index].coords ~= nil then
					SetNewWaypoint(Config.GPS[Index].coords)
				else
					DeleteWaypoint()
				end

				TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'GPS', _U('gps', Config.GPS[Index].label), 'CHAR_SOCIAL_CLUB', 'logo', 8)
			end

			PersonalMenu.GPSIndex = Index
		end)
	end)
end

function RenderActionsMenu(type)
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if type == 'inventory' then
			RageUI.Button(_U('inventory_use_button'), "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					if PersonalMenu.ItemSelected.usable then
						TriggerServerEvent('esx:useItem', PersonalMenu.ItemSelected.name)
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('not_usable', PersonalMenu.ItemSelected.label), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)
		

			RageUI.Button(_U('inventory_give_button'), "", {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3 then
						local closestPed = GetPlayerPed(closestPlayer)

						if not IsPedSittingInAnyVehicle(closestPed) then
							if PersonalMenu.ItemIndex[PersonalMenu.ItemSelected.name] ~= nil and PersonalMenu.ItemSelected.count > 0 then
								TriggerServerEvent('esx:donneItem', GetPlayerServerId(closestPlayer), 'item_standard', PersonalMenu.ItemSelected.name, PersonalMenu.ItemIndex[PersonalMenu.ItemSelected.name])
								RageUI.CloseAll()
							else
								TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('amount_invalid'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
							end
						else
							TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('in_vehicle_give', PersonalMenu.ItemSelected.label), 'CHAR_SOCIAL_CLUB', 'logo', 8)
						end
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)

		elseif type == 'loadout' then
			if HasPedGotWeapon(plyPed, PersonalMenu.ItemSelected.hash, false) then
				RageUI.Button(_U('loadout_give_button'), "", {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestDistance ~= -1 and closestDistance <= 3 then
							local closestPed = GetPlayerPed(closestPlayer)

							if not IsPedSittingInAnyVehicle(closestPed) then
								local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.ItemSelected.hash)
								TriggerServerEvent('esx:donneItem', GetPlayerServerId(closestPlayer), 'item_weapon', PersonalMenu.ItemSelected.name, ammo)
								RageUI.CloseAll()
							else
								TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('in_vehicle_give', PersonalMenu.ItemSelected.label), 'CHAR_SOCIAL_CLUB', 'logo', 8)
							end
						else
							TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Inventaire', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
						end
					end
				end)

				RageUI.Button(_U('loadout_givemun_button'), "", {RightBadge = RageUI.BadgeStyle.Ammo}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMMO_AMOUNT', _U('dialogbox_amount_ammo'), '', 8))

						if post then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

							if closestDistance ~= -1 and closestDistance <= 3 then
								local closestPed = GetPlayerPed(closestPlayer)

								if not IsPedSittingInAnyVehicle(closestPed) then
									local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.ItemSelected.hash)

									if ammo > 0 then
										if quantity <= ammo and quantity >= 0 then
											local finalAmmo = math.floor(ammo - quantity)
											SetPedAmmo(plyPed, PersonalMenu.ItemSelected.name, finalAmmo)

											TriggerServerEvent('KorioZ-PersonalMenu:munitionserver', GetPlayerServerId(closestPlayer), PersonalMenu.ItemSelected.name, quantity)
											TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('gave_ammo', quantity, GetPlayerName(closestPlayer)), 'CHAR_SOCIAL_CLUB', 'logo', 8)
											RageUI.CloseAll()
										else
											TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('not_enough_ammo'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
										end
									else
										TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('no_ammo'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
									end
								else
									TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('in_vehicle_give', PersonalMenu.ItemSelected.label), 'CHAR_SOCIAL_CLUB', 'logo', 8)
								end
							else
								TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
							end
						else
							TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Gestion Armes', _U('amount_invalid'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
						end
					end
				end)
			else
				RageUI.GoBack()
			end
		end
	end)
end

function RenderInventoryMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #ESX.PlayerData.inventory, 1 do
			if ESX.PlayerData.inventory[i].count > 0 then
				local invCount = {}

				for i = 1, ESX.PlayerData.inventory[i].count, 1 do
					table.insert(invCount, i)
				end

				RageUI.List(ESX.PlayerData.inventory[i].label .. ' (' .. ESX.PlayerData.inventory[i].count .. ')', invCount, PersonalMenu.ItemIndex[ESX.PlayerData.inventory[i].name] or 1, nil, {}, true, function(Hovered, Active, Selected, Index)
					if (Selected) then
						PersonalMenu.ItemSelected = ESX.PlayerData.inventory[i]
					end

					PersonalMenu.ItemIndex[ESX.PlayerData.inventory[i].name] = Index
				end, RMenu.Get('inventory', 'actions'))
			end
		end
	end)
end

function RenderWeaponMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.WeaponData, 1 do
			if HasPedGotWeapon(plyPed, PersonalMenu.WeaponData[i].hash, false) then
				local ammo = GetAmmoInPedWeapon(plyPed, PersonalMenu.WeaponData[i].hash)

				RageUI.Button(PersonalMenu.WeaponData[i].label .. ' [' .. ammo .. ']', nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
					if (Selected) then
						PersonalMenu.ItemSelected = PersonalMenu.WeaponData[i]
					end
				end, RMenu.Get('loadout', 'actions'))
			end
		end
	end)
end

function RenderAccessoiresNewMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()

		RageUI.Button(('Mes Accessoires'), "Gère tout tes accessoires", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
			if (Selected) then
				TriggerEvent('esx_accessories:openmenu')
				RageUI.CloseAll()
			end
		end)
	end)
end

function RenderWalletMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()

		RageUI.Button(('Mes Cartes SIM'), "Gère toutes tes carte SIM", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
			if (Selected) then
				OpenSIMTkt()
				RageUI.CloseAll()
			end
		end)

		RageUI.Button((''), "", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
			end
		end)
		
		RageUI.Button(_U('wallet_job_button', ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label), nil, {}, true, function() end)

		if Config.DoubleJob then
			RageUI.Button(_U('wallet_job2_button', ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label), nil, {}, true, function() end)
		end

		for i = 1, #ESX.PlayerData.accounts, 1 do
			if ESX.PlayerData.accounts[i].name == 'money' then
				if PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] == nil then PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] = 1 end
				RageUI.List(_U('wallet_money_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), PersonalMenu.WalletList, PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] or 1, nil, {}, true, function(Hovered, Active, Selected, Index)
					if (Selected) then
						if Index == 1 then
							local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8))

							if post then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

								if closestDistance ~= -1 and closestDistance <= 3 then
									local closestPed = GetPlayerPed(closestPlayer)

									if not IsPedSittingInAnyVehicle(closestPed) then
										TriggerServerEvent('esx:donneItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)
										RageUI.CloseAll()
									else
										ESX.ShowNotification(_U('in_vehicle_give', 'de l\'argent'))
									end
								else
									ESX.ShowNotification(_U('players_nearby'))
								end
							else
								ESX.ShowNotification(_U('amount_invalid'))
							end
						elseif Index == 2 then
							local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8))

							if post then
								if not IsPedSittingInAnyVehicle(plyPed) then
									TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
									RageUI.CloseAll()
								else
									ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent'))
								end
							else
								ESX.ShowNotification(_U('amount_invalid'))
							end
						end
					end

					PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] = Index
				end)
			end

			if ESX.PlayerData.accounts[i].name == 'bank' then
				RageUI.Button(_U('wallet_bankmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), nil, {}, true, function() end)
			end

			if ESX.PlayerData.accounts[i].name == 'black_money' then
				if PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] == nil then PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] = 1 end
				RageUI.List(_U('wallet_blackmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), PersonalMenu.WalletList, PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] or 1, nil, {}, true, function(Hovered, Active, Selected, Index)
					if (Selected) then
						if Index == 1 then
							local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8))

							if post then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

								if closestDistance ~= -1 and closestDistance <= 3 then
									local closestPed = GetPlayerPed(closestPlayer)

									if not IsPedSittingInAnyVehicle(closestPed) then
										TriggerServerEvent('esx:donneItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)
										RageUI.CloseAll()
									else
										TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('in_vehicle_give', 'de l\'argent'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
									end
								else
									TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
								end
							else
								TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('amount_invalid'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
							end
						elseif Index == 2 then
							local post, quantity = CheckQuantity(KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8))

							if post then
								if not IsPedSittingInAnyVehicle(plyPed) then
									TriggerServerEvent('esx:retirerItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
									RageUI.CloseAll()
								else
									TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('in_vehicle_drop', 'de l\'argent'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
								end
							else
								TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('amount_invalid'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
							end
						end
					end

					PersonalMenu.WalletIndex[ESX.PlayerData.accounts[i].name] = Index
				end)
			end
		end

		if Config.JSFourIDCard then
			RageUI.Button(_U('wallet_show_idcard_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)

			RageUI.Button(_U('wallet_check_idcard_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
				end
			end)

			RageUI.Button(_U('wallet_show_driver_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)

			RageUI.Button(_U('wallet_check_driver_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
				end
			end)

			RageUI.Button(_U('wallet_show_firearms_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Portefeuilles', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)

			RageUI.Button(_U('wallet_check_firearms_button'), nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
				end
			end)
		end
	end)
end

function RenderBillingMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.BillData, 1 do
			RageUI.Button(PersonalMenu.BillData[i].label, nil, {RightLabel = '$' .. ESX.Math.GroupDigits(PersonalMenu.BillData[i].amount)}, true, function(Hovered, Active, Selected)
				if (Selected) then
					ESX.TriggerServerCallback('esx_billing:payBill', function()
						ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills)
							PersonalMenu.BillData = bills
						end)
					end, PersonalMenu.BillData[i].id)
				end
			end)
		end
	end)
end

function RenderClothesMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.ClothesButtons, 1 do
			RageUI.Button(_U(('clothes_%s'):format(PersonalMenu.ClothesButtons[i])), nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active, Selected)
				if (Selected) then
					setUniform(PersonalMenu.ClothesButtons[i], plyPed)
				end
			end)
		end
	end)
end

function RenderAccessoriesMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #PersonalMenu.AccessoriesButtons, 1 do
			RageUI.Button(_U(('accessories_%s'):format((PersonalMenu.AccessoriesButtons[i]:lower()))), nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, function(Hovered, Active, Selected)
				if (Selected) then
					setAccessory(PersonalMenu.AccessoriesButtons[i])
				end
			end)
		end
	end)
end

-- Dormir/Se Réveiller
local ragdoll = false
  function setRagdoll(flag)
	ragdoll = flag
  end
  Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
	  if ragdoll then
		SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
	  end
	end
  end)
  
  ragdol = true
  RegisterNetEvent("Ragdoll")
  AddEventHandler("Ragdoll", function()
	  if ( ragdol ) then
		  setRagdoll(true)
		  ragdol = false
	  else
		  setRagdoll(false)
		  ragdol = true
	  end
  end)

function Ragdoll()
	TriggerEvent("Ragdoll", source)
end

-- GPS/GPS OFF
RegisterNetEvent('no_hud:GPSACTIVE')
AddEventHandler('no_hud:GPSACTIVE', function()
	DisplayRadar(true)
end)

RegisterNetEvent('no_hud:GPSDESACTIVE')
AddEventHandler('no_hud:GPSDESACTIVE', function()
	DisplayRadar(false)
end)

local interface = true
 function openInterface()
	interface = not interface
	if not interface then -- hide
		TriggerEvent('ui:toggle', false)
	elseif interface then -- show
	  	TriggerEvent('ui:toggle', true)
	end
 end

local hasCinematic = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPauseMenuActive() then
			ESX.UI.HUD.SetDisplay(0.0)
		elseif hasCinematic == true then
			ESX.UI.HUD.SetDisplay(0.0)
		end
	end
end)

function Cinematique()
	hasCinematic = not hasCinematic

	if not hasCinematic then -- show
		SendNUIMessage({openCinema = true})
		ESX.UI.HUD.SetDisplay(0.0)
		TriggerEvent('es:setMoneyDisplay', 0.0)
		TriggerEvent('esx_status:setDisplay', 0.0)
		DisplayRadar(false)

	elseif hasCinematic then -- hide
		SendNUIMessage({openCinema = false})
		ESX.UI.HUD.SetDisplay(1.0)
		TriggerEvent('es:setMoneyDisplay', 1.0)
		TriggerEvent('esx_status:setDisplay', 1.0)
		DisplayRadar(true)
	end
 end


local audioTroisD = false
function RenderDiversMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()

		--[[RageUI.Button(('Porter | Lacher'), "Porter ou Lacher une personne", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				TriggerEvent('RiZiePersoMenu:porter')
			end
		end)]]

		RageUI.Button(('Dormir | Se Réveiller'), "Dormir ou Se Réveiller", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				Ragdoll()
			end
		end)

		RageUI.Button(('Afficher | Cacher le GPS'), "Afficher/Cacher le GPS", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if not radar then
					RageUI.Popup({message = "Radar ~g~Affiché"})
					DisplayRadar(true)
					radar = true
				else
					RageUI.Popup({message = "Radar ~r~Caché"})
					DisplayRadar(false)
					radar = false
				end
			end
		end)

		RageUI.Button(('Activer/Désactiver Mode Cinématique'), "Afficher/Cacher le Mode Cinématique", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				--Cinematique()
				if not cinematique then
					RageUI.Popup({message = "Mode Cinématique ~g~Affiché"})
					SendNUIMessage({openCinema = true})
					ESX.UI.HUD.SetDisplay(0.0)
					TriggerEvent('es:setMoneyDisplay', 0.0)
					TriggerEvent('esx_status:setDisplay', 0.0)
					DisplayRadar(false)
					TriggerEvent('ui:toggle', false)
					TriggerEvent('ui:togglevoit', false)
					cinematique = true
				else
					RageUI.Popup({message = "Mode Cinématique ~r~Caché"})
					SendNUIMessage({openCinema = false})
					ESX.UI.HUD.SetDisplay(1.0)
					TriggerEvent('es:setMoneyDisplay', 1.0)
					TriggerEvent('esx_status:setDisplay', 1.0)
					DisplayRadar(true)
					TriggerEvent('ui:toggle', true)
					TriggerEvent('ui:togglevoit', true)
					cinematique = false
				end
			end
		end)

		--[[
		RageUI.Button(('Activer/Désactiver l\'HUD'), "Afficher/Cacher l'HUD", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				--Cinematique()
				if not cinematique then
					RageUI.Popup({message = "HUD ~g~Caché"})
					ESX.UI.HUD.SetDisplay(0.0)
					TriggerEvent('es:setMoneyDisplay', 0.0)
					TriggerEvent('esx_status:setDisplay', 0.0)
					DisplayRadar(false)
					TriggerEvent('ui:toggle', false)
					TriggerEvent('ui:togglevoit', false)
					cinematique = true
				else
					RageUI.Popup({message = "HUD ~r~Affiché"})
					ESX.UI.HUD.SetDisplay(1.0)
					TriggerEvent('es:setMoneyDisplay', 1.0)
					TriggerEvent('esx_status:setDisplay', 1.0)
					DisplayRadar(true)
					TriggerEvent('ui:toggle', true)
					TriggerEvent('ui:togglevoit', true)
					cinematique = false
				end
			end
		end)

		RageUI.Button(('Activer/Désactiver le vocal 3D'), "ATTENTION ! Pour certaine personne le vocal 3D fait instant crash, pour d'autre, ça ne marchera juste pas !", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if not audioTroisD then
					RageUI.Popup({message = "Vocal 3D ~g~ON !"})
					ExecuteCommand("3don")
					print(GetConvar("voice_use3dAudio"))
					audioTroisD = true
				else
					RageUI.Popup({message = "Vocal 3D ~r~OFF !"})
					audioTroisD = false
					ExecuteCommand("3doff")
					print(GetConvar("voice_use3dAudio"))
				end
			end
		end)]]

		RageUI.Button(('Nombre de Joueur(s)'), "Dormir ou Se Réveiller", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				RageUI.Popup({message = 'Il y a '.. TouslesJoueursCO() ..' joueurs connectés'})
			end
		end)

		RageUI.Button("Voir son ID", "Voir son ID sans déranger les admins !", {}, true, function(Hovered, Active, Selected)
            if (Selected) then
				RageUI.Popup({message = '~b~Bonjour ~g~'.. GetPlayerName(PlayerId()) ..' ~b~, ton ID est le ~g~Numéro ~r~'.. GetPlayerServerId(PlayerId()) ..' ~b~!'})
            end
        end)

		--[[RageUI.Button(('Sauvegarder votre personnage (SKIN)'), "Sauvegarde votre personnage !", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				TriggerServerEvent('esx_skin:save', skin)
				RageUI.Popup({message = "✅ ~g~Personnage Sauvegarder !"})
			end
		end)]]
	end)
end


function RenderDiversMenuMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()

		RageUI.Button("Vision Normal", "Changer la Vue en Normal !", {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                SetTimecycleModifier('')
            end
		end)
		
        RageUI.Button("Vue & lumières améliorées", "Changer la Vue en Amélioré !", {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                SetTimecycleModifier('tunnel')
            end
		end)
		
        RageUI.Button("Couleurs amplifiées", "Changer la Vue en Couleurs Amplifiées !", {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                SetTimecycleModifier('rply_saturation')
            end
		end)
		
        RageUI.Button("Noir & blancs", "Changer la Vue en Noir et Blancs !", {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                SetTimecycleModifier('rply_saturation_neg')
            end
		end)
		
		RageUI.Button("Optimisation", "Optimisation de vos FPS.", { RightBadge = RageUI.BadgeStyle.Tick, Color = {BackgroundColor = { 0, 120, 0, 25 }} }, true, function(Hovered, Active, Selected)
            if (Selected) then
                        DoScreenFadeIn(2000) -- Ecran Noir
                        LoadingPrompt("Optimisation en cours...", 3)
                        DoScreenFadeOut(2000)  -- Ecran Noir
                        Citizen.Wait(2000)
                        DoScreenFadeIn(1500) -- Ecran Noir
                        ClearAllBrokenGlass()
                        ClearAllHelpMessages()
                        LeaderboardsReadClearAll()
                        ClearBrief()
                        ClearGpsFlags()
                        ClearPrints()
                        ClearSmallPrints()
                        ClearReplayStats()
                        LeaderboardsClearCacheData()
                        ClearFocus()
                        ClearHdArea()
                        ClearHelp()
                        ClearNotificationsPos()
                        ClearPedInPauseMenu()
                        ClearFloatingHelp()
                        ClearGpsPlayerWaypoint()
                        ClearGpsRaceTrack()
                        ClearReminderMessage()
                        ClearThisPrint()
                        Citizen.Wait(2090)
                        RemoveLoadingPrompt()
                        Citizen.Wait(100)
                        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
					end
				end)
			end)
		end

RegisterCommand("3don", function(source, args, rawCommand)
    ExecuteCommand("voice_use3dAudio 1")
end, false)

RegisterCommand("3doff", function(source, args, rawCommand)
    ExecuteCommand("voice_use3dAudio 0")
end, false)

--[[function RenderAnimationMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #RMenu['animation'], 1 do
			RageUI.Button(RMenu['animation'][i].Menu.Title, nil, {RightLabel = ""}, true, function() end, RMenu['animation'][i].Menu)
		end
	end)
end]]

function RenderAnimationMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		RageUI.Button(('Animations'), "Jouez des Animations !", {RightBadge = RageUI.BadgeStyle.None}, true, function(Hovered, Active, Selected)
			if (Selected) then
				exports["dpemotes"]:OpenEmoteMenu1()
				RageUI.CloseAll()
				ESX.UI.Menu.CloseAll()
			end
		end)
	end)
end

function RenderAnimationsSubMenu(menu)
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #Config.Animations, 1 do
			if Config.Animations[i].name == menu then
				for j = 1, #Config.Animations[i].items, 1 do
					RageUI.Button(Config.Animations[i].items[j].label, nil, {}, true, function(Hovered, Active, Selected)
						if (Selected) then
							if Config.Animations[i].items[j].type == 'anim' then
								startAnim(Config.Animations[i].items[j].data.lib, Config.Animations[i].items[j].data.anim)
							elseif Config.Animations[i].items[j].type == 'scenario' then
								TaskStartScenarioInPlace(plyPed, Config.Animations[i].items[j].data.anim, 0, false)
							elseif Config.Animations[i].items[j].type == 'attitude' then
								startAttitude(Config.Animations[i].items[j].data.lib, Config.Animations[i].items[j].data.anim)
							end
						end
					end)
				end
			end
		end
	end)
end

function RenderVehicleMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		RageUI.Button(_U('vehicle_engine_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if not IsPedSittingInAnyVehicle(plyPed) then
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Véhicule', _U('no_vehicle'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				elseif IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if GetIsVehicleEngineRunning(plyVeh) then
						SetVehicleEngineOn(plyVeh, false, false, true)
						SetVehicleUndriveable(plyVeh, true)
					elseif not GetIsVehicleEngineRunning(plyVeh) then
						SetVehicleEngineOn(plyVeh, true, false, true)
						SetVehicleUndriveable(plyVeh, false)
					end
				end
			end
		end)

		RageUI.List(_U('vehicle_door_button'), PersonalMenu.DoorList, PersonalMenu.DoorIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
			if (Selected) then
				if not IsPedSittingInAnyVehicle(plyPed) then
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Véhicule', _U('no_vehicle'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				elseif IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if Index == 1 then
						if not PersonalMenu.DoorState.FrontLeft then
							PersonalMenu.DoorState.FrontLeft = true
							SetVehicleDoorOpen(plyVeh, 0, false, false)
						elseif PersonalMenu.DoorState.FrontLeft then
							PersonalMenu.DoorState.FrontLeft = false
							SetVehicleDoorShut(plyVeh, 0, false, false)
						end
					elseif Index == 2 then
						if not PersonalMenu.DoorState.FrontRight then
							PersonalMenu.DoorState.FrontRight = true
							SetVehicleDoorOpen(plyVeh, 1, false, false)
						elseif PersonalMenu.DoorState.FrontRight then
							PersonalMenu.DoorState.FrontRight = false
							SetVehicleDoorShut(plyVeh, 1, false, false)
						end
					elseif Index == 3 then
						if not PersonalMenu.DoorState.BackLeft then
							PersonalMenu.DoorState.BackLeft = true
							SetVehicleDoorOpen(plyVeh, 2, false, false)
						elseif PersonalMenu.DoorState.BackLeft then
							PersonalMenu.DoorState.BackLeft = false
							SetVehicleDoorShut(plyVeh, 2, false, false)
						end
					elseif Index == 4 then
						if not PersonalMenu.DoorState.BackRight then
							PersonalMenu.DoorState.BackRight = true
							SetVehicleDoorOpen(plyVeh, 3, false, false)
						elseif PersonalMenu.DoorState.BackRight then
							PersonalMenu.DoorState.BackRight = false
							SetVehicleDoorShut(plyVeh, 3, false, false)
						end
					end
				end
			end

			PersonalMenu.DoorIndex = Index
		end)

		RageUI.Button(_U('vehicle_hood_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if not IsPedSittingInAnyVehicle(plyPed) then
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Véhicule', _U('no_vehicle'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				elseif IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if not PersonalMenu.DoorState.Hood then
						PersonalMenu.DoorState.Hood = true
						SetVehicleDoorOpen(plyVeh, 4, false, false)
					elseif PersonalMenu.DoorState.Hood then
						PersonalMenu.DoorState.Hood = false
						SetVehicleDoorShut(plyVeh, 4, false, false)
					end
				end
			end
		end)

		RageUI.Button(_U('vehicle_trunk_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if not IsPedSittingInAnyVehicle(plyPed) then
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Véhicule', _U('no_vehicle'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				elseif IsPedSittingInAnyVehicle(plyPed) then
					local plyVeh = GetVehiclePedIsIn(plyPed, false)

					if not PersonalMenu.DoorState.Trunk then
						PersonalMenu.DoorState.Trunk = true
						SetVehicleDoorOpen(plyVeh, 5, false, false)
					elseif PersonalMenu.DoorState.Trunk then
						PersonalMenu.DoorState.Trunk = false
						SetVehicleDoorShut(plyVeh, 5, false, false)
					end
				end
			end
		end)
	end)
end

function RenderBossMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if societymoney ~= nil then
			RageUI.Button(_U('bossmanagement_chest_button'), nil, {RightLabel = '$' .. societymoney}, true, function() end)
		end

		RageUI.Button(_U('bossmanagement_hire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_recruterplayer', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_fire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_virerplayer', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_promote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_promouvoirplayer', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement_demote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_promouvoirplayer', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)
	end)
end

function RenderBoss2Menu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		if societymoney ~= nil then
			RageUI.Button(_U('bossmanagement2_chest_button'), nil, {RightLabel = '$' .. societymoney2}, true, function() end)
		end

		RageUI.Button(_U('bossmanagement2_hire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Organisation', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_recruterplayer2', GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name, 0)
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_fire_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_virerplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_promote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_promouvoirplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)

		RageUI.Button(_U('bossmanagement2_demote_button'), nil, {}, true, function(Hovered, Active, Selected)
			if (Selected) then
				if ESX.PlayerData.job2.grade_name == 'boss' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('players_nearby'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					else
						TriggerServerEvent('KorioZ-PersonalMenu:patron_promouvoirplayer2', GetPlayerServerId(closestPlayer))
					end
				else
					TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Entreprise', _U('missing_rights'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
				end
			end
		end)
	end)
end

function RenderAdminMenu()
	RageUI.DrawContent({header = true, instructionalButton = true}, function()
		for i = 1, #Config.Admin, 1 do
			local authorized = false

			for j = 1, #Config.Admin[i].groups, 1 do
				if Config.Admin[i].groups[j] == Player.group then
					authorized = true
				end
			end

			if authorized then
				RageUI.Button(Config.Admin[i].label, nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						Config.Admin[i].command()
					end
				end)
			else
				RageUI.Button(Config.Admin[i].label, nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, function() end)
			end
		end
	end)
end

RegisterNetEvent("MENU:GetInfoClient")
AddEventHandler("MENU:GetInfoClient", function(_bills, group)
	Player.group = group
	PersonalMenu.BillData = _bills
	print(#PersonalMenu.BillData)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, Config.Controls.OpenMenu.keyboard) and not Player.isDead then
			if not RageUI.Visible() then
				TriggerServerEvent("MENU:GetInfos")
				--ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(plyGroup)
				--	Player.group = plyGroup
--
				--	ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills)
				--		PersonalMenu.BillData = bills
						ESX.PlayerData = ESX.GetPlayerData()
						RageUI.Visible(RMenu.Get('rageui', 'personal'), true)
				--	end)
				--end)
			end
		end

		if RageUI.Visible(RMenu.Get('rageui', 'personal')) then
			RenderPersonalMenu()
		end

		if RageUI.Visible(RMenu.Get('inventory', 'actions')) then
			RenderActionsMenu('inventory')
		elseif RageUI.Visible(RMenu.Get('loadout', 'actions')) then
			RenderActionsMenu('loadout')
		end

		if RageUI.Visible(RMenu.Get('personal', 'inventory')) then
			RenderInventoryMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'loadout')) then
			RenderWeaponMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'wallet')) then
			RenderWalletMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'billing')) then
			RenderBillingMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'clothes')) then
			RenderClothesMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'accessories')) then
			--RenderAccessoriesMenu()
			RenderAccessoiresNewMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'animation')) then
			RenderAnimationMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'vehicle')) then
			if not RMenu.Settings('personal', 'vehicle', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderVehicleMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'boss')) then
			if not RMenu.Settings('personal', 'boss', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderBossMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'boss2')) then
			if not RMenu.Settings('personal', 'boss2', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderBoss2Menu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'admin')) then
			if not RMenu.Settings('personal', 'admin', 'Restriction')() then
				RageUI.GoBack()
			end
			RenderAdminMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'divers')) then
			RenderDiversMenu()
		end

		if RageUI.Visible(RMenu.Get('personal', 'vision')) then
			RenderDiversMenuMenu()
		end

		for i = 1, #Config.Animations, 1 do
			if RageUI.Visible(RMenu.Get('animation', Config.Animations[i].name)) then
				RenderAnimationsSubMenu(Config.Animations[i].name)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()

		if IsControlJustReleased(0, Config.Controls.StopTasks.keyboard) and IsInputDisabled(2) and not Player.isDead then
			Player.handsup, Player.pointing = false, false
			ClearPedTasks(plyPed)
		end

		if IsControlPressed(1, Config.Controls.TPMarker.keyboard1) and IsControlJustReleased(1, Config.Controls.TPMarker.keyboard2) and IsInputDisabled(2) and not Player.isDead then
			ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(plyGroup)
				if plyGroup ~= nil and (plyGroup == 'mod' or plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
					local waypointHandle = GetFirstBlipInfoId(8)

					if DoesBlipExist(waypointHandle) then
						Citizen.CreateThread(function()
							local waypointCoords = GetBlipInfoIdCoord(waypointHandle)
							local foundGround, zCoords, zPos = false, -500.0, 0.0

							while not foundGround do
								zCoords = zCoords + 10.0
								RequestCollisionAtCoord(waypointCoords.x, waypointCoords.y, zCoords)
								Citizen.Wait(0)
								foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, zCoords)

								if not foundGround and zCoords >= 2000.0 then
									foundGround = true
								end
							end

							SetPedCoordsKeepVehicle(plyPed, waypointCoords.x, waypointCoords.y, zPos)
							TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Administration', _U('admin_tpmarker'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
						end)
					else
						TriggerEvent('esx:showAdvancedStreamedNotification', 'PRL', 'Administration', _U('admin_nomarker'), 'CHAR_SOCIAL_CLUB', 'logo', 8)
					end
				end
			end)
		end

		if Player.showCoords then
			local plyCoords = GetEntityCoords(plyPed, false)
			Text('~r~X~s~: ' .. plyCoords.x .. ' ~b~Y~s~: ' .. plyCoords.y .. ' ~g~Z~s~: ' .. plyCoords.z .. ' ~y~Angle~s~: ' .. GetEntityHeading(plyPed))
		end

		if Player.noclip then
			local plyCoords = GetEntityCoords(plyPed, false)
			local camCoords = getCamDirection()
			SetEntityVelocity(plyPed, 0.01, 0.01, 0.01)

			if IsControlPressed(0, 32) then
				plyCoords = plyCoords + (Config.NoclipSpeed * camCoords)
			end

			if IsControlPressed(0, 269) then
				plyCoords = plyCoords - (Config.NoclipSpeed * camCoords)
			end

			SetEntityCoordsNoOffset(plyPed, plyCoords, true, true, true)
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if Player.showName then
			for k, v in ipairs(ESX.Game.GetPlayers()) do
				local otherPed = GetPlayerPed(v)

				if otherPed ~= plyPed then
					if #(GetEntityCoords(plyPed, false) - GetEntityCoords(otherPed, false)) < 5000.0 then
						Player.gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
					else
						RemoveMpGamerTag(Player.gamerTags[v])
						Player.gamerTags[v] = nil
					end
				end
			end
		end

		Citizen.Wait(100)
	end
end)

--[[
for _, i in ipairs(GetActivePlayers()) do
    if GetPlayerPed(i) ~= PlayerPedId() then
        tags[i] = CreateFakeMpGamerTag(GetPlayerPed(i), GetPlayerServerId(i) .. " - " .. GetPlayerName(i), 0, 0, "", 0)
        SetMpGamerTagVisibility(tags[i], 0, Admin.nomtete)
        SetMpGamerTagVisibility(tags[i], 2, Admin.nomtete)
    end
end]]
			
Citizen.CreateThread(function()
	while true do
	Wait(1)
		if Player.showblips then
			for k, v in ipairs(ESX.Game.GetPlayers()) do
				if NetworkIsPlayerActive(v) and GetPlayerPed(v) ~= plyPed then
					plyPed = PlayerPedId()
					ped = GetPlayerPed(v)
					blip = GetBlipFromEntity(ped)

                if not DoesBlipExist(blip) then 
                    blip = AddBlipForEntity(ped)
                    SetBlipSprite(blip, 1)
                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) 
                else 
                    veh = GetVehiclePedIsIn(ped, false) 
                    blipSprite = GetBlipSprite(blip)
                    if not GetEntityHealth(ped) then
                        if blipSprite ~= 274 then
                            SetBlipSprite(blip, 274)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                        end
                    elseif veh then 
                        calsseVeicolo = GetVehicleClass(veh)
                        modelloVeicolo = GetEntityModel(veh)
                        if calsseVeicolo == 15 then 
                            if blipSprite ~= 422 then 
                                SetBlipSprite(blip, 422) 
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                            end
                        elseif calsseVeicolo == 16 then --Avion
                            if modelloVeicolo == GetHashKey("besra") or modelloVeicolo == GetHashKey("hydra") or modelloVeicolo == GetHashKey("lazer") then 
                                if blipSprite ~= 424 then
                                    SetBlipSprite(blip, 424)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                                end
                            elseif blipSprite ~= 423 then
                                SetBlipSprite(blip, 423)
                                Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false) 
                            end
                        elseif calsseVeicolo == 14 then --Bateau
                            if blipSprite ~= 427 then
                                SetBlipSprite(blip, 427)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                            end
                        elseif modelloVeicolo == GetHashKey("insurgent") or modelloVeicolo == GetHashKey("insurgent2") or modelloVeicolo == GetHashKey("limo2") then
                                if blipSprite ~= 426 then
                                    SetBlipSprite(blip, 426)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                                end
                            elseif modelloVeicolo == GetHashKey("rhino") then -- tank
                                if blipSprite ~= 421 then
                                    SetBlipSprite(blip, 421)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) 
                                end
                            elseif blipSprite ~= 1 then -- default blip
                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) 
                            end
                            
                            passengers = GetVehicleNumberOfPassengers(veh)
                            if passengers then
                                if not IsVehicleSeatFree(veh, -1) then
                                    passengers = passengers + 1
                                end
                                ShowNumberOnBlip(blip, passengers)
                            else
                                HideNumberOnBlip(blip)
                            end
                        else
                            
                            HideNumberOnBlip(blip)
                            if blipSprite ~= 1 then 
                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) 
                            end
                        end
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) 
                        SetBlipNameToPlayerName(blip, v) 
                        SetBlipScale(blip, 0.85) 
                        
                        if IsPauseMenuActive() then
                            SetBlipAlpha(blip, 255)
                        else 
                            x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true)) 
                            x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(v), true)) 
                            distanza = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                           
                            if distanza < 0 then
                                distanza = 0
                            elseif distanza > 255 then
                                distanza = 255
                            end
                            SetBlipAlpha(blip, distanza)
                        end
                    end
                else
                    RemoveBlip(blip)
                end
            end
        end
    end
end)


--------------------------
--------RADIALMENU--------
--------------------------

RegisterCommand("card", function(source, args, rawCommand)
	if item == showID then
		personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()
									
		if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
			TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer))
		else
			ESX.ShowNotification(_U('players_nearby'))
		end
	end	
end)

RegisterCommand("joint", function(source, args, rawCommand)
	local ped = GetPlayerPed(-1)
	local ad = "anim@mp_player_intveh@plane@luxor2@rear_back@smoke@"

	loadAnimDict(ad)
	TaskPlayAnim(ped, ad, "cigar_a", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
	RemoveAnimDict(ad)
	Wait (5000)
	ClearPedTasks(PlayerPedId())

	local cigar_name = cigar_name or 'p_cs_joint_02' --noprop				
	if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) then 
		if IsCigar then
			Wait(500)
			DetachEntity(cigar, 1, 1)
			DeleteObject(cigar)
			IsCigar = false
		else
			IsCigar = true
			Wait(500)
			local x,y,z = table.unpack(GetEntityCoords(ped))
			cigar = CreateObject(GetHashKey(cigar_name), x, y, z+0.2,  true,  true, true)
			AttachEntityToEntity(cigar, ped, GetPedBoneIndex(ped, 47419), 0.015, -0.009, 0.003, 55.0, 0.0, 110.0, true, true, false, true, 1, true)
		end     
	end	
end)

RegisterCommand("cigarette", function(source, args, rawCommand)
	local ped = GetPlayerPed(-1)
	local ad = "anim@mp_player_intveh@plane@luxor2@rear_back@smoke@"

	loadAnimDict(ad)
	TaskPlayAnim(ped, ad, "cigar_a", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
	RemoveAnimDict(ad)
	Wait (5000)
	ClearPedTasks(PlayerPedId())

	local cigar_name = cigar_name or 'prop_amb_ciggy_01' --noprop
	if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) then 
		if IsCigar then
			Wait(500)
			DetachEntity(cigar, 1, 1)
			DeleteObject(cigar)
			IsCigar = false
		else
			IsCigar = true
			Wait(500)
			local x,y,z = table.unpack(GetEntityCoords(ped))
			cigar = CreateObject(GetHashKey(cigar_name), x, y, z+0.2,  true,  true, true)
			AttachEntityToEntity(cigar, ped, GetPedBoneIndex(ped, 47419), 0.015, -0.009, 0.003, 55.0, 0.0, 110.0, true, true, false, true, 1, true)
		end     
	end
end)

RegisterCommand("cigar", function(source, args, rawCommand)
	local ped = GetPlayerPed(-1)
	local ad = "anim@mp_player_intveh@plane@luxor2@rear_back@smoke@"

	loadAnimDict(ad)
	TaskPlayAnim(ped, ad, "cigar_a", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
	RemoveAnimDict(ad)
	Wait (5000)
	ClearPedTasks(PlayerPedId())

	local cigar_name = cigar_name or 'prop_cigar_01' --noprop				
	if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) then 
		if IsCigar then
			Wait(500)
			DetachEntity(cigar, 1, 1)
			DeleteObject(cigar)
			IsCigar = false
		else
			IsCigar = true
			Wait(500)
			local x,y,z = table.unpack(GetEntityCoords(ped))
			cigar = CreateObject(GetHashKey(cigar_name), x, y, z+0.2,  true,  true, true)
			AttachEntityToEntity(cigar, ped, GetPedBoneIndex(ped, 47419), 0.015, -0.0001, 0.003, 55.0, 0.0, -85.0, true, true, false, true, 1, true)
		end
	end	
end)    

------------------
------Porter------
------------------

RegisterNetEvent('RiZiePersoMenu:porter')
AddEventHandler('RiZiePersoMenu:porter', function()
    if not carryingBackInProgress then
        local player = PlayerPedId()	
		lib = 'missfinale_c2mcs_1'
		anim1 = 'fin_c2_mcs_1_camman'
		lib2 = 'nm'
		anim2 = 'firemans_carry'
		distans = 0.15
		distans2 = 0.27
		height = 0.63
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		local closestPlayer = JoueurPlusProche(3)
		target = GetPlayerServerId(closestPlayer)
		if closestPlayer ~= -1 and closestPlayer ~= nil then
			carryingBackInProgress = true
			TriggerServerEvent('CarryPeople:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
		else
			drawNativeNotification("Personne à porter à proximité !")
		end
	else
        carryingBackInProgress = false
		ClearPedSecondaryTask(GetPlayerPed(-1))
		DetachEntity(GetPlayerPed(-1), true, false)
		local closestPlayer = JoueurPlusProche(3)
		target = GetPlayerServerId(closestPlayer)
		if target ~= 0 then 
			TriggerServerEvent("CarryPeople:stop",target)
		end
	end
end,false)

RegisterNetEvent('CarryPeople:syncTarget')
AddEventHandler('CarryPeople:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length,spin,controlFlag)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	carryingBackInProgress = true
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(GetPlayerPed(-1), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	carryAnimNamePlaying = animation2
	carryAnimDictPlaying = animationLib
	carryControlFlagPlaying = controlFlag
end)

RegisterNetEvent('CarryPeople:syncMe')
AddEventHandler('CarryPeople:syncMe', function(animationLib, animation,length,controlFlag,animFlag)
	local playerPed = GetPlayerPed(-1)
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	carryAnimNamePlaying = animation
	carryAnimDictPlaying = animationLib
	carryControlFlagPlaying = controlFlag
end)


RegisterNetEvent('CarryPeople:cl_stop')
AddEventHandler('CarryPeople:cl_stop', function()
	carryingBackInProgress = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if carryingBackInProgress then 
			while not IsEntityPlayingAnim(GetPlayerPed(-1), carryAnimDictPlaying, carryAnimNamePlaying, 3) do
				TaskPlayAnim(GetPlayerPed(-1), carryAnimDictPlaying, carryAnimNamePlaying, 8.0, -8.0, 100000, carryControlFlagPlaying, 0, false, false, false)
				Citizen.Wait(0)
			end
		end
		Wait(0)
	end
end)

function drawNativeNotification(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function loadAnimDict(dict)

	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function SetMovementAnim(pHash)
	local playerPed = PlayerPedId()
	RequestAnimSet(pHash)

	while not HasAnimSetLoaded(pHash) do
		Citizen.Wait(0)
	end

	SetPedMovementClipset(playerPed, pHash, 1.0)
	SetModelAsNoLongerNeeded(pHash)
end

function TouslesJoueursCO()
    local joueurs = 0

    for _, i in ipairs(GetActivePlayers()) do
        joueurs = joueurs + 1
    end

    return joueurs
end

function JoueurPlusProche(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

function helpnotif(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function OpenSIMTkt()
	TriggerEvent('NB:carteSIM')
end
--------------------------
---EDITED BY ikNox#6088---
--------------------------