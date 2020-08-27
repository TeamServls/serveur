local pause = false
function EntrerInstance()
     --NetworkSetVoiceChannel(math.random(1, 1000))
     pause = true
     EnPause()
     PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 1)
     Wait(1000)
     local pPed = GetPlayerPed(-1)
     if IsPedInAnyVehicle(pPed, false) then
          local pVeh = GetVehiclePedIsIn(pPed, false)
          local plate = GetVehicleNumberPlateText(pVeh)
          _D:GetDamage(pVeh)
          local props = ESX.Game.GetVehicleProperties(pVeh)
          local model = GetEntityModel(pVeh)
          CoordsEntreInstance = GetEntityCoords(pPed, true)
          OpoHeading = GetEntityHeading(pPed) - 180.0
          
          SetEntityCoords(pPed, 201.58, -1001.94, -98.99-1.0, 0.0, 0.0, 0.0, 0)
          local LocalVeh = CreateVehicle(model, 201.58, -1001.94, -98.99-1.0, GetEntityHeading(pPed) - 180.0, false, 1)
          CopyVehicleDamages(pVeh, LocalVeh)
          -- Delete du veh network
          while DoesEntityExist(pVeh) do
               SetEntityAsNoLongerNeeded(pVeh)
               DeleteEntity(pVeh)
               Wait(1)
          end
          --
          ESX.Game.SetVehicleProperties(LocalVeh, props)
          _D:ApplyDamage(plate, LocalVeh)
          TaskWarpPedIntoVehicle(pPed, LocalVeh, -1)
          SetEntityHeading(LocalVeh, -360.0)
     else
          CoordsEntreInstance = GetEntityCoords(pPed, true)
          OpoHeading = GetEntityHeading(pPed) - 180.0
          SetEntityCoords(pPed, 201.58, -1001.94, -98.99-1.0, 0.0, 0.0, 0.0, 0)
     end
end

function SortieInstance()
     --TriggerEvent("XNL_NET:AddPlayerXP", math.random(10,15))
     EnPause()
     pause = false
     local pPed = GetPlayerPed(-1)
     if IsPedInAnyVehicle(pPed, false) then
          local pVeh = GetVehiclePedIsIn(pPed, false)
          local plate = GetVehicleNumberPlateText(pVeh)
          _D:GetDamage(pVeh)
          local props = ESX.Game.GetVehicleProperties(pVeh)
          local model = GetEntityModel(pVeh)

          if CoordsEntreInstance ~= nil then
               SetEntityCoords(pPed, CoordsEntreInstance, 0.0, 0.0, 0.0, 0)
               
               local NetVeh = CreateVehicle(model, CoordsEntreInstance, OpoHeading, true, 1)
               CopyVehicleDamages(pVeh, NetVeh)
               -- Delete du veh local
               while DoesEntityExist(pVeh) do
                    SetEntityAsNoLongerNeeded(pVeh)
                    DeleteEntity(pVeh)
                    Wait(1)
               end
               --
               local NetId = NetworkGetNetworkIdFromEntity(NetVeh)
               _R:SaveVeh(NetId)
               ESX.Game.SetVehicleProperties(NetVeh, props)
               _D:ApplyDamage(plate, NetVeh)
               TaskWarpPedIntoVehicle(pPed, NetVeh, -1)
               TriggerEvent("RS_KEY:GiveKey", GetVehicleNumberPlateText(NetVeh))
               SetEntityHeading(NetVeh, OpoHeading)
               Collision()
          else
               SetEntityCoords(pPed, -146.40, -585.09, 31.98, 0.0, 0.0, 0.0, false)
               
               local NetVeh = CreateVehicle(model, -146.40, -585.09, 31.98, 161.0, true, 1)
               CopyVehicleDamages(pVeh, NetVeh)
               -- Delete du veh local
               while DoesEntityExist(pVeh) do
                    SetEntityAsNoLongerNeeded(pVeh)
                    DeleteEntity(pVeh)
                    Wait(1)
               end
               --
               ESX.Game.SetVehicleProperties(NetVeh, props)
               _D:ApplyDamage(plate, NetVeh)
               SetEntityAsMissionEntity(NetVeh, 1, 1)
               TaskWarpPedIntoVehicle(pPed, NetVeh, -1)
               SetEntityHeading(NetVeh, 161.0)
               TriggerEvent("RS_KEY:GiveKey", GetVehicleNumberPlateText(NetVeh))
               ShowAdvancedNotificationErreur("Garage personnel", "~b~Information", "~r~ERREUR: ~w~Impossible de récupérer votre dernière position, vous avez été placé automatiquement en ville.", "CHAR_PEGASUS_DELIVERY", 8)
               NotificationErreur("Pour éviter se problème, merci de ne pas vous déconnecté dans vos garages.")
               Collision()
          end
     else
          if CoordsEntreInstance ~= nil then
               SetEntityCoords(pPed, CoordsEntreInstance, 0.0, 0.0, 0.0, 0)
               
          else
               SetEntityCoords(pPed, -146.40, -585.09, 31.98, 0.0, 0.0, 0.0, 0)
               
               ShowAdvancedNotificationErreur("Garage personnel", "~b~Information", "~r~ERREUR: ~w~Impossible de récupérer votre dernière position, vous avez été placé automatiquement en ville.", "CHAR_PEGASUS_DELIVERY", 8)
               NotificationErreur("Pour éviter se problème, merci de ne pas vous déconnecté dans vos garages.")
          end
     end
