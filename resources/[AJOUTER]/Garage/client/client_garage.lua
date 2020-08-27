-- Local
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

carInstance = {}



-- Fin Local

-- Init ESX
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj)
		ESX = obj
		end)
	end


	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	CreateZone()
end)


-- Fin Afficher les listes des vehicules

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Fourrière", "~b~Menu véhicule fourrière")
_menuPool:Add(mainMenu)
_menuPool:WidthOffset(0)

local objets = {}
local nomChercher = "Aucun nom"
function ListVehiclesFourriereMenu2(mainMenu, garage)
	local vehiclePropsList = {}

	local thisItem = NativeUI.CreateItem("Chercher par nom", "Majuscule et minuscule pris en compte, ~g~Incroyable hein :D ?")
	mainMenu:AddItem(thisItem)
	thisItem:RightLabel(nomChercher)
	thisItem.Activated = function(ParentMenu,SelectedItem)
		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 128 + 1)
		
		while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
			Citizen.Wait( 0 )
		end
		
		local result = GetOnscreenKeyboardResult()
		
		if result and result ~= "" then
			nomChercher = result
			thisItem:RightLabel(result) -- this is broken for now
			_menuPool:CloseAllMenus()
			ListVehiclesFourriereMenu()
		else
			nomChercher = "Aucun nom"
		end
	end

	ESX.TriggerServerCallback('ruby_garage:getVehiclesMecano', function(vehicles)
		for k,v in ipairs(vehicles) do
			local vehicleProps = json.decode(v.vehicle)
			vehiclePropsList[vehicleProps.plate] = vehicleProps
			local vehicleHash = vehicleProps.model
			local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
			label = ('%s | %s %s | %s'):format(vehicleName, v.firstname, v.lastname, vehicleProps.plate)
			if nomChercher == "Aucun nom" then
				objets[vehicleProps.plate] = NativeUI.CreateItem(label, '')
				mainMenu:AddItem(objets[vehicleProps.plate]) 
			else
				if nomChercher == v.firstname or nomChercher == v.lastname then
					objets[vehicleProps.plate] = NativeUI.CreateItem(label, '')
					mainMenu:AddItem(objets[vehicleProps.plate]) 
				end
			end
		end

		mainMenu.OnItemSelect = function(sender, item, index)
			for k,v in ipairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				local vehicleHash = vehicleProps.model
				local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
				if item == objets[vehicleProps.plate] then
					local plate = vehicleProps.plate
					print(plate)
					print(vehicleProps)
					SpawnVehicleMecano(vehicleProps, garage)
					TriggerServerEvent('ruby_garage:ChangeStateFromFourriereMecano', vehicleProps, false)
					_menuPool:CloseAllMenus()
                	end
            	end
        	end
	end)
end

local count = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        while ESX == nil do
            Citizen.Wait(10)
        end
        _menuPool:ProcessMenus()
        if count == 0 then
            ListVehiclesFourriereMenu2(mainMenu, garage)
            count = 1
        end
    end
end)

_menuPool:RefreshIndex()
_menuPool:MouseControlsEnabled (false);
_menuPool:MouseEdgeEnabled (false);
_menuPool:ControlDisablingEnabled(false);



function ListVehiclesFourriereMenu(garage)
    mainMenu:Clear()
    ListVehiclesFourriereMenu2(mainMenu, garage)
    Wait(100)
    mainMenu:Visible(not mainMenu:Visible())
end




-- Fonction qui permet de rentrer un vehicule dans fourriere
RegisterNetEvent("StockVehicleFourriereMenu")
AddEventHandler("StockVehicleFourriereMenu", function(vehicle)
	local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
	if GotTrailer then
		local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
		ESX.TriggerServerCallback('ruby_garage:stockvmecano',function(valid)
			if(valid) then
				--DeleteVehicle(TrailerHandle)
				TriggerServerEvent('ruby_garage:ChangeStateFromFourriereMecano', trailerProps, true)
				TriggerEvent("Fourriere:PlacementFourriere", vehicle)
			else
				TriggerEvent("Fourriere:PlacementFourriere", vehicle)
			end
		end,trailerProps)
	else
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		ESX.TriggerServerCallback('ruby_garage:stockvmecano',function(valid)
			if(valid) then
				--DeleteVehicle(vehicle)
				TriggerServerEvent('ruby_garage:ChangeStateFromFourriereMecano', vehicleProps, true)
				TriggerEvent("Fourriere:PlacementFourriere", vehicle)
			else
				TriggerEvent("Fourriere:PlacementFourriere", vehicle)
			end
		end,vehicleProps)
	end
end)
-- Fin fonction qui permet de rentrer un vehicule dans fourriere
--Fin fonction Menu


