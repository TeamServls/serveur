gangsData = nil
gangsKit = {
	Weapons = {
		[1] = {
			{name = 'WEAPON_KNIFE', price = 15000000},
			{name = 'WEAPON_PISTOL', price = 115000000},
			{name = 'WEAPON_MICROSMG', price = 1700000000},
			{name = 'WEAPON_ASSAULTSMG', price = 37500000000}
		},
		[2] = {}
	}
}

RegisterNetEvent('gb:SyncGangs')
AddEventHandler('gb:SyncGangs', function(data)
	gangsData = data
end)

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

	while (UpdateOnscreenKeyboard() ~= 1) and (UpdateOnscreenKeyboard() ~= 2) do
		DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		return GetOnscreenKeyboardResult()
	else
		return nil
	end
end

function ShowNotification(text)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(false, false)
end

function VectorToArray(vector)
	return {x = vector.x, y = vector.y, z = vector.z}
end