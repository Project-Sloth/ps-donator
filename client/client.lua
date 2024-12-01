local NPC = nil

RegisterNetEvent("donator:createMenu", function()
    local options = {}

    local coins = lib.callback.await('donator:GetCoins', false) or 0

    options[#options + 1] = {
        title = ('Coins : %s'):format(coins),
        icon = 'star',
        iconColor = '#ffd43b',
        colorScheme = '#ffd43b',
        readOnly = true,
    }

    for id, data in pairs(config.shop) do 

        options[#options + 1] = {
            title = data.title,
            description = data.description,
            serverEvent = 'donator:purchase',
            args = {
                id = id
            }
        }
    end
    
    
    lib.registerContext({
        id = 'donator_store_menu',
        title = 'Donator Store',
        options = options,
    })

    lib.showContext('donator_store_menu')
end)

local function onEnter()
    lib.requestModel(config.model)
    NPC = CreatePed(4, config.model, config.npc.x, config.npc.y, config.npc.z, config.npc.w, false, false)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)

    if config.anim then
        lib.requestAnimDict(config.anim.dict)
        TaskPlayAnim(NPC, config.anim.dict, config.anim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
    end

    if config.scenario then
        TaskStartScenarioInPlace(NPC, config.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(NPC, {
        {
            label = 'Donator Store',
            icon = 'fa-solid fa-comment-dots',
            event = 'donator:createMenu',
        }
    })
end

local function onExit()
    DeleteEntity(NPC)
end

lib.zones.sphere({
    coords = config.npc,
    radius = 50.0,
    debug = false,
    onEnter = onEnter,
    onExit = onExit
})

CreateThread(function()

    if config.blip.enabled then
        local blip = AddBlipForCoord(config.npc)
        SetBlipSprite(blip, config.blip.sprite)
        SetBlipScale(blip, config.blip.scale)
        SetBlipColour(blip, config.blip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(config.blip.name)
        EndTextCommandSetBlipName(blip)
    end
end)