--Fonction pour spawn vehicule
function SpawnVehicle(vehicle)
	print("Spawn veh")
	LoadVeh(vehicle.model)
	local LocalVeh = CreateVehicle(vehicle.model, 194.41, -999.70, -98.99, 180.0, false, 1)
	ESX.Game.SetVehicleProperties(LocalVeh, vehicle)
	local carplate = GetVehicleNumberPlateText(LocalVeh)
	table.insert(carInstance, {vehicleentity = LocalVeh, plate = carplate})
	ShowAdvancedNotificationS("Garage", "~b~Info garage perso", "Vous avez sortie votre véhicule personnel.\nPlaque: ~g~"..carplate, "CHAR_PEGASUS_DELIVERY", 8)
	
	_D:ApplyDamage(carplate, LocalVeh)
	
	TriggerServerEvent('ruby_garage:modifystate', vehicle.plate, false)
end


function ShowAdvancedNotificationS(title, subject, msg, icon, iconType)
	AddTextEntry('GarageNotif', msg)
	SetNotificationTextEntry('GarageNotif')
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)
end

function ShowAdvancedNotificationErreur(title, subject, msg, icon, iconType)
	AddTextEntry('GarageNotifErreur', msg)
	SetNotificationTextEntry('GarageNotifErreur')
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	ThefeedNextPostBackgroundColor(6)
	DrawNotification(false, false)
end

function NotificationErreur(msg)
	AddTextEntry('NotifErreur', msg)
	SetNotificationTextEntry('NotifErreur')
	ThefeedNextPostBackgroundColor(6)
	DrawNotification(false, true)
end

--Fin fonction pour spawn vehicule

--Fonction pour spawn vehicule fourriere mecano
function SpawnVehicleMecano(vehicle)
	ESX.Game.SpawnVehicle(vehicle.model, {
		x = 969.94,
		y = -1843.19,
		z = 31.28											
		},314.96, function(callback_vehicle)
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			--TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
		end)
	TriggerServerEvent('ruby_garage:ChangeStateFromFourriereMecano', vehicle, false)
end
--Fin fonction pour spawn vehicule fourriere mecano





_GarageGestion = NativeUI.CreatePool()
GestionMenuGarage = NativeUI.CreateMenu("Ordinateur Garage", "~b~Menu de géstion")
_GarageGestion:Add(GestionMenuGarage)
_GarageGestion:WidthOffset(0)

local GestionVeh = {}
function GestionVehicle(menu)
	ESX.TriggerServerCallback('ruby_garage:getOutVehicles', function(vehicles)
		local elements, vehiclePropsList = {}, {}
		if not table.empty(vehicles) then
			for _,v in pairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				print(vehicleProps.plate)
				local vehicleHash = vehicleProps.model
				local vehicleName, vehicleLabel

				vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)

				if v.fourrieremecano then
					vehicleLabel = vehicleName..': Fourrière externe'
					GestionVeh[vehicleProps.plate] = NativeUI.CreateItem(vehicleLabel, '')
					menu:AddItem(GestionVeh[vehicleProps.plate]) 
				else
					vehicleLabel = vehicleName..': Sortie'
					GestionVeh[vehicleProps.plate] = NativeUI.CreateItem(vehicleLabel, '')
					menu:AddItem(GestionVeh[vehicleProps.plate]) 
				end
			end
		else
			vide = NativeUI.CreateItem("Pas de véhicule a sortir", '')
			menu:AddItem(vide) 
		end


		menu.OnItemSelect = function(sender, item, index)
			for _,v in pairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				print(vehicleProps.plate)
				local vehicleHash = vehicleProps.model
				local vehicleName, vehicleLabel
				if item == GestionVeh[vehicleProps.plate] then
					if v.fourrieremecano then
						ShowAdvancedNotificationS("Garage", "~b~Info garage perso", "Désolé, votre véhicule ne se trouve pas dans votre garage.\nAllez voir à la fourrièrex .", "CHAR_PEGASUS_DELIVERY", 8)
					else
						local doesVehicleExist = false
						for k,v in pairs(carInstance) do
							if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
								if DoesEntityExist(v.vehicleentity) then
									doesVehicleExist = true
								else
									table.remove(carInstance, k)
									doesVehicleExist = false
								end
							end
						end
						if not doesVehicleExist then
							ESX.TriggerServerCallback('ruby_garage:checkMoney', function(hasEnoughMoney)
								if hasEnoughMoney then
									SpawnVehicle(vehicleProps)
									_GarageGestion:CloseAllMenus()
								else	
									ShowAdvancedNotificationS("Garage", "~b~Info garage perso", "Vous n\'avez pas assez d\'argent", "CHAR_PEGASUS_DELIVERY", 8)					
								end
							end, Config.Price)
						else
							ShowAdvancedNotificationS("Garage", "~b~Info garage perso", "Vous ne pouvez pas sortir ce véhicule. Allez la chercher!", "CHAR_PEGASUS_DELIVERY", 8)				
						end				
					end	
				end
			end
		end
	end)
