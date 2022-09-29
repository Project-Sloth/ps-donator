local QBCore = exports["qb-core"]:GetCoreObject()

local function GetCoins()
  local p = promise.new()
  QBCore.Functions.TriggerCallback("donator:GetCoins", function(r)
    p:resolve(r)
  end)
  return Citizen.Await(p)
end

RegisterNetEvent("donator:createMenu", function()
    local menu = {}

    local coins = GetCoins()
    menu[#menu+1] = {
      header = "Coins: "..coins,
      isMenuHeader = true
    }

    for k,v in pairs(Config.CoinShop) do 
        menu[#menu+1] = {
            header = v["header"],
            text = v["text"],
            params = {
              isServer = true,
              event = "donator:purchase",
              args = {
                  id = k,
              }
          }
        }
    end
    exports["qb-menu"]:openMenu(menu)
end)

CreateThread(function()

    local blip = AddBlipForCoord(Config.NPC)
    SetBlipSprite(blip, 351)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 50)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Donator Store")
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:SpawnPed({
        model = Config.Model,
        coords = Config.NPC,
        minusOne = true, 
        freeze = true, 
        invincible = true, 
        blockevents = true,
        spawnNow = true,
        target = {
          useModel = false,
          options = {
            {
              type = "client",
              event = "donator:createMenu",
              label = 'Donator Store',
              icon = 'fa-solid fa-circle',
            },
          },
          distance = 2.5,
        },
      })
end)

RegisterNetEvent("donator:spawnVehicle", function(model, plate)
    QBCore.Functions.SpawnVehicle(model, function(veh)
      
        SetVehicleEngineOn(veh, false, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleNumberPlateText(veh, plate)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        
    end, Config.VehicleSpawn, true)
end)