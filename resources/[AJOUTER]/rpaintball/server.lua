ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local default = {
    matchInProgress = false,
    currentPlayers = {},
    queue = {timer = false},
    matchEnds = false,
    prizePool = 0
}

local defaultDefault = {
    matchInProgress = false,
    currentPlayers = {},
    queue = {timer = false},
    matchEnds = false,
    prizePool = 0
}

isplayerActive = function(id)
    local playerTable = GetPlayers()
    for k, v in pairs(playerTable) do
        if tonumber(v) == id then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        for i = 1, #default.currentPlayers do -- in case 'playerDropped' doesn't work
            if default.currentPlayers[i] then
                if not isplayerActive(default.currentPlayers[i].id) then
                    print(default.currentPlayers[i].id) 
                    table.remove(default.currentPlayers, i)
                end
            end
        end
        if default.matchInProgress then
            if #default.currentPlayers < Config.RequiredPlayers then -- if there are not enough players online, cancel the current match
                for i = 1, #default.currentPlayers do
                    TriggerClientEvent('loaf_paintball:stop', default.currentPlayers[i].id)
                    default = json.decode(json.encode(defaultDefault))
                end
                default.currentPlayers = {}
            end
        end
        Wait(2500)
    end
end)

Citizen.CreateThread(function()
    while true do
        if not default.matchInProgress then
            if #default.currentPlayers >= Config.RequiredPlayers then
                if not default.queue.timer then
                    local queuetime = 60 * Config.QueueTime
                    default.queue.timer = os.time() + queuetime
                end
                if default.queue.timer - os.time() <= 0 then
                    default.queue.timer = false
                    default.matchInProgress = true
                    local matchends = 60 * Config.MatchLength
                    default.matchEnds = os.time() + matchends
                    for i = 1, #default.currentPlayers do
                        local xPlayer = ESX.GetPlayerFromId(default.currentPlayers[i].id)
                        xPlayer.removeMoney(Config.Price)
                        default.prizePool = default.prizePool + Config.Price
                        TriggerClientEvent('loaf_paintball:start', default.currentPlayers[i].id)
                    end
                end
            end
        end
        Wait(500)
    end
end)

local SendingPlayers = {}
RegisterNetEvent("PAINTBALL:Debug")
AddEventHandler("PAINTBALL:Debug", function(status)
    player = source
    if status then
        table.insert(SendingPlayers, player)
    else
        for k,v in pairs(SendingPlayers) do
            if v == player then
                table.remove(SendingPlayers, k)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local text = ''
        local other = ''
        if not default.matchInProgress then
            if #default.currentPlayers >= 1 then
                text = #default.currentPlayers .. Config.Translations['in_queue']
                if default.queue.timer then
                    text = text .. Config.Translations['seconds_starts'] .. default.queue.timer - os.time()
                end
            end
            if #default.currentPlayers < Config.RequiredPlayers then
                default.queue.timer = false
            end
        else
            text = Config.Translations['match_progress']
            other = default.matchEnds - os.time()
            if default.matchEnds - os.time() <= Config.DisplayWinner then
                local killsTable = {}
                for i = 1, #default.currentPlayers do
                    killsTable[tostring(default.currentPlayers[i].id)] = default.currentPlayers[i].kills
                end
                local winner = tonumber(getMax(killsTable))
                local xPlayer = ESX.GetPlayerFromId(winner)
                xPlayer.addMoney(default.prizePool)

                for i = 1, #default.currentPlayers do
                    if default.currentPlayers[i].id == winner then
                        winner = default.currentPlayers[i]
                    end
                end
                for i = 1, #default.currentPlayers do
                    TriggerClientEvent('loaf_paintball:matchOver', default.currentPlayers[i].id, json.encode(winner), json.encode(default.currentPlayers[i]))
                end
                default = json.decode(json.encode(defaultDefault))
                Wait(Config.DisplayWinner * 1000)
                default.matchInProgress = false
            end
        end
        for k,v in pairs(SendingPlayers) do
            TriggerClientEvent('loaf_paintball:queueInfo', v, text, other)
        end
        Wait(1500)
    end
end)