end





Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        while ESX == nil do
            Citizen.Wait(10)
        end
        _GarageGestion:ProcessMenus()
    end
end)

_GarageGestion:RefreshIndex()
_GarageGestion:MouseControlsEnabled (false);
_GarageGestion:MouseEdgeEnabled (false);
_GarageGestion:ControlDisablingEnabled(false);



function ListGestionGarage()
    GestionMenuGarage:Clear()
    GestionVehicle(GestionMenuGarage)
    GestionMenuGarage:Visible(not GestionMenuGarage:Visible())
end

local GarageBlip = {}
local CoordsEntreInstance = nil
local OpoHeading = nil
function CreateZone()

	local FourrierePos = vector3(965.34, -1837.01, 32.28)
	while true do
		local TempsAttente = 500
		local pPed = GetPlayerPed(-1)
		local pCoords = GetEntityCoords(pPed, true)
		local k = "Garage_Centre"
		local v = "A"

		local distance = GetDistanceBetweenCoords(pCoords, Garage.Pos, true)
		if distance <= 50 then
			TempsAttente = 1
			DrawMarker(36, Garage.SpawnPoint.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 170, false, true, 2, 0, nil, nil, false)
			DrawMarker(36, Garage.DeletePoint.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 170, false, true, 2, 0, nil, nil, false)
			DrawMarker(39, Garage.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 170, false, true, 2, 0, nil, nil, false)

			local distanceSpawn = GetDistanceBetweenCoords(pCoords, Garage.SpawnPoint.Pos, true)
			local distanceDelete = GetDistanceBetweenCoords(pCoords, Garage.DeletePoint.Pos, true)
			local distanceFourriere = GetDistanceBetweenCoords(pCoords, Garage.Pos, true)

			if distanceSpawn <= 3.0 then
				ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~g~ouvrir ~w~le menu d'intéraction!")
				if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) and not IsPedInAnyVehicle(PlayerPedId()) then
					InitGarageMenu(v, "personal", k, "car")
				end
			elseif distanceDelete <= 3.0 then
				ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~g~ouvrir ~w~le menu d'intéraction!")
				if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) then	
					StockVehicleMenu()
				end
			elseif distanceFourriere <= 3.0 then
				ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~g~ouvrir ~w~le menu d'intéraction!")
				if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) and not IsPedInAnyVehicle(PlayerPedId()) then
					--OpenMenuGarage(v, "personal", k, "car")
					ListGestionGarage()
				end
			end
		end

		-- Faire le job only 
		if ESX.PlayerData.job.name == "fourriere" then
			local distance = GetDistanceBetweenCoords(pCoords, FourrierePos, true)
			if distance <= 20 then
				TempsAttente = 1
				DrawMarker(39, FourrierePos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 170, false, true, 2, 0, nil, nil, false)
				local distanceSpawn = GetDistanceBetweenCoords(pCoords, FourrierePos, true)
				if distanceSpawn <= 3.0 then
					ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~g~ouvrir ~w~le menu d'intéraction!")
					if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) and not IsPedInAnyVehicle(PlayerPedId()) then
						ListVehiclesFourriereMenu(v)
					end
				end
			end
		end

		for k,v in pairs(Config.EntrerInstance) do
			local distance = GetDistanceBetweenCoords(pCoords, v, true)
			if distance <= 20 then
				TempsAttente = 1
				DrawMarker(36, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 170, false, true, 2, 0, nil, nil, false)
				if distance <= 3.0 then
					ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~g~entré ~w~dans le garage!")
					if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) then
						EntrerInstance()
					end
				end
			end
		end

		for k,v in pairs(Config.SortieInstance) do
			local distance = GetDistanceBetweenCoords(pCoords, v, true)
			if distance <= 20 then
				TempsAttente = 1
				DrawMarker(36, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 170, false, true, 2, 0, nil, nil, false)
				if distance <= 3.0 then
					
					ESX.ShowHelpNotification("Utilise ~INPUT_CONTEXT~ pour ~r~sortir ~w~dans le garage!")
					if IsControlJustReleased(0, 38) and IsInputDisabled(0) and GetLastInputMethod(2) then
						SortieInstance()
					end
				end
			end
		end

		Citizen.Wait(TempsAttente)
	end
end


-- Fin controle touche
function dump(o, nb)
  if nb == nil then
    nb = 0
  end
   if type(o) == 'table' then
      local s = ''
      for i = 1, nb + 1, 1 do
        s = s .. "    "
      end
      s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
          for i = 1, nb, 1 do
            s = s .. "    "
          end
         s = s .. '['..k..'] = ' .. dump(v, nb + 1) .. ',\n'
      end
      for i = 1, nb, 1 do
        s = s .. "    "
      end
      return s .. '}'
   else
      return tostring(o)
   end
end

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end


