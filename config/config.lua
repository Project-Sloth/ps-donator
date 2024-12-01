config = {

    framework = 'QBCore', -- Framework to use. (QBCore/QBX/SA)
    giveKeysEvent = 'qb-vehiclekeys:client:GiveKeys', -- Vehicle Keys Give Keys event Name.

    npc = vector4(185.29, -916.61, 29.69, 148.52), -- Location for the NPC to spawn.
    model = "cs_fbisuit_01", -- NPC Model.
    vehicleSpawn = vector4(180.45, -923.15, 30.10, 230.33), -- Location for car to spawn.
    garage = "garage1", -- Default garage for the car to be tagged too.

    blip = {
        enabled = true,
        sprite = 351,
        scale = 1.0,
        color = 50,
        name = "Donator Store",
    },

    shop = {
        {
            type = "item", -- Item/Car
            name = "weapon_pistol", -- Name of Item.
            amount = 1, -- amount of items to give.
            cost = 1, -- Coin Cost to purchase item.
            title = "Buy Pistol", -- Title Text.
            description = "Buy pistol for 1 coin.", -- description Text.
        },
        {
            type = "car", -- Item/Car
            name = "sultan", -- Model of the vehicle to spawn.
            cost = 1, -- Coin Cost to purchase item.
            title = "Buy Sultan", -- Title Text.
            description = "Buy a Sultan for 1 coin.", -- description Text.
        },
    },

    defaultVehicleMods = {
        engineHealth = 1000.0,
        bodyHealth = 1000.0,
        fuelLevel = 100.0,
        tankHealth = 1000.0,
    },

    packages = {
        ["coinpack1"] = 100, -- Number of coins given on redemption.
        ["coinpack2"] = 200, -- Number of coins given on redemption.
    },
}