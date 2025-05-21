local RSGCore = exports['rsg-core']:GetCoreObject()
local ox_lib = exports.ox_lib


local function openCraftingMenu()
    local menuOptions = {}
    for _, recipe in ipairs(Config.CraftingRecipes) do
        local requiredItemsDesc = {}
        for _, reqItem in ipairs(recipe.requiredItems) do
            local itemData = RSGCore.Shared.Items[reqItem.item]
            if itemData then
                table.insert(requiredItemsDesc, reqItem.amount .. 'x ' .. itemData.label)
            else
                table.insert(requiredItemsDesc, reqItem.amount .. 'x Unknown Item')
            end
        end
        table.insert(menuOptions, {
            title = 'Craft ' .. recipe.label,
            description = 'Requires: ' .. table.concat(requiredItemsDesc, ', '),
            onSelect = function()
                TriggerServerEvent('metal_crafting:craftItem', recipe.result, recipe.requiredItems, recipe.craftTime)
            end
        })
    end

    ox_lib:registerContext({
        id = 'metal_crafting_menu',
        title = 'Metal Crafting',
        options = menuOptions
    })

    ox_lib:showContext('metal_crafting_menu')
end


local function registerGrindingWheelTargeting(model)
    exports.ox_target:addModel(model, {
        {
            name = 'craft_metal_bars',
            event = 'metal_crafting:client:openCraftingMenu',
            icon = 'fas fa-hammer',
            label = 'Craft Metal Bars',
            distance = Config.InteractionDistance,
            canInteract = function(entity)
                return true
            end
        },
        {
            name = 'pickup_grindingwheel',
            event = 'metal_crafting:client:pickupGrindingWheel',
            icon = 'fas fa-hand-holding',
            label = 'Pick Up Grinding Wheel',
            distance = Config.InteractionDistance,
            canInteract = function(entity)
                return true
            end
        }
    })
end

