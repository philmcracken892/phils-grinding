-- Configuration file for metal bar crafting
Config = {}

-- Distance for interacting with the grinding wheel
Config.InteractionDistance = 2.0

-- Crafting recipes
Config.CraftingRecipes = {
    {
        result = 'gold_bar',
        label = 'Gold Bar',
        requiredItems = { { item = 'gold_ore', amount = 5 } },
        craftTime = 5000 -- in milliseconds
    },
    {
        result = 'silver_bar',
        label = 'Silver Bar',
        requiredItems = { { item = 'silver_ore', amount = 5 } },
        craftTime = 5000
    },
    {
        result = 'iron_bar',
        label = 'Iron Bar',
        requiredItems = { { item = 'iron_ore', amount = 5 } },
        craftTime = 5000
    },
    {
        result = 'lead_bar',
        label = 'Lead Bar',
        requiredItems = { { item = 'lead_ore', amount = 5 } },
        craftTime = 5000
    },
    {
        result = 'copper_bar',
        label = 'Copper Bar',
        requiredItems = { { item = 'copper_ore', amount = 5 } },
        craftTime = 5000
    },
    {
        result = 'steel_bar',
        label = 'Steel Bar',
        requiredItems = { { item = 'iron_ore', amount = 3 }, { item = 'coal', amount = 2 } },
        craftTime = 6000
    },
    {
        result = 'zinc_bar',
        label = 'Zinc Bar',
        requiredItems = { { item = 'zinc_ore', amount = 5 } },
        craftTime = 5000
    },
    {
        result = 'brass_bar',
        label = 'Brass Bar',
        requiredItems = { { item = 'copper_ore', amount = 3 }, { item = 'zinc_ore', amount = 2 } },
        craftTime = 6000
    }
}