ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetGangData()
	local data = LoadResourceFile('GangsBuilder', 'data/gangData.json')
	return data and json.decode(data) or {}
end

RegisterServerEvent('gb:addGang')
AddEventHandler('gb:addGang', function(data)
    MySQL.Async.execute([[
    INSERT INTO `addon_account` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
    INSERT INTO `datastore` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
    INSERT INTO `addon_inventory` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
    INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@gangName, @gangLabel, 1);
    INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
    (@gangName, 0, 'rookie', 'Associé', 0, '{}', '{}'),
    (@gangName, 1, 'member', 'Soldat', 0, '{}', '{}'),
    (@gangName, 2, 'elite', 'Elite', 0, '{}', '{}'),
    (@gangName, 3, 'lieutenant', 'Lieutenant', 0, '{}', '{}'),
    (@gangName, 4, 'viceboss', 'Bras Droit', 0, '{}', '{}'),
    (@gangName, 5, 'boss', 'Patron', 0, '{}', '{}')
;
    ]], {
		['@gangName'] = data.Name,
		['@gangLabel'] = data.Label,
		['@gangSociety'] = 'society_' .. data.Name
	}, function(rowsChanged)
        local GangData = GetGangData()
        table.insert(GangData, data)
    
        SaveResourceFile('GangsBuilder', 'data/gangData.json', json.encode(GangData))
        TriggerClientEvent('gb:SyncGangs', -1, GangData)
	end)
end)

RegisterServerEvent('gb:editGang')
AddEventHandler('gb:editGang', function(i, data)
    local GangData = GetGangData()
    GangData[i] = data

    SaveResourceFile('GangsBuilder', 'data/gangData.json', json.encode(GangData))
    TriggerClientEvent('gb:SyncGangs', -1, GangData)
end)

RegisterServerEvent('gb:deleteGang')
AddEventHandler('gb:deleteGang', function(i)
    local GangData = GetGangData()
    table.remove(GangData, i)

    SaveResourceFile('GangsBuilder', 'data/gangData.json', json.encode(GangData))
    TriggerClientEvent('gb:SyncGangs', -1, GangData)
end)

RegisterServerEvent('gb:requestSync')
AddEventHandler('gb:requestSync', function()
    TriggerClientEvent('gb:SyncGangs', source, GetGangData())
end)