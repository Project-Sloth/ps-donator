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
    if ID == nil or Config.CoinShop[ID] == nil then -- Check to see if passed ID is actually a valid ID
        print("Cheater tried to access an invalid donator item! ID: " .. src)
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if RemoveCoins(Player.PlayerData.license, Config.CoinShop[ID]["cost"]) then

        if Config.CoinShop[ID]["type"] == "item" then
            Player.Functions.AddItem(Config.CoinShop[ID]["name"], Config.CoinShop[ID]["amount"])
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.CoinShop[ID]["name"]], "add")
        elseif Config.CoinShop[ID]["type"] == "car" then 

            local plate = GeneratePlate()
            MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                Config.CoinShop[ID]["name"],
                GetHashKey(Config.CoinShop[ID]["name"]),
                '{"engineHealth":1000.00,"bodyHealth":1000.00,"fuelLevel":100.0,"tankHealth":1000.00,}',
                plate,
                1,
                Config.Garage,
            })

            TriggerClientEvent("donator:spawnVehicle", src, Config.CoinShop[ID]["name"], plate)
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

-- REDEMPTION

QBCore.Commands.Add('redeem', 'Redeem tebex store purchase', { { name = 'id', help = 'tebex transaction id' }}, true, function(source, args)
    
    if args[1] then
        local transactionId = args[1]
        local pending = MySQL.query.await('SELECT * FROM donator_pending WHERE transactionId = ?  LIMIT 1', { transactionId })
        if pending[1] then
            if pending[1].redeemed == 0 then
                local Player = QBCore.Functions.GetPlayer(source)
                local license = Player.PlayerData.license
                AddCoins(license, Config.Packages[pending[1].package])
                print(string.format("License: %s redeemed %s", license, transactionId))
                TriggerClientEvent("QBCore:Notify", source, "Purchase Redeemed", "success")
                MySQL.update.await('UPDATE donator_pending SET redeemed = 1 WHERE transactionId = ?', { transactionId })
            else
                TriggerClientEvent("QBCore:Notify", source, "This package has already been redeemed", "error")
            end
        else
            TriggerClientEvent("QBCore:Notify", source, "Invalid transaction id", "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", source, "Invalid transaction id", "error")
    end
end, 'user')

RegisterCommand("donatorPurchase", function(source, args)
    if source == 0 then
        local data = json.decode(args[1])

        local pending = MySQL.query.await('SELECT transactionId, redeemed FROM donator_pending WHERE transactionId = ?', { data.transactionId })
        if pending[1] and pending[1].redeemed == 0 then
            local affectedRows = MySQL.update.await('UPDATE donator_pending SET package = ? WHERE transactionId = ?', { data.package, data.transactionId })
            if affectedRows then
                print(string.format("Added new pending redeem ID: %s Package: %s", data.transactionId, data.package))
            else
                print(string.format("Error adding redeem ID: %s Package: %s", data.transactionId, data.package))
            end
        else
            MySQL.Async.insert('INSERT INTO donator_pending (transactionId, package) VALUES (?, ?)', { data.transactionId, data.package })
            print(string.format("Added ID: %s Package: %s", data.transactionId, data.package))
        end
    else
        print(string.format("ID: %s tried to create a pending package", source))
    end
end, false)