end



-- Pas parfait, à revoir 
function Collision()
     if CoordsEntreInstance == nil then
          CoordsEntreInstance = vector3(-146.40, -585.09, 31.98)
     end
     local count = 0
     local pPed = GetPlayerPed(-1)
     local cVeh = ESX.Game.GetClosestVehicle(CoordsEntreInstance)
     local pCoords = GetEntityCoords(pPed, true)
     if cVeh ~= nil then
          local dst = GetDistanceBetweenCoords(pCoords, CoordsEntreInstance, true)  
          local pVeh = GetVehiclePedIsIn(pPed, false)
          SetEntityCollision(pVeh, 1, 0)
          while dst <= 10.0 do
               local pCoords = GetEntityCoords(pPed, true)
               dst = GetDistanceBetweenCoords(pCoords, CoordsEntreInstance, true)  
               DisplayText()

               local pVeh = GetVehiclePedIsIn(pPed, false)
               local cVeh = GetVehDevant()
               SetEntityNoCollisionEntity(pVeh, cVeh, false)
               SetEntityNoCollisionEntity(cVeh, pVeh, false)
               SetEntityAlpha(cVeh, 150, 150)
               SetEntityAlpha(pVeh, 150, 150)
               Citizen.Wait(0)
          end
          local AllVeh = ESX.Game.GetVehicles()
          for k,v in pairs(AllVeh) do
               pVeh = GetVehiclePedIsIn(pPed, false)
               SetEntityNoCollisionEntity(pVeh, v, true)
               SetEntityNoCollisionEntity(v, pVeh, true)
               SetEntityCollision(v, 1, 1)
               ResetEntityAlpha(v)
          end
          Wait(1)
     end
end

function GetVehDevant()
	local backwardPosition = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, 5.0, 0 )
	local voiture = ESX.Game.GetClosestVehicle(backwardPosition)
	local distance = GetDistanceBetweenCoords(backwardPosition, GetEntityCoords(voiture), true)
	if distance <= 5.0 then
		return voiture
	end
	return nil
end

function DisplayText()
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString("Mode [~g~sécurité~w~] activé")
	DrawText(0.25, 0.9)
	-- 
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString("~w~Collision temporairement désactivé")
	DrawText(0.25, 0.93)
end


function EnPause()
     Citizen.CreateThread(function()
          while pause == true do
               Citizen.Wait(1)
               for _, i in ipairs(GetActivePlayers()) do
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(i), 1), GetEntityCoords(PlayerPedId(), 1), 1)
                    if distance <= 20.0 then
                         SetEntityVisible(GetPlayerPed(i), false, false)
                         SetEntityVisible(PlayerPedId(), true, true)
                         SetEntityNoCollisionEntity(GetPlayerPed(i), GetPlayerPed(-1), false)
                    end
               end
          end
          for _, i in ipairs(GetActivePlayers()) do
               SetEntityVisible(GetPlayerPed(i), 1, 0)
               SetEntityVisible(PlayerPedId(), true, true)
               SetEntityNoCollisionEntity(GetPlayerPed(i), GetPlayerPed(-1), true)
          end
     end)
end
