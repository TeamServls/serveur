RMenu.Add('PC', 'main', RageUI.CreateMenu("PC", " "))
RMenu:Get('PC', 'main'):SetSubtitle("~b~Menu intéraction PC")
RMenu:Get('PC', 'main').EnableMouse = false
RMenu:Get('PC', 'main').Closed = function()
    -- TODO Perform action
end;

local VehTable = {}
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-281.2987, -888.7973, 31.31802)

    SetBlipSprite(blip, 565)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("~b~Parking Central - Place central")
    EndTextCommandSetBlipName(blip)


    local blip = AddBlipForCoord(-298.6448, -899.8942, 31.08062)

    SetBlipSprite(blip, 557)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 1)
    SetBlipDisplay(blip, 5)
    SetBlipAsShortRange(blip, true)
    while true do
        local boolCentral, wait = NearZoneOpti(vector3(-281.2987, -888.7973, 31.31802), 5.0)
        if boolCentral then
            ShowHelpNotification("Appuyer sur ~b~E~w~ pour ouvrir le garage")
            if IsControlJustPressed(1, 38) then
                RageUI.Visible(RMenu:Get('PC', 'main'), not RageUI.Visible(RMenu:Get('PC', 'main')))
                ESX.TriggerServerCallback('ruby_garage:getVehicles', function(vehicles)
                    VehTable = vehicles
                end)
            end
        end

        

        if RageUI.Visible(RMenu:Get('PC', 'main')) then
            RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
                --vehiclePropsList = {}
                if not table.empty(VehTable) then
                   for _,v in pairs(VehTable) do
                        local vehicleProps = json.decode(v.vehicle)
                        --vehiclePropsList[vehicleProps.plate] = vehicleProps

                        local vehicleHash = vehicleProps.model
                        local vehicleName, vehicleLabel

                        local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
                        local LastVeh = GetVehiclePedIsIn(GetPlayerPed(-1), true)
                        local LastPlate = GetVehicleNumberPlateText(LastVeh)
                        local ranger = false
               
                        if v.fourrieremecano then
                            vehicleLabel = vehicleName..': Fourrière externe'
                        elseif v.stored then
                            vehicleLabel = vehicleName..":~g~Rentré"
                        else
                            vehicleLabel = vehicleName..":~r~Sortie"
                        end
                        RageUI.Button(vehicleLabel, nil, {}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                if v.stored then
                                    local ZoneDeSpawn, HeadingZone = SelectSpawnPoint()
                                    if ZoneDeSpawn ~= false then
                                        TriggerServerEvent('ruby_garage:modifystate', vehicleProps.plate, false)
                                        RequestModel(vehicleHash)
                                        while not HasModelLoaded(vehicleHash) do Wait(100) end
                                        local NetVeh = CreateVehicle(vehicleHash, ZoneDeSpawn, HeadingZone, true, 1)
                                        ESX.Game.SetVehicleProperties(NetVeh, vehicleProps)
                                        SetEntityHeading(NetVeh, HeadingZone)  
                                        local id = NetworkGetNetworkIdFromEntity(NetVeh)
                                        _R:SaveVeh(NetVeh)
                                        SetNetworkIdCanMigrate(id, true)
                                        SetEntityAsMissionEntity(NetVeh, true, true)
                                        SetVehicleHasBeenOwnedByPlayer(NetVeh, true)
                                        SetVehicleNeedsToBeHotwired(NetVeh, false)
                                        SetVehicleDirtLevel(NetVeh, 0.1)
                                        TriggerEvent("RS_KEY:GiveKey", GetVehicleNumberPlateText(NetVeh))
                                        local blip = AddBlipForEntity(NetVeh)

                                        SetBlipSprite(blip, 326)
                                        SetBlipDisplay(blip, 2)
                                        SetBlipScale(blip, 0.50)
                                        SetBlipColour(blip, 2)
                                        SetBlipCategory(blip, 11)
                                        SetBlipAsShortRange(blip, true)

                                        BeginTextCommandSetBlipName('STRING')
                                        AddTextComponentString("~g~Véhicule Personnel")
                                        EndTextCommandSetBlipName(blip)

                                        for i = 0, 30 do
                                           if DoesExtraExist(NetVeh, i) == 1 then
                                               SetVehicleExtra(NetVeh, i, false)
                                           end
                                        end
                                        RageUI.CloseAll()
                                        ESX.TriggerServerCallback('ruby_garage:getVehicles', function(vehicles)
                                            VehTable = vehicles
                                        end)

                                    end
                                else
                                    RageUI.Popup("~b~INFORMATION SYSTEM\n~o~Véhicule déja sortie.")
                                end
                            end
                        end)
                    end
                else
                    RageUI.Button("Aucun véhicule", nil, {}, true, function(Hovered, Active, Selected)
                    end)
                end                    

            end, function()
                ---Panels
            end)
        end
        Citizen.Wait(wait)
    end
