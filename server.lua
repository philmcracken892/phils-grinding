local RSGCore = exports['rsg-core']:GetCoreObject()


RegisterNetEvent('metal_crafting:registerUsableItem')
AddEventHandler('metal_crafting:registerUsableItem', function()
    RSGCore.Functions.CreateUseableItem('grindingwheel', function(source)
        TriggerClientEvent('metal_crafting:client:useGrindingWheel', source)
    end)
end)


RegisterNetEvent('metal_crafting:craftItem')
AddEventHandler('metal_crafting:craftItem', function(resultItem, requiredItems, craftTime)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    
    local hasItems = true
    for _, reqItem in ipairs(requiredItems) do
        local item = Player.Functions.GetItemByName(reqItem.item)
        if not item or item.amount < reqItem.amount then
            hasItems = false
            break
        end
    end
    
    if hasItems then
       
        for _, reqItem in ipairs(requiredItems) do
            Player.Functions.RemoveItem(reqItem.item, reqItem.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[reqItem.item], 'remove', reqItem.amount)
        end
        
       
        Player.Functions.AddItem(resultItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[resultItem], 'add', 1)
       
       
        TriggerClientEvent('metal_crafting:startCrafting', src, {
            label = RSGCore.Shared.Items[resultItem].label
        }, craftTime)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crafting',
            description = 'You don\'t have the required items!',
            type = 'error'
        })
    end
end)


RegisterNetEvent('metal_crafting:removeGrindingWheelItem')
AddEventHandler('metal_crafting:removeGrindingWheelItem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem('grindingwheel', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['grindingwheel'], 'remove', 1)
    end
end)


RegisterNetEvent('metal_crafting:addGrindingWheelItem')
AddEventHandler('metal_crafting:addGrindingWheelItem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem('grindingwheel', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['grindingwheel'], 'add', 1)
    end
end)


Citizen.CreateThread(function()
    RSGCore.Functions.CreateUseableItem('grindingwheel', function(source)
        TriggerClientEvent('metal_crafting:client:useGrindingWheel', source)
    end)
end)