local function placeGrindingWheel()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local placeCoords = vector3(
        playerCoords.x + (forward.x * 1.0),
        playerCoords.y + (forward.y * 1.0),
        playerCoords.z - 1.0
    )

   
    local model = GetHashKey('p_grindingwheel01x')
    RequestModel(model)
    
    
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(model) then
        lib.notify({
            title = 'Error',
            description = 'Failed to load grinding wheel model',
            type = 'error'
        })
        return
    end

   
    ExecuteCommand('closeInv')
    Wait(500)
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CROUCH_INSPECT", 0, true)
    Wait(2000)
    
    
    local object = CreateObject(model, placeCoords.x, placeCoords.y, placeCoords.z, true, true, true)
    
    
    ClearPedTasks(playerPed)
    
    if DoesEntityExist(object) then
        
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetEntityAsMissionEntity(object, true, true)
        
        
        lib.notify({
            title = 'Grinding Wheel',
            description = 'Grinding wheel placed successfully',
            type = 'success'
        })

       
        TriggerServerEvent('metal_crafting:removeGrindingWheelItem')
    else
        lib.notify({
            title = 'Error',
            description = 'Failed to place grinding wheel',
            type = 'error'
        })
    end

   
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('metal_crafting:startCrafting')
AddEventHandler('metal_crafting:startCrafting', function(recipe, craftTime)
    local ped = PlayerPedId()
    local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
    
   
    local playerCoords = GetEntityCoords(ped)
    local model = GetHashKey('p_grindingwheel01x')
    local grindingWheel = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, model, false, false, false)
    
    if not DoesEntityExist(grindingWheel) then
        lib.notify({
            title = 'Crafting',
            description = 'No grinding wheel found nearby',
            type = 'error'
        })
        return
    end
    
   
    local wheelCoords = GetEntityCoords(grindingWheel)
    
    
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, anim1, 0, true)
    
   
    local spark_group = "scr_excellente"
    local spark_name = "scr_mech_fire"
    local smoke_group = "scr_dm_ftb"
    local smoke_name = "scr_mp_chest_spawn_smoke"
    local fx_scale = 0.3 
    
    
    RequestNamedPtfxAsset(spark_group)
    RequestNamedPtfxAsset(smoke_group)
    
    local timeout = 0
    while (not HasNamedPtfxAssetLoaded(spark_group) or not HasNamedPtfxAssetLoaded(smoke_group)) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end
    
    
    local function CreateSparkEffect()
        UseParticleFxAsset(spark_group)
       
        local sparkCoords = vector3(wheelCoords.x, wheelCoords.y, wheelCoords.z + 0.2)
        StartParticleFxNonLoopedAtCoord(spark_name, sparkCoords, 0.0, 0.0, 0.0, fx_scale, false, false, false, true)
    end
    
    
    local function CreateSmokeEffect()
        UseParticleFxAsset(smoke_group)
        
        local offsetX = math.random(-10, 10) / 100
        local offsetY = math.random(-10, 10) / 100
        local smokeCoords = vector3(wheelCoords.x + offsetX, wheelCoords.y + offsetY, wheelCoords.z + 0.3)
        StartParticleFxNonLoopedAtCoord(smoke_name, smokeCoords, 0.0, 0.0, 0.0, fx_scale, false, false, false, true)
    end
    
   
    local effectsThread = CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < craftTime do
            
            if (GetGameTimer() - startTime) % 1000 < 500 then
                CreateSparkEffect()
            else
                CreateSmokeEffect()
            end
            Wait(250) 
        end
    end)
    
    
   
    if lib.progressBar({
        duration = craftTime,
        label = 'Crafting ' .. recipe.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            sprint = true
        }
    }) then
       
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        
        lib.notify({
            title = 'Crafting',
            description = 'Successfully crafted ' .. recipe.label,
            type = 'success'
        })
    else
       
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        
        lib.notify({
            title = 'Crafting',
            description = 'Crafting cancelled',
            type = 'error',
            icon = 'ban'
        })
    end
    
   
    
    
    
    if effectsThread then
        TerminateThread(effectsThread)
    end
end)



RegisterNetEvent('metal_crafting:client:openCraftingMenu')
AddEventHandler('metal_crafting:client:openCraftingMenu', function()
    openCraftingMenu()
end)

RegisterNetEvent('metal_crafting:client:pickupGrindingWheel')
AddEventHandler('metal_crafting:client:pickupGrindingWheel', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local model = GetHashKey('p_grindingwheel01x')
    local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, model, false, false, false)

    if DoesEntityExist(object) then
        
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CROUCH_INSPECT", 0, true)
        Wait(2000)
        ClearPedTasks(playerPed)
        
        NetworkRequestControlOfEntity(object)
        local timeout = 0
        while not NetworkHasControlOfEntity(object) and timeout < 50 do
            timeout = timeout + 1
            Wait(10)
        end
        
        if NetworkHasControlOfEntity(object) or timeout >= 50 then
            DeleteObject(object)
            TriggerServerEvent('metal_crafting:addGrindingWheelItem')
            lib.notify({
                title = 'Grinding Wheel',
                description = 'Grinding wheel picked up',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Error',
                description = 'Failed to get control of grinding wheel',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Grinding Wheel',
            description = 'No grinding wheel found nearby',
            type = 'error'
        })
    end
end)


RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
   
    TriggerServerEvent('metal_crafting:registerUsableItem')
end)


RegisterNetEvent('metal_crafting:client:useGrindingWheel')
AddEventHandler('metal_crafting:client:useGrindingWheel', function()
    placeGrindingWheel()
end)


RegisterNetEvent('metal_crafting:client:placeGrindingWheel')
AddEventHandler('metal_crafting:client:placeGrindingWheel', function()
    placeGrindingWheel()
end)


CreateThread(function()
   
    registerGrindingWheelTargeting(GetHashKey('p_grindingwheel01x'))
    
   
    Wait(1000)
    
end)