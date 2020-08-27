ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Recupere les véhicules
ESX.RegisterServerCallback('ruby_garage:getVehicles', function(source, cb)
	local _source = source
	local identifier = ""
	identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
		['@identifier'] = identifier
	}, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules$

--Recupere les véhicules
ESX.RegisterServerCallback('ruby_garage:getVehiclesMecano', function(source, cb)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles INNER JOIN users ON owned_vehicles.owner = users.identifier WHERE fourrieremecano = 1", nil, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules

--Stock les véhicules
ESX.RegisterServerCallback('ruby_garage:stockv',function(source, cb, vehicleProps)
	local identifier = ""
	local _source = source
	identifier = GetPlayerIdentifiers(_source)[1]

	local vehplate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles where plate=@plate and owner=@identifier",{['@plate'] = vehplate, ['@identifier'] = identifier}, function(result)
		if result[1] ~= nil then
			local vehprop = json.encode(vehicleProps)
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE plate=@plate",{
					['@vehprop'] = vehprop,
					['@plate'] = vehplate
				}, function(rowsChanged)
					cb(true)
				end)
			else
				print("[esx_ruby_garage] player "..identifier..' tried to spawn a vehicle with hash:'..vehiclemodel..". his original vehicle: "..originalvehprops.model)
				DropPlayer(_source, "RUBY-AC | Desync véhicule - Cheat Engine détécté.")
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)
--Fin stock les vehicules

ESX.RegisterServerCallback('ruby_garage:stockvmecano',function(source,cb, vehicleProps)
	local _source = source
	local plate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model
	local identifier = GetPlayerIdentifiers(_source)[1]
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles where plate=@plate",{['@plate'] = plate}, function(result)
		if result[1] ~= nil then
			local vehprop = json.encode(vehicleProps)
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE plate=@plate",{
					['@vehprop'] = vehprop,
					['@plate'] = plate
				}, function(rowsChanged)
					cb(true)
				end)
			else
				TriggerEvent('nb_menuperso:bancheaterplayer', _source)
				print("[esx_ruby_garage] player "..identifier..' tried to spawn a vehicle with hash:'..vehiclemodel..". his original vehicle: "..originalvehprops.model)
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)

--Change le state du véhicule
RegisterServerEvent('ruby_garage:modifystate')
AddEventHandler('ruby_garage:modifystate', function(plate, stored)
	MySQL.Async.execute("UPDATE owned_vehicles SET `stored` =@stored WHERE plate=@plate",{
		['@stored'] = stored,
		['@plate'] = plate
	})
end)	
--Fin change le state du véhicule

RegisterServerEvent('ruby_garage:ChangeStateFromFourriereMecano')
AddEventHandler('ruby_garage:ChangeStateFromFourriereMecano', function(vehicleProps, fourrieremecano)
	local _source = source
	local vehicleplate = vehicleProps.plate
	local fourrieremecano = fourrieremecano
	
	MySQL.Async.execute("UPDATE owned_vehicles SET fourrieremecano =@fourrieremecano WHERE plate=@plate",{
		['@fourrieremecano'] = fourrieremecano,
		['@plate'] = vehicleplate
	})
end)


RegisterServerEvent('ruby_garage:renamevehicle')
AddEventHandler('ruby_garage:renamevehicle', function(vehicleplate, name)
	MySQL.Sync.execute("UPDATE owned_vehicles SET vehiclename =@vehiclename WHERE plate=@plate",{['@vehiclename'] = name , ['@plate'] = vehicleplate})
end)


ESX.RegisterServerCallback('ruby_garage:getOutVehicles',function(source, cb)	
	local _source = source
	local identifier = ""
	identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier AND (`stored` = FALSE OR fourrieremecano = TRUE)",{
		['@identifier'] = identifier
	}, function(result)
		cb(result)
	end)
end)

--Foonction qui check l'argent
ESX.RegisterServerCallback('ruby_garage:checkMoney', function(source, cb, money)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.get('money') >= money then
		xPlayer.removeMoney(money)
		cb(true)
	else
		cb(false)
	end
end)
--Fin Foonction qui check l'argent

-- Fonction qui change les etats sorti en rentré lors d'un restart


--if Config.StoreOnServerStart then
--	AddEventHandler('onMySQLReady', function()
--		MySQL.Async.execute("UPDATE owned_vehicles SET `stored`=true WHERE `stored`=false", {})
--	end)
--end


-- Fin Fonction qui change les etats sorti en rentré lors d'un restart

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
