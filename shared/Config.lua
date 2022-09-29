Config = {}

Config.NPC = vector4(185.29, -916.61, 30.69, 148.52)
Config.Model = "cs_fbisuit_01"
Config.VehicleSpawn = vector4(180.45, -923.15, 30.69, 230.33)
Config.Garage = "garage1" -- Default garage for the car to be tagged too.

Config.CoinShop = {
    [1] = {
        type = "item",
        name = "weapon_pistol",
        amount = 1,
        cost = 1,
        header = "Buy Pistol",
        text = "Buy pistol for 1 coin.",
    },
    [2] = {
        type = "car",
        name = "sultan",
        cost = 1,
        header = "Buy Sultan",
        text = "Buy a Sultan for 1 coin.",
    },
}

Config.Packages = {
    ["coinpack1"] = 100,
    ["coinpack2"] = 200,
}