-- Variables
local pendingDeliveries = {}

-- Function to check if player has enough money
function HasEnoughMoney(source, amount)
    -- This function should be adapted to your economy system
    -- For vanilla FiveM, we'll use the default GetPlayerMoney function
    local money = GetPlayerMoney(source)
    return money >= amount
end

-- Function to remove money from player
function RemoveMoney(source, amount)
    -- This function should be adapted to your economy system
    -- For vanilla FiveM, we'll use the default RemovePlayerMoney function
    if HasEnoughMoney(source, amount) then
        RemovePlayerMoney(source, amount)
        return true
    end
    return false
end

-- Event handlers
RegisterNetEvent('weapons_shop:loginAttempt')
AddEventHandler('weapons_shop:loginAttempt', function(username, password)
    local source = source
    
    -- Check if username exists
    if Config.Users[username] then
        -- Check if password matches
        if Config.Users[username].password == password then
            -- Successful login
            TriggerClientEvent('weapons_shop:loginResult', source, true, username, {
                name = Config.Users[username].name,
                weapons = Config.Users[username].weapons
            })
            
            if Config.Debug then
                print('Login success: ' .. username)
            end
        else
            -- Incorrect password
            TriggerClientEvent('weapons_shop:loginResult', source, false)
            
            if Config.Debug then
                print('Login failed (wrong password): ' .. username)
            end
        end
    else
        -- Username doesn't exist
        TriggerClientEvent('weapons_shop:loginResult', source, false)
        
        if Config.Debug then
            print('Login failed (user not found): ' .. username)
        end
    end
end)

RegisterNetEvent('weapons_shop:purchaseWeapon')
AddEventHandler('weapons_shop:purchaseWeapon', function(weapon, price)
    local source = source
    
    -- Check if player has enough money
    if HasEnoughMoney(source, price) then
        -- Remove money
        if RemoveMoney(source, price) then
            -- Successful purchase
            TriggerClientEvent('weapons_shop:purchaseResult', source, true, weapon, 'You have purchased a weapon for $' .. price)
            
            if Config.Debug then
                print('Purchase success: ' .. weapon .. ' for $' .. price)
            end
        else
            -- Failed to remove money
            TriggerClientEvent('weapons_shop:purchaseResult', source, false, nil, 'Failed to process payment.')
            
            if Config.Debug then
                print('Purchase failed (payment error): ' .. weapon)
            end
        end
    else
        -- Not enough money
        TriggerClientEvent('weapons_shop:purchaseResult', source, false, nil, 'You do not have enough money.')
        
        if Config.Debug then
            print('Purchase failed (insufficient funds): ' .. weapon)
        end
    end
end)

-- Admin commands for managing users
RegisterCommand('weapons_add_user', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        if #args < 2 then
            print('Usage: /weapons_add_user [username] [password] [name]')
            return
        end
        
        local username = args[1]
        local password = args[2]
        local name = args[3] or username
        
        -- Add user to config
        if not Config.Users[username] then
            Config.Users[username] = {
                password = password,
                name = name,
                weapons = {}
            }
            print('User ' .. username .. ' added successfully.')
        else
            print('User ' .. username .. ' already exists.')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)

RegisterCommand('weapons_add_weapon', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        if #args < 3 then
            print('Usage: /weapons_add_weapon [username] [weapon] [price]')
            return
        end
        
        local username = args[1]
        local weapon = 'WEAPON_' .. string.upper(args[2])
        local price = tonumber(args[3])
        
        -- Check if user exists
        if Config.Users[username] then
            -- Add weapon to user
            Config.Users[username].weapons[weapon] = price
            print('Weapon ' .. weapon .. ' added to user ' .. username .. ' for $' .. price)
        else
            print('User ' .. username .. ' does not exist.')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)

RegisterCommand('weapons_remove_weapon', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        if #args < 2 then
            print('Usage: /weapons_remove_weapon [username] [weapon]')
            return
        end
        
        local username = args[1]
        local weapon = 'WEAPON_' .. string.upper(args[2])
        
        -- Check if user exists
        if Config.Users[username] then
            -- Remove weapon from user
            if Config.Users[username].weapons[weapon] then
                Config.Users[username].weapons[weapon] = nil
                print('Weapon ' .. weapon .. ' removed from user ' .. username)
            else
                print('User ' .. username .. ' does not have weapon ' .. weapon)
            end
        else
            print('User ' .. username .. ' does not exist.')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)

RegisterCommand('weapons_remove_user', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        if #args < 1 then
            print('Usage: /weapons_remove_user [username]')
            return
        end
        
        local username = args[1]
        
        -- Remove user from config
        if Config.Users[username] then
            Config.Users[username] = nil
            print('User ' .. username .. ' removed successfully.')
        else
            print('User ' .. username .. ' does not exist.')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)

RegisterCommand('weapons_list_users', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        print('=== Weapons Shop Users ===')
        for username, userData in pairs(Config.Users) do
            print('- ' .. username .. ' (' .. userData.name .. ')')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)

RegisterCommand('weapons_list_weapons', function(source, args, rawCommand)
    -- Check if source is console or has admin permissions
    if source == 0 or IsPlayerAceAllowed(source, 'command.weapons_admin') then
        if #args < 1 then
            print('Usage: /weapons_list_weapons [username]')
            return
        end
        
        local username = args[1]
        
        -- Check if user exists
        if Config.Users[username] then
            print('=== Weapons for ' .. username .. ' ===')
            for weapon, price in pairs(Config.Users[username].weapons) do
                print('- ' .. weapon .. ' ($' .. price .. ')')
            end
        else
            print('User ' .. username .. ' does not exist.')
        end
    else
        TriggerClientEvent('weapons_shop:showNotification', source, 'You do not have permission to use this command.', 'error')
    end
end, true)