end)


Citizen.CreateThread(function()
    while true do
        local boolCentral, wait = NearZoneOpti(vector3(-298.6448, -899.8942, 31.08062), 5.0)
        if boolCentral then
            DrawMarker(26, -298.6448, -899.8942, 30.28062, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 5.0, 255, 0, 0, 120, 0, 0, 2, 0, nil, nil, 0)
            ShowHelpNotification("Appuyer sur ~b~E~w~ pour rentrer votre véhicule")
            if IsControlJustPressed(1, 38) then
                StockVehicleMenu()
            end
        end
        Citizen.Wait(wait)
    end
end)


local pointDeSpawn = {
    {pos = vector3(-289.4828, -887.1871, 30.4062),heading = 168.68370056152,},
    {pos = vector3(-292.9493, -886.2637, 30.40651),heading = 169.20199584961,},
    {pos = vector3(-296.6092, -885.4933, 30.4059),heading = 167.11051940918,},
    {pos = vector3(-300.108, -884.6674, 30.40653),heading = 168.29191589355,},
    {pos = vector3(-303.6909, -883.9616, 30.40638),heading = 169.0029296875,},
    {pos = vector3(-307.4514, -883.2728, 30.40622),heading = 166.89085388184,},
    {pos = vector3(-311.1225, -882.2717, 30.4062),heading = 169.08381652832,},
    {pos = vector3(-314.7074, -881.5721, 30.40614),heading = 167.53604125977,},
    {pos = vector3(-318.2289, -880.9164, 30.40542),heading = 167.66410827637,},
    {pos = vector3(-321.9713, -879.9478, 30.39994),heading = 169.20231628418,},
    {pos = vector3(-325.423, -879.491, 30.39869),heading = 169.02655029297,},
    {pos = vector3(-329.1522, -878.3954, 30.39816),heading = 166.45169067383,},
    {pos = vector3(-332.6591, -877.8058, 30.39827),heading = 168.12246704102,},
    {pos = vector3(-336.3878, -876.9553, 30.39695),heading = 167.82698059082,},
    {pos = vector3(-339.9684, -876.5357, 30.39667),heading = 167.75471496582,},
    {pos = vector3(-343.7131, -875.7701, 30.39702),heading = 168.08651733398,},
    {pos = vector3(-338.4011, -891.2151, 30.39716),heading = 349.22869873047,},
    {pos = vector3(-334.8346, -892.3517, 30.39705),heading = 347.9866027832,},
    {pos = vector3(-331.351, -893.1173, 30.39729),heading = 348.19030761719,},
    {pos = vector3(-327.6126, -893.8376, 30.39812),heading = 348.54498291016,},
    {pos = vector3(-323.9274, -894.6839, 30.39828),heading = 348.89910888672,},
    {pos = vector3(-320.3198, -895.0855, 30.39879),heading = 349.34579467773,},
    {pos = vector3(-316.7539, -896.2692, 30.40016),heading = 349.05297851563,},
    {pos = vector3(-313.1308, -896.7591, 30.40133),heading = 349.18316650391,},
}

ShowHelpNotification = function(msg)
	AddTextEntry('PCNotif', msg)
	DisplayHelpTextThisFrame('PCNotif', false)
end

function SelectSpawnPoint()
    local found = false
    while not found do
        local i = math.random(0, #pointDeSpawn)
        local info = pointDeSpawn[i]
        print(info.pos)
        print(info.heading)
        local clear = ESX.Game.IsSpawnPointClear(info.pos, 2.5)
        if clear and not found then
            found = true
            return info.pos, info.heading
        end
    end
    RageUI.Popup("~b~INFORMATION SYSTEM\n~o~Aucun point de sortie disponible.")
    return false
end

function NearZoneOpti(coords, near)
    local pPed = GetPlayerPed(-1)
    local pCoords = GetEntityCoords(pPed)
    local dst = GetDistanceBetweenCoords(coords, pCoords, true)
    if dst <= near then
        return true, 1
    else
        return false, 500
    end
end