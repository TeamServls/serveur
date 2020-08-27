--
--
--
--                       Version édité du Eden_jb_garage2.
--                Si tu vient de dump un serveur et tu vois se message
--   Respecte mon travail et ne vole pas le scripts, au moins demande moi la permission Rubylium#3694
--
--
--




local MenuGestionVeh = {
    LastVeh = nil,
    StatusPorte = true,
}

_R = MenuGestionVeh
_C = Config


function _R:GetLastVeh()
    local veh = NetworkGetEntityFromNetworkId(self.LastVeh)
    if DoesEntityExist(veh) then
       return true, veh
    else
       return false
    end
    return false
end

function _R:SaveVeh(ent)
    local NetId = NetworkGetNetworkIdFromEntity(ent)
    self.LastVeh = NetId
end



_GestionPool = NativeUI.CreatePool()
GestionMenu = NativeUI.CreateMenu("Géstion", "~b~Menu géstion véhicule", nil, nil, "commonmenu", "gradient_bgd")
_GestionPool:Add(GestionMenu)
_GestionPool:WidthOffset(0)


function _R:GestionVehMenu(menu)
    local status, veh = _R:GetLastVeh()
    local vehActuel = NativeUI.CreateItem("Véhicule: ", "")
    if status then
       	local plate = GetVehicleNumberPlateText(veh)
		vehActuel:RightLabel("~g~"..plate) 
    else
		vehActuel:RightLabel("~r~Aucun véhicule") 
    end
	GestionMenu:AddItem(vehActuel)

	if status then
		marqeur = NativeUI.CreateItem("Ajouter un traceur", "~b~Permet de mettre un traceur sur votre véhicule personnel")
        GestionMenu:AddItem(marqeur)
        
        porte = NativeUI.CreateItem("~r~Fermer ~w~/ ~g~Ouvrir ~w~les portes du véhicule", "~b~Permet de mettre un traceur sur votre véhicule personnel")
        GestionMenu:AddItem(porte)
	end
    blip = NativeUI.CreateItem("~r~Désactiver ~w~/ ~g~Activer ~w~les points GPS", "~b~Permet d'activer ou de désactiver les points GPS des garages sur la minimap'")
    GestionMenu:AddItem(blip)

	GestionMenu.OnItemSelect = function(sender, item, index)
		if item == marqeur then
			local blip = AddBlipForEntity(veh)
			SetBlipSprite(blip, 225)
			SetBlipColour(blip, 3)
			SetBlipShrink(blip, true)
			SetBlipScale(blip, 0.85)
            SetBlipCategory(blip, 2)
            
		    BeginTextCommandSetBlipName('STRING')
		    AddTextComponentString("~b~Véhicule personnel")
            EndTextCommandSetBlipName(blip)
        elseif item == porte then
            _R:UpdatePorte(veh)
        elseif item == blip then
            _C:Blip()
		end
    end
end


function _R:UpdatePorte(veh)
    if self.StatusPorte then
        SetVehicleDoorsLocked(veh, 2)
        PlayVehicleDoorCloseSound(veh, 1)
        SetVehicleLights(veh, 2)
        SoundVehicleHornThisFrame(veh)
        Wait(200)
        SetVehicleLights(veh, 0)
        Wait(200)
        SetVehicleLights(veh, 2)
        SoundVehicleHornThisFrame(veh)
        Wait(400)
        SetVehicleLights(veh, 0)
        self.StatusPorte = false
    elseif not self.StatusPorte then
        SetVehicleDoorsLocked(veh, 1)
        PlayVehicleDoorOpenSound(veh, 0)
        SetVehicleLights(veh, 2)
        SoundVehicleHornThisFrame(veh)
        Wait(200)
        SetVehicleLights(veh, 0)
        Wait(200)
        SetVehicleLights(veh, 2)
        SoundVehicleHornThisFrame(veh)
        Wait(400)
        SetVehicleLights(veh, 0)
        self.StatusPorte = true
    end
end



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _GestionPool:ProcessMenus()
        if IsControlJustReleased(0, 344) then
            _R:GestionMenuInit()
        end
    end
end)

_GestionPool:RefreshIndex()
_GestionPool:MouseControlsEnabled (false)
_GestionPool:MouseEdgeEnabled (false)
_GestionPool:ControlDisablingEnabled(false)


function _R:GestionMenuInit()
    GestionMenu:Clear()
    self.GestionVehMenu(GestionMenu)
    GestionMenu:Visible(not GestionMenu:Visible())
end

local BlipsTable = {}
local blip = false
function _C:Blip()
    if blip == false then
	    for k,v in pairs(self.EntrerInstance) do
	    	local blip = AddBlipForCoord(v)

	    	SetBlipSprite(blip, 473)
	    	SetBlipDisplay(blip, 2)
	    	SetBlipScale(blip, 0.50)
	    	SetBlipColour(blip, 2)
	    	SetBlipCategory(blip, 11)
	    	SetBlipAsShortRange(blip, true)

	    	BeginTextCommandSetBlipName('STRING')
	    	AddTextComponentString("~g~Garage privé")
            EndTextCommandSetBlipName(blip)
            table.insert(BlipsTable, blip) 
        end
        blip = true
    else
        for k,v in pairs(BlipsTable) do
            RemoveBlip(v)
        end
        blip = false
    end
end