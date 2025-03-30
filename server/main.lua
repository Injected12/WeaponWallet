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
    -- Allow any player to use this command (removed permission check)
    if #args < 2 then
        if source == 0 then
            print('Usage: /weapons_add_user [username] [password] [name]')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Usage: /weapons_add_user [username] [password] [name]', 'info')
        end
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
        if source == 0 then
            print('User ' .. username .. ' added successfully.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' added successfully.', 'success')
        end
    else
        if source == 0 then
            print('User ' .. username .. ' already exists.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' already exists.', 'error')
        end
    end
end, false)

RegisterCommand('weapons_add_weapon', function(source, args, rawCommand)
    -- Allow any player to use this command
    if #args < 3 then
        if source == 0 then
            print('Usage: /weapons_add_weapon [username] [weapon] [price]')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Usage: /weapons_add_weapon [username] [weapon] [price]', 'info')
        end
        return
    end
    
    local username = args[1]
    local weapon = 'WEAPON_' .. string.upper(args[2])
    local price = tonumber(args[3])
    
    -- Check if user exists
    if Config.Users[username] then
        -- Add weapon to user
        Config.Users[username].weapons[weapon] = price
        if source == 0 then
            print('Weapon ' .. weapon .. ' added to user ' .. username .. ' for $' .. price)
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Weapon ' .. weapon .. ' added to user ' .. username .. ' for $' .. price, 'success')
        end
    else
        if source == 0 then
            print('User ' .. username .. ' does not exist.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' does not exist.', 'error')
        end
    end
end, false)

RegisterCommand('weapons_remove_weapon', function(source, args, rawCommand)
    -- Allow any player to use this command
    if #args < 2 then
        if source == 0 then
            print('Usage: /weapons_remove_weapon [username] [weapon]')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Usage: /weapons_remove_weapon [username] [weapon]', 'info')
        end
        return
    end
    
    local username = args[1]
    local weapon = 'WEAPON_' .. string.upper(args[2])
    
    -- Check if user exists
    if Config.Users[username] then
        -- Remove weapon from user
        if Config.Users[username].weapons[weapon] then
            Config.Users[username].weapons[weapon] = nil
            if source == 0 then
                print('Weapon ' .. weapon .. ' removed from user ' .. username)
            else
                TriggerClientEvent('weapons_shop:showNotification', source, 'Weapon ' .. weapon .. ' removed from user ' .. username, 'success')
            end
        else
            if source == 0 then
                print('User ' .. username .. ' does not have weapon ' .. weapon)
            else
                TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' does not have weapon ' .. weapon, 'error')
            end
        end
    else
        if source == 0 then
            print('User ' .. username .. ' does not exist.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' does not exist.', 'error')
        end
    end
end, false)

RegisterCommand('weapons_remove_user', function(source, args, rawCommand)
    -- Allow any player to use this command
    if #args < 1 then
        if source == 0 then
            print('Usage: /weapons_remove_user [username]')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Usage: /weapons_remove_user [username]', 'info')
        end
        return
    end
    
    local username = args[1]
    
    -- Remove user from config
    if Config.Users[username] then
        Config.Users[username] = nil
        if source == 0 then
            print('User ' .. username .. ' removed successfully.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' removed successfully.', 'success')
        end
    else
        if source == 0 then
            print('User ' .. username .. ' does not exist.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' does not exist.', 'error')
        end
    end
end, false)

RegisterCommand('weapons_list_users', function(source, args, rawCommand)
    -- Allow any player to use this command
    local userList = '=== Weapons Shop Users ===\n'
    for username, userData in pairs(Config.Users) do
        userList = userList .. '- ' .. username .. ' (' .. userData.name .. ')\n'
    end
    
    if source == 0 then
        print(userList)
    else
        TriggerClientEvent('weapons_shop:showNotification', source, userList, 'info')
    end
end, false)

RegisterCommand('weapons_list_weapons', function(source, args, rawCommand)
    -- Allow any player to use this command
    if #args < 1 then
        if source == 0 then
            print('Usage: /weapons_list_weapons [username]')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'Usage: /weapons_list_weapons [username]', 'info')
        end
        return
    end
    
    local username = args[1]
    
    -- Check if user exists
    if Config.Users[username] then
        local weaponList = '=== Weapons for ' .. username .. ' ===\n'
        for weapon, price in pairs(Config.Users[username].weapons) do
            weaponList = weaponList .. '- ' .. weapon .. ' ($' .. price .. ')\n'
        end
        
        if source == 0 then
            print(weaponList)
        else
            TriggerClientEvent('weapons_shop:showNotification', source, weaponList, 'info')
        end
    else
        if source == 0 then
            print('User ' .. username .. ' does not exist.')
        else
            TriggerClientEvent('weapons_shop:showNotification', source, 'User ' .. username .. ' does not exist.', 'error')
        end
    end
end, false)
