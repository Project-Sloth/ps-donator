local string = lib.string

local function GeneratePlate()
    local plate =  lib.string.random('........'):upper()
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
        lib.logger(-1, 'set_coins', string.format("Set %s coins to %s", license, amount))
    else
        MySQL.Async.insert('INSERT INTO donator (license, coins) VALUES (?, ?)', { license, amount })
        lib.logger(-1, 'set_coins', string.format("Set %s coins to %s", license, amount))
    end
end

local function AddCoins(license, amount)
    local coins = GetCoins(license)
    coins = coins + amount

    local affectedRows = MySQL.update.await('UPDATE donator SET coins = ? WHERE license = ?', { coins, license })
    if affectedRows then
        lib.logger(-1, 'add_coins', string.format("Added %s to %s", coins, license))
    else
        MySQL.Async.insert('INSERT INTO donator (license, coins) VALUES (?, ?)', { license, coins })
        lib.logger(-1, 'add_coins', string.format("Added %s to %s", coins, license))
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

local function spawnVehicle(playerId, model, coords, props)

    local tempVehicle = CreateVehicle(model, 0, 0, -100.0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do Wait(0) end

    local vehicleType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)

    local veh = CreateVehicleServerSetter(model, vehicleType, coords.x, coords.y, coords.z, coords.w)
    while not DoesEntityExist(veh) do Wait(0) end
    while GetVehicleNumberPlateText(veh) == '' do Wait(0) end

    local state = Entity(veh).state
    state:set('initVehicle', true, true)
    state:set('setVehicleProperties', props, true)

    lib.waitFor(function()
        if state.setVehicleProperties then return false end
        return true
    end, 'Failed to set vehicle properties', 5000)

    SetPedIntoVehicle(playerId, veh, -1)

    local netId = NetworkGetNetworkIdFromEntity(veh)

    return netId, veh
end

lib.callback.register('donator:GetCoins', function(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    local coins = GetCoins(license)
    return coins
end)

RegisterNetEvent("donator:purchase", function(data)
    local ID = data.id
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))

    if #(coords - vec(config.npc.x, config.npc.y, config.npc.z)) > 6.0 then -- Check to see if player is close to NPC
        print("Cheater tried to access the donator store from too far away! ID: " .. src)
        return
    end

    if ID == nil or config.shop[ID] == nil then -- Check to see if passed ID is actually a valid ID
        print("Cheater tried to access an invalid donator item! ID: " .. src)
        return
    end

    local license = GetPlayerIdentifierByType(src, 'license')

    if RemoveCoins(license, config.shop[ID].cost) then

        if config.shop[ID].type == "item" then
            exports.ox_inventory:AddItem(src, config.shop[ID].name, config.shop[ID].amount)
        elseif config.shop[ID].type == "car" then 

            local cid = nil

            if config.framework == 'QBCore' then
                local QBCore = exports['qb-core']:GetCoreObject()
                local player = QBCore.Functions.GetPlayer(src)
                cid = player.PlayerData.citizenid
            elseif config.framework == 'QBX' then
                local player = exports.qbox_core:GetPlayer(src)
                cid = player.PlayerData.citizenid
            elseif config.framework == 'SA' then
                -- Custom get player here.
            end

            if cid == nil then
                print("Invalid Framework for Donator Store")
                return
            end


            local plate = GeneratePlate()
            MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                license,
                cid,
                config.shop[ID].name,
                GetHashKey(config.shop[ID].name),
                json.encode(config.defaultVehicleMods),
                plate,
                1,
                config.Garage,
            })

            local netId, veh = spawnVehicle(src, GetHashKey(config.shop[ID].name), config.vehicleSpawn, config.defaultVehicleMods)
            SetVehicleNumberPlateText(veh, plate)

            TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', src, plate)

        end
    else 
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Donator Store",
            description = "You do not have enough coins to purchase this item!",
            type = "error",
        })
    end
end)


lib.addCommand('addcoins', {
    help = 'Give Player Coins (Admin Only)',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'amount',
            type = 'number',
            help = 'Number of the coins to give, or blank to give 1',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)

    local license = GetPlayerIdentifierByType(source, 'license')
    if license then
        AddCoins(license, tonumber(args.amount) or 1)
    else
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Donator Store",
            description = "Invalid Player",
            type = "error",
        })
    end

end)

lib.addCommand('setcoins', {
    help = 'Set Player Coins (Admin Only)',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'amount',
            type = 'number',
            help = 'Number of the coins to set',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)

    local license = GetPlayerIdentifierByType(source, 'license')
    if license then
        SetCoins(license, tonumber(args.amount))
    else
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Donator Store",
            description = "Invalid Player",
            type = "error",
        })
    end

end)

-- REDEMPTION

lib.addCommand('redeem', {
    help = 'Redeem tebex store purchase',
    params = {
        {
            name = 'id',
            type = 'string',
            help = 'tebex transaction id',
        },
    },
    restricted = 'group.user'
}, function(source, args, raw)

    local transactionId = args.id
    local pending = MySQL.query.await('SELECT * FROM donator_pending WHERE transactionId = ?  LIMIT 1', { transactionId })
    if pending[1] then
        if pending[1].redeemed == 0 then
            local license = GetPlayerIdentifierByType(source, 'license')

            AddCoins(license, config.shop[pending[1].package].cost)
            lib.logger(-1, 'donator_redeem', string.format("License: %s redeemed %s", license, transactionId))

            TriggerClientEvent("ox_lib:notify", source, {
                title = "Donator Store",
                description = "Purchase Redeemed",
                type = "success",
            })

            MySQL.update.await('UPDATE donator_pending SET redeemed = 1 WHERE transactionId = ?', { transactionId })
        else
            TriggerClientEvent("ox_lib:notify", source, {
                title = "Donator Store",
                description = "This package has already been redeemed",
                type = "error",
            })
        end
    else
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Donator Store",
            description = "Invalid transaction id",
            type = "error",
        })
    end

end)

-- Console Tebex Command

RegisterCommand("donatorPurchase", function(source, args)
    -- Only allow console to run this command.
    if source ~= 0 then return end

    local data = json.decode(args[1])

    local pending = MySQL.query.await('SELECT transactionId, redeemed FROM donator_pending WHERE transactionId = ?', { data.transactionId })
    if pending[1] and pending[1].redeemed == 0 then
        local affectedRows = MySQL.update.await('UPDATE donator_pending SET package = ? WHERE transactionId = ?', { data.package, data.transactionId })
        if affectedRows then
            lib.logger(-1, 'donatorPurchase', string.format("Added new pending redeem ID: %s Package: %s", data.transactionId, data.package))
        else
            lib.logger(-1, 'donatorPurchase', string.format("Error adding redeem ID: %s Package: %s", data.transactionId, data.package))
        end
    else
        MySQL.Async.insert('INSERT INTO donator_pending (transactionId, package) VALUES (?, ?)', { data.transactionId, data.package })
        lib.logger(-1, 'donatorPurchase', string.format("Added ID: %s Package: %s", data.transactionId, data.package))
    end
end, false)