RegisterServerEvent('loaf_paintball:join')
AddEventHandler('loaf_paintball:join', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getMoney() >= Config.Price then
        if not default.matchInProgress then
            local init = false
            for i = 1, #default.currentPlayers do
                if default.currentPlayers[i] then
                    if default.currentPlayers[i].id == src then
                        init = true
                        table.remove(default.currentPlayers, i)
                    end
                end
            end
            if not init then
                table.insert(default.currentPlayers, {id = src, kills = 0, deaths = 0})
            end
        end
    else
        TriggerClientEvent('loaf_paintball:hudNotify', src, Config.Translations['no_money'])
    end
end)

RegisterServerEvent('loaf_paintball:kill')
AddEventHandler('loaf_paintball:kill', function(killed)
    local src = source
    if default.matchInProgress then
        local killedPlaying = false
        if isplayerActive(killed) then
            for i = 1, #default.currentPlayers do
                if default.currentPlayers[i].id == killed then
                    killedPlaying = true
                    default.currentPlayers[i].deaths = default.currentPlayers[i].deaths + 1
                    TriggerClientEvent('loaf_paintball:die', default.currentPlayers[i].id)
                end
            end
        end
        if killedPlaying then
            for i = 1, #default.currentPlayers do
                if default.currentPlayers[i].id == src then
                    default.currentPlayers[i].kills = default.currentPlayers[i].kills + 1
                    TriggerClientEvent('loaf_paintball:hudNotify', default.currentPlayers[i].id, Config.Translations['you_killed'] .. ': ~r~' .. GetPlayerName(killed))
                elseif default.currentPlayers[i].id == killed then
                    TriggerClientEvent('loaf_paintball:hudNotify', default.currentPlayers[i].id, Config.Translations['you_got_killed'] .. ': ~r~' .. GetPlayerName(src))
                    TriggerClientEvent('loaf_paintball:died', default.currentPlayers[i].id, src)
                else
                    TriggerClientEvent('loaf_paintball:hudNotify', default.currentPlayers[i].id, GetPlayerName(killed) .. Config.Translations['killed_by'] .. GetPlayerName(src))
                end
            end
        end
    end
end)

getMax = function(data)
    local max_val, key = -math.huge
    for k, v in pairs(data) do
        if v > max_val then
            max_val, key = v, k
        end
    end
    return key
end




RegisterNetEvent("RED_PAINTBALL:AjouterScore")
AddEventHandler("RED_PAINTBALL:AjouterScore", function(kill, mort)
    local _source = source
    local steam = nil
    for i = 0, GetNumPlayerIdentifiers(_source) - 1 do
        local id = GetPlayerIdentifier(_source, i)
        if string.find(id, "license") then
            steam = id
        end
   end

    MySQL.Async.fetchAll("SELECT * FROM paintball_leaderboard WHERE id = @id", {["@id"] = steam}, function(result)
        while result == nil do Wait(1) end
        for k,v in pairs(result) do
            MySQL.Async.execute("UPDATE paintball_leaderboard SET id = @id, `kill` = `kill` + @kill, mort = mort + @mort WHERE id = @id", {["@id"] = steam, ["@kill"] = kill, ["@mort"] = mort}, function(result)
                while result == nil do Wait(100) end
            end)
            TriggerEvent("RED_PAINTBALL:GetScoreboard", _source)
            return
        end
        MySQL.Async.execute("INSERT INTO paintball_leaderboard VALUES (@id, 0, 0)", {["@id"] = steam}, function(result)
            while result == nil do Wait(100) end
        end)
        MySQL.Async.execute("UPDATE paintball_leaderboard SET id = @id, `kill` = `kill` + @kill, mort = mort + @mort WHERE id = @id", {["@id"] = steam, ["@kill"] = kill, ["@mort"] = mort}, function(result)
            while result == nil do Wait(100) end
        end)
        TriggerEvent("RED_PAINTBALL:GetScoreboard", _source)
        return
    end)
end)



RegisterNetEvent("RED_PAINTBALL:GetScoreboard")
AddEventHandler("RED_PAINTBALL:GetScoreboard", function(sourceJ)
    if sourceJ ~= nil then
        _source = sourceJ
    else
        _source = source
    end
    MySQL.Async.fetchAll("SELECT * FROM paintball_leaderboard INNER JOIN users ON paintball_leaderboard.id = users.identifier ORDER BY paintball_leaderboard.kill DESC", {}, function(result)
        while result == nil do Wait(100) end
        TriggerClientEvent("RED_PAINTBALL:UpdateScoreboard", _source, result)
    end)
end)