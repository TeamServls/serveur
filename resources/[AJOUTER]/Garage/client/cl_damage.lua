--
--
--
--                       Version édité du Eden_jb_garage2.
--                Si tu vient de dump un serveur et tu vois se message
--   Respecte mon travail et ne vole pas le scripts, au moins demande moi la permission Rubylium#3694
--
--
--


local SaveDamage = {
     window0 = {},
     window1 = {},
     window2 = {},
     window3 = {},
     window4 = {},
     window5 = {},
     window6 = {},
     window7 = {},
     window8 = {},
     window9 = {},

     tyre0 = {},
     tyre1 = {},
     tyre2 = {},
     tyre3 = {},
     tyre4 = {},
     tyre5 = {},
     tyre6 = {},
     tyre7 = {},


     door0 = {},
     door1 = {},
     door2 = {},
     door3 = {},
     door4 = {},
     door5 = {},
     door6 = {},
}


_D = SaveDamage


function _D:GetDamage(veh)
     local window = {}

     local P = GetVehicleNumberPlateText(veh)

    local win0 = IsVehicleWindowIntact(veh, 0)
    local win1 = IsVehicleWindowIntact(veh, 1)
    local win2 = IsVehicleWindowIntact(veh, 2)
    local win3 = IsVehicleWindowIntact(veh, 3)
    local win4 = IsVehicleWindowIntact(veh, 4)
    local win5 = IsVehicleWindowIntact(veh, 5)
    local win6 = IsVehicleWindowIntact(veh, 6)
    local win7 = IsVehicleWindowIntact(veh, 7)
    --local win8 = IsVehicleWindowIntact(veh, 8)
    --local win9 = IsVehicleWindowIntact(veh, 9)

    self.window0[P] = win0
    self.window1[P] = win1
    self.window2[P] = win2
    self.window3[P] = win3
    self.window4[P] = win4
    self.window5[P] = win5
    self.window6[P] = win6
    self.window7[P] = win7
    self.window8[P] = win8
    self.window9[P] = win9

     local tyre0 = IsVehicleTyreBurst(veh, 0, false)
     if not tyro0 then
          tyre0 = IsVehicleTyreBurst(veh, 0, true)
     end
     local tyre1 = IsVehicleTyreBurst(veh, 1, false)
     if not tyro1 then
          tyre1 = IsVehicleTyreBurst(veh, 1, true)
     end
     local tyre2 = IsVehicleTyreBurst(veh, 2, false)
     if not tyro2 then
          tyre2 = IsVehicleTyreBurst(veh, 2, true)
     end
     local tyre3 = IsVehicleTyreBurst(veh, 3, false)
     if not tyro3 then
          tyre3 = IsVehicleTyreBurst(veh, 3, true)
     end
     local tyre4 = IsVehicleTyreBurst(veh, 4, false)
     if not tyro4 then
          tyre4 = IsVehicleTyreBurst(veh, 4, true)
     end
     local tyre5 = IsVehicleTyreBurst(veh, 5, false)
     if not tyro5 then
          tyre5 = IsVehicleTyreBurst(veh, 5, true)
     end
     local tyre6 = IsVehicleTyreBurst(veh, 45, false)
     if not tyro6 then
          tyre6 = IsVehicleTyreBurst(veh, 45, true)
     end
     local tyre7 = IsVehicleTyreBurst(veh, 47, false)
     if not tyro7 then
          tyre7 = IsVehicleTyreBurst(veh, 47, true)
     end

     self.tyre0[P] = tyre0
     self.tyre1[P] = tyre1
     self.tyre2[P] = tyre2
     self.tyre3[P] = tyre3
     self.tyre4[P] = tyre4
     self.tyre5[P] = tyre5
     self.tyre6[P] = tyre6
     self.tyre7[P] = tyre7


     local door0 = DoesVehicleHaveDoor(veh, 0)
     local door1 = DoesVehicleHaveDoor(veh, 1)
     local door2 = DoesVehicleHaveDoor(veh, 2)
     local door3 = DoesVehicleHaveDoor(veh, 3)
     local door4 = DoesVehicleHaveDoor(veh, 4)
     local door5 = DoesVehicleHaveDoor(veh, 5)
     local door6 = DoesVehicleHaveDoor(veh, 6)


     self.door0[P] = door0
     self.door1[P] = door1
     self.door2[P] = door2
     self.door3[P] = door3
     self.door4[P] = door4
     self.door5[P] = door5
     self.door6[P] = door6
end


