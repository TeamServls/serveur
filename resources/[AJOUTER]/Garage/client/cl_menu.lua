--
--
--
--                       Version édité du Eden_jb_garage2.
--                Si tu vient de dump un serveur et tu vois se message
--   Respecte mon travail et ne vole pas le scripts, au moins demande moi la permission Rubylium#3694
--
--
--



_GaragePool = NativeUI.CreatePool()
GarageMenu = NativeUI.CreateMenu("Menu Garage", "~b~Garage", nil, nil, "commonmenu", "gradient_bgd")
_GaragePool:Add(GarageMenu)
_GaragePool:WidthOffset(30)

local TempVeh = nil
local _garage = nil
local CarProps = {}
local VehTable = {}
function garageMenu(GarageMenu, garage)
     vehiclePropsList = {}
     objets = {}
	ESX.TriggerServerCallback('ruby_garage:getVehicles', function(vehicles)
		VehTable = vehicles
		if not table.empty(vehicles) then
			for _,v in pairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				
				local vehicleHash = vehicleProps.model
				local vehicleName, vehicleLabel
								
				vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)

				if v.fourrieremecano then
					vehicleLabel = vehicleName..': Fourrière externe'
				elseif v.stored then
					vehicleLabel = vehicleName..":~g~Rentré"
				else
					vehicleLabel = vehicleName..":~r~Sortie"
                    end

                    objets[vehicleProps.plate] = NativeUI.CreateItem(vehicleLabel, '')
				GarageMenu:AddItem(objets[vehicleProps.plate]) 
               end
          else
              local vide = NativeUI.CreateItem("Aucun véhicule", "")
              GarageMenu:AddItem(vide) 
          end

          GarageMenu.OnItemSelect = function(sender, item, index)
               for _,v in pairs(vehicles) do
                    local vehicleProps = json.decode(v.vehicle)
				if item == objets[vehicleProps.plate] then
					SetEntityAsNoLongerNeeded(TempVeh)
					DeleteEntity(TempVeh)
					while DoesEntityExist(TempVeh) do
						SetEntityAsNoLongerNeeded(TempVeh)
						DeleteEntity(TempVeh)
						Citizen.Wait(100)
					end
					LoadVeh(vehicleProps.model)
                         TempVeh = CreateVehicle(vehicleProps.model, 194.41, -999.70, -98.99, 180.0, false, 1)
                         ESX.Game.SetVehicleProperties(TempVeh, vehicleProps)
                         FreezeEntityPosition(TempVeh, 1)
					--SetPedIntoVehicle(GetPlayerPed(-1), TempVeh, -1)
					SetEntityAlpha(TempVeh, 30, 30)
					SetEntityCollision(TempVeh, 0, 0)
					_D:ApplyDamage(vehicleProps.plate, TempVeh)
					CarProps = vehiclePropsList[vehicleProps.plate]
                    end 
               end
          end
	end)
	

	count = 1
end



local count = 0
local attente = false
Citizen.CreateThread(function()
     while true do
          Citizen.Wait(0)
          _GaragePool:ProcessMenus()
		if _GaragePool:IsAnyMenuOpen() and TempVeh ~= nil then
			SetEntityAlpha(TempVeh, 150, 150)
			printControlsText()
			
			if IsControlJustReleased(0, 38) then
				for _,v in pairs(VehTable) do
					local vehicleProps = json.decode(v.vehicle)
					local doesVehicleExist = false
					

					for k,v in pairs (carInstance) do
						if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
							if DoesEntityExist(v.vehicleentity) then
								doesVehicleExist = true
							else
								table.remove(carInstance, k)
								doesVehicleExist = false
							end
						end
					end
					if doesVehicleExist then
						ShowAdvancedNotificationS("Garage personnel", "~b~Information", "Vous ne pouvez pas sortir ce véhicule. Allez la chercher!", "CHAR_PEGASUS_DELIVERY", 8)
               		elseif v.fourrieremecano then
						ShowAdvancedNotificationS("Garage personnel", "~b~Information", "Votre véhicule est à la fourrière, allez la bas pour le récupèrer.", "CHAR_PEGASUS_DELIVERY", 8)
					elseif v.stored then
						if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
							SetEntityAsNoLongerNeeded(TempVeh)
							DeleteEntity(TempVeh)
							while DoesEntityExist(TempVeh) do
								SetEntityAsNoLongerNeeded(TempVeh)
								DeleteEntity(TempVeh)
								Citizen.Wait(100)
							end
							TempVeh = nil
							_GaragePool:CloseAllMenus()
							if not attente then
								SpawnVehicle(CarProps)
								attente = true
								break
							end
						end
               		else
               		    ShowAdvancedNotificationS("Garage personnel", "~b~Information", "Votre véhicule est déja sortie.", "CHAR_PEGASUS_DELIVERY", 8)
					end
				end
			end
			
		else
			SetEntityAsNoLongerNeeded(TempVeh)
			DeleteEntity(TempVeh)
			while DoesEntityExist(TempVeh) do
				SetEntityAsNoLongerNeeded(TempVeh)
				DeleteEntity(TempVeh)
				Citizen.Wait(100)
			end
			TempVeh = nil
			count = 0
          end
     end
end)

_GaragePool:RefreshIndex()
_GaragePool:MouseControlsEnabled (false);
_GaragePool:MouseEdgeEnabled (false);
_GaragePool:ControlDisablingEnabled(false);



function InitGarageMenu(garage)
	GarageMenu:Clear()

    	garageMenu(GarageMenu, garage)
	GarageMenu:Visible(not GarageMenu:Visible())
	attente = false
end

function LoadVeh(veh)
	while not HasModelLoaded(veh) do
		RequestModel(veh)
		Wait(10)
	end
end


function printControlsText()
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString("Touche [~g~E~w~] pour sortir le véhicule")
	DrawText(0.25, 0.9)
end