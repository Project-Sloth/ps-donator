local QBCore = exports["qb-core"]:GetCoreObject()

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

local function GetCoins(license)
    local coins = MySQL.Sync.fetchScalar('SELECT coins FROM donator WHERE license = ?', { license })
    if coins ~= nil then
        return coins
    else
        MySQL.Async.insert('INSERT INTO donator (license, coins) VALUES (?, 0)', { license })
        return 0
    end
end

local function SetCoins(license, amount)
    local affectedRows = MySQL.update.await('UPDATE donator SET coins = ? WHERE license = ?', { amount, license })
    if affectedRows then
        print(string.format("Set %s coins to %s", license, amount))
    else
        MySQL.Async.insert('INSERT INTO donator (license, coins) VALUES (?, ?)', { license, amount })
        print(string.format("Set %s coins to %s", license, amount))
    end
end

local function AddCoins(license, amount)
    local coins = GetCoins(license)
    coins = coins + amount

    local affectedRows = MySQL.update.await('UPDATE donator SET coins = ? WHERE license = ?', { coins, license })
    if affectedRows then
        print(string.format("Added %s to %s", coins, license))
    else
        MySQL.Async.insert('INSERT INTO donator (license, coins) VALUES (?, ?)', { license, coins })
        print(string.format("Added %s to %s", coins, license))
    end
end

local function RemoveCoins(license, amount)
    local coins = GetCoins(license)
    local total = (coins - amount)
    if total < 0 then
        return false
    else
        SetCoins(license, total)
        return true
    end
end

QBCore.Functions.CreateCallback("donator:GetCoins", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local license = Player.PlayerData.license
    local coins = GetCoins(license)
    cb(coins)
end)

RegisterNetEvent("donator:purchase", function(data)
    local ID = data.id
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
    if #(coords - Config.NPC.xyz) > 6.0 then -- Check to see if player is close to NPC
        print("Cheater tried to access the donator store from too far away! ID: " .. src)
        return
    end
    if ID == nil or Config["Donations"][ID] == nil then -- Check to see if passed ID is actually a valid ID
        print("Cheater tried to access an invalid donator item! ID: " .. src)
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if RemoveCoins(Player.PlayerData.license, Config["Donations"][ID]["cost"]) then

        if Config["Donations"][ID]["type"] == "item" then
            Player.Functions.AddItem(Config["Donations"][ID]["name"], Config["Donations"][ID]["amount"])
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config["Donations"][ID]["name"]], "add")
        elseif Config["Donations"][ID]["type"] == "car" then 

            local plate = GeneratePlate()
            MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                Config["Donations"][ID]["name"],
                GetHashKey(Config["Donations"][ID]["name"]),
                '{"engineHealth":1000.00,"bodyHealth":1000.00,"fuelLevel":100.0,"tankHealth":1000.00,}',
                plate,
                1,
                Config.Garage,
            })

            TriggerClientEvent("donator:spawnVehicle", src, Config["Donations"][ID]["name"], plate)
        end
    else 
        TriggerClientEvent("QBCore:Notify", src, "You do not have enough coins to purchase this item!", "error")
    end
end)

QBCore.Commands.Add('addcoins', 'Give Player Coins (God Only)', { { name = 'id', help = 'ID of player' }, { name = "amount", help = "Number of coins to add" }}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))

    if Player then
        AddCoins(Player.PlayerData.license, tonumber(args[2]))
    else
        TriggerClientEvent('QBCore:Notify', src, "Player not online", 'error')
    end
end, 'god')

QBCore.Commands.Add('setcoins', 'Set Player Coins (God Only)', { { name = 'id', help = 'ID of player' }, { name = "amount", help = "Number of coins to set" }}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))

    if Player then
        SetCoins(Player.PlayerData.license, tonumber(args[2]))
    else
        TriggerClientEvent('QBCore:Notify', src, "Player not online", 'error')
    end
end, 'god')

