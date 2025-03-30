Config = {}

-- Shop location (using x, y, z format to prevent vector3 errors)
Config.ShopLocation = { x = -1500.0, y = -200.0, z = 14.0 } -- Default location, change to your preferred spot
Config.ShopBlip = {
    Sprite = 110,
    Color = 1,
    Display = 4,
    Scale = 0.8,
    Name = "Weapons Market"
}

-- Interaction settings
Config.InteractionDistance = 3.0
Config.InteractionKey = 38 -- E key
Config.InteractionText = "Press ~INPUT_CONTEXT~ to access the weapons market"

-- Delivery settings
Config.DeliveryDistance = {min = 100.0, max = 300.0} -- Min and max distance for delivery point
Config.DeliveryWaitTime = 60 -- Time in seconds to wait before NPC spawns
Config.DeliveryTimeout = 900 -- Time in seconds before delivery expires (15 minutes)

-- NPC settings
Config.DeliveryNPC = {
    model = "s_m_m_highsec_01", -- NPC model
    scenario = "WORLD_HUMAN_SMOKING" -- NPC animation
}

-- UI settings
Config.UISettings = {
    backgroundColor = "rgba(0, 0, 0, 0.8)",
    textColor = "#FFFFFF",
    accentColor = "#ff9f1c",
    errorColor = "#e63946",
    successColor = "#2a9d8f",
    fontSize = "1rem",
    borderRadius = "5px"
}

-- Weapons categories
Config.WeaponCategories = {
    "Handguns",
    "Submachine Guns",
    "Shotguns",
    "Assault Rifles",
    "Sniper Rifles",
    "Heavy Weapons",
    "Melee Weapons",
    "Thrown Weapons"
}

-- Users with access to the weapon shop
Config.Users = {
    ["admin"] = {
        password = "admin123",
        name = "Administrator",
        weapons = {
            ["WEAPON_PISTOL"] = 1000,
            ["WEAPON_SMG"] = 5000,
            ["WEAPON_CARBINERIFLE"] = 10000,
            ["WEAPON_SNIPERRIFLE"] = 15000,
            ["WEAPON_BAT"] = 500
        }
    },
    ["dealer1"] = {
        password = "dealer123",
        name = "Gun Dealer",
        weapons = {
            ["WEAPON_PISTOL"] = 1500,
            ["WEAPON_COMBATPISTOL"] = 2000,
            ["WEAPON_MICROSMG"] = 6000
        }
    }
}

-- Debug mode
Config.Debug = false