function _D:ApplyDamage(plate, veh)
     P = plate
     local win0 = self.window0[P]
     local win1 = self.window1[P]
     local win2 = self.window2[P]
     local win3 = self.window3[P]
     local win4 = self.window4[P]
     local win5 = self.window5[P]
     local win6 = self.window6[P]
     local win7 = self.window7[P]
     local win8 = self.window8[P]
     local win9 = self.window9[P]


     if win0 ~= nil then
          if not win0 then
               SmashVehicleWindow(veh, 0)
          end
          if not win1 then
               SmashVehicleWindow(veh, 1)
          end
          if not win2 then
               SmashVehicleWindow(veh, 2)
          end
          if not win3 then
               SmashVehicleWindow(veh, 3)
          end
          if not win4 then
               SmashVehicleWindow(veh, 4)
          end
          if not win5 then
               SmashVehicleWindow(veh, 5)
          end
          if not win6 then
               SmashVehicleWindow(veh, 6)
          end
          if not win7 then
               SmashVehicleWindow(veh, 7)
          end
          if not win8 then
               SmashVehicleWindow(veh, 8)
          end
          if not win9 then
               SmashVehicleWindow(veh, 9)
          end
     end


     
     local tyre0 = self.tyre0[P]
     local tyre1 = self.tyre1[P]
     local tyre2 = self.tyre2[P]
     local tyre3 = self.tyre3[P]
     local tyre4 = self.tyre4[P]
     local tyre5 = self.tyre5[P]
     local tyre6 = self.tyre6[P]
     local tyre7 = self.tyre7[P]

     if tyre0 ~= nil then
          if tyre0 then
               SetVehicleTyreBurst(veh, 0, false, 100.0)
          end
          if tyre1 then
               SetVehicleTyreBurst(veh, 1, false, 100.0)
          end
          if tyre2 then
               SetVehicleTyreBurst(veh, 2, false, 100.0)
          end
          if tyre3 then
               SetVehicleTyreBurst(veh, 3, false, 100.0)
          end
          if tyre4 then
               SetVehicleTyreBurst(veh, 4, false, 100.0)
          end
          if tyre5 then
               SetVehicleTyreBurst(veh, 5, false, 100.0)
          end
          if tyre6 then
               SetVehicleTyreBurst(veh, 45, false, 100.0)
          end
          if tyre7 then
               SetVehicleTyreBurst(veh, 47, false, 100.0)
          end         
     end

     local door0 = self.door0[P]
     local door1 = self.door1[P]
     local door2 = self.door2[P]
     local door3 = self.door3[P]
     local door4 = self.door4[P]
     local door5 = self.door5[P]
     local door6 = self.door6[P]

     if door0 ~= nil then
          if not door0 then
               SetVehicleDoorBroken(veh, 0, true)
          end
          if not door1 then
               SetVehicleDoorBroken(veh, 1, true)
          end
          if not door2 then
               SetVehicleDoorBroken(veh, 2, true)
          end
          if not door3 then
               SetVehicleDoorBroken(veh, 3, true)
          end
          if not door4 then
               SetVehicleDoorBroken(veh, 4, true)
          end
          if not door5 then
               SetVehicleDoorBroken(veh, 5, true)
          end
          if not door6 then
               SetVehicleDoorBroken(veh, 6, true)
          end
     end   

end



-- Fonction qui permet de rentrer un vehicule
function StockVehicleMenu()
     local playerPed  = PlayerPedId()
     local vehicle = nil
     if IsPedInAnyVehicle(playerPed, false) then
          vehicle = GetVehiclePedIsIn(playerPed, false)
     else
          local _vehicle = GetVehiclePedIsIn(playerPed, true)
          local distance = GetDistanceBetweenCoords(GetEntityCoords(playerPed, true), GetEntityCoords(_vehicle, true), false)
          if distance <= 20.0 then
               vehicle = _vehicle
          else
               TriggerEvent('esx:showNotification', 'Il n\' y a pas de vehicule à rentrer')
          end
     end
     if vehicle ~= nil then
		local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
		if GotTrailer then
			local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
			ESX.TriggerServerCallback('ruby_garage:stockv',function(valid)
				if(valid) then
					for k,v in pairs (carInstance) do
						if ESX.Math.Trim(v.plate) == ESX.Math.Trim(trailerProps.plate) then
							table.remove(carInstance, k)
						end
					end
					DeleteEntity(TrailerHandle)
					TriggerServerEvent('ruby_garage:modifystate', trailerProps.plate, true)
					ESX.ShowAdvancedNotification("Garage personnel", "~b~Informations", "Vous avez bien ~r~rangé~w~ votre véhicule personnel.", "CHAR_PEGASUS_DELIVERY", 1)
				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
				end
			end, trailerProps)
		else
			local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
			ESX.TriggerServerCallback('ruby_garage:stockv',function(valid)
				if(valid) then
					for k,v in pairs (carInstance) do
						if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
							table.remove(carInstance, k)
						end
                         end
                         _D:GetDamage(vehicle)
					TaskLeaveAnyVehicle(GetPlayerPed(-1), 0, 0)
					while IsPedInAnyVehicle(GetPlayerPed(-1), false) do
						Citizen.Wait(500)
					end
					DeleteEntity(vehicle)
					TriggerServerEvent('ruby_garage:modifystate', vehicleProps.plate, true)
					ESX.ShowAdvancedNotification("Garage personnel", "~b~Informations", "Vous avez bien ~r~rangé~w~ votre véhicule personnel.", "CHAR_PEGASUS_DELIVERY", 1)

				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
				end
			end, vehicleProps)
		end
     end
end
-- Fin fonction qui permet de rentrer un vehicule 