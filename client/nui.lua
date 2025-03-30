-- Function to open the weapons shop menu
function OpenWeaponsShopMenu()
    -- Set NUI focus
    SetNuiFocus(true, true)
    
    -- Send NUI message to open the menu
    SendNUIMessage({
        type = 'openMenu',
        categories = Config.WeaponCategories,
        config = Config.UISettings
    })
end

-- Function to close the weapons shop menu
function CloseWeaponsShopMenu()
    -- Remove NUI focus
    SetNuiFocus(false, false)
    
    -- Send NUI message to close the menu
    SendNUIMessage({
        type = 'closeMenu'
    })
end
