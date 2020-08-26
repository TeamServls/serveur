ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

RMenu.Add('example', 'main', RageUI.CreateMenu("Shop", "Menu Shop"))




Citizen.CreateThread(function()
    while true do

        RageUI.IsVisible(RMenu:Get('example', 'main'), true, true, true, function()

            RageUI.Button("Eau", "OUfff J'avais tres soifff !", {RightLabel = "~g~5$"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    TriggerServerEvent('zousko_shop:BuyEau')
                end
            end)

                RageUI.Button("Pain", "Miam Miam C'est bon !", {RightLabel = "~g~5$"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('zousko_shop:BuyPain')
                    end
                end)
                        
            end, function()
                ---Panels
            end, 1)

            Citizen.Wait(0)
        end
    end)




    local position = {
       {vector3(25.67, -1346.37, 29.49)},
       vector3{x = 373.875, y = 325.896,  z = 102.566},
       vector3{x = 2557.458, y = 382.282,  z = 107.622},
       vector3{x = -3038.939, y = 585.954,  z = 6.908},
       vector3{x = -3241.927, y = 1001.462, z = 11.830},
       vector3{x = 547.431, y = 2671.710, z = 41.156},
       vector3{x = 1961.464, y = 3740.672, z = 31.343},
       vector3{x = 2678.916, y = 3280.671, z = 54.241},
       vector3{x = 1729.216, y = 6414.131, z = 34.037}
    }        

    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
    
            for _,v in pairs(position) do
    
                local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v[1])
    
                if dist <= 1.0 then

                   RageUI.Text({
                        message = "Appuyez sur [~b~E~w~] pour acceder au ~b~Shop",
                        time_display = 1
                    })
                   -- ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour acceder au ~b~Shop")
                    if IsControlJustPressed(1,51) then
                        RageUI.Visible(RMenu:Get('example', 'main'), not RageUI.Visible(RMenu:Get('example', 'main')))
                    end
                end
            end
        end
    end)