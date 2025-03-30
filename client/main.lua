local isNearShop = false
local currentDelivery = nil
local deliveryBlip = nil
local deliveryNPC = nil
local loggedIn = false
local currentUser = nil

-- Function to check if player is near the shop
function IsPlayerNearShop()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - Config.ShopLocation)
    
    return distance <= Config.InteractionDistance
end

-- Function to create shop blip
function CreateShopBlip()
    local blip = AddBlipForCoord(Config.ShopLocation)
    SetBlipSprite(blip, Config.ShopBlip.Sprite)
    SetBlipColour(blip, Config.ShopBlip.Color)
    SetBlipDisplay(blip, Config.ShopBlip.Display)
    SetBlipScale(blip, Config.ShopBlip.Scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.ShopBlip.Name)
    EndTextCommandSetBlipName(blip)
end

-- Function to draw 3D text
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Function to create a random delivery point
function CreateDeliveryPoint()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local angle = math.random() * 2 * math.pi
    local distance = math.random(Config.DeliveryDistance.min, Config.DeliveryDistance.max)
    
    local x = playerCoords.x + math.cos(angle) * distance
    local y = playerCoords.y + math.sin(angle) * distance
    local z = playerCoords.z
    
    -- Find ground Z coordinate
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if ground then
        z = groundZ
    end
    
    local coords = vector3(x, y, z)
    
    -- Create blip
    if deliveryBlip ~= nil then
        RemoveBlip(deliveryBlip)
    end
    
    deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(deliveryBlip, 501) -- Crate blip
    SetBlipColour(deliveryBlip, 5) -- Yellow
    SetBlipDisplay(deliveryBlip, 4)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Weapon Delivery")
    EndTextCommandSetBlipName(deliveryBlip)
    
    SetBlipRoute(deliveryBlip, true)
    
    currentDelivery = {
        coords = coords,
        weapon = currentDelivery.weapon,
        timeout = GetGameTimer() + (Config.DeliveryTimeout * 1000)
    }
    
    -- Start timer for NPC spawn
    Citizen.CreateThread(function()
        Citizen.Wait(Config.DeliveryWaitTime * 1000)
        if currentDelivery ~= nil then
            SpawnDeliveryNPC()
        end
    end)
    
    -- Start timeout check
    Citizen.CreateThread(function()
        while currentDelivery ~= nil do
            Citizen.Wait(1000)
            if GetGameTimer() > currentDelivery.timeout then
                TriggerEvent('weapons_shop:showNotification', 'Your delivery has timed out.', 'error')
                CancelDelivery()
                break
            end
        end
    end)
    
    return coords
end

-- Function to spawn delivery NPC
function SpawnDeliveryNPC()
    if currentDelivery == nil then return end
    
    -- Request model
    local model = GetHashKey(Config.DeliveryNPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end
    
    -- Create NPC
    deliveryNPC = CreatePed(4, model, currentDelivery.coords.x, currentDelivery.coords.y, currentDelivery.coords.z, 0.0, false, true)
    SetEntityAsMissionEntity(deliveryNPC, true, true)
    SetBlockingOfNonTemporaryEvents(deliveryNPC, true)
    SetPedCanBeTargetted(deliveryNPC, false)
    SetPedCanRagdoll(deliveryNPC, false)
    FreezeEntityPosition(deliveryNPC, true)
    
    -- Set NPC scenario
    TaskStartScenarioInPlace(deliveryNPC, Config.DeliveryNPC.scenario, 0, true)
    
    -- Notify player
    TriggerEvent('weapons_shop:showNotification', 'Your contact has arrived at the delivery point.', 'success')
end

-- Function to complete delivery
function CompleteDelivery()
    if currentDelivery == nil or deliveryNPC == nil then return end
    
    -- Give weapon to player
    GiveWeaponToPed(PlayerPedId(), GetHashKey(currentDelivery.weapon), 100, false, true)
    
    -- Notify player
    TriggerEvent('weapons_shop:showNotification', 'You have received your weapon.', 'success')
    
    -- Clean up
    CancelDelivery()
end

-- Function to cancel delivery
function CancelDelivery()
    if deliveryBlip ~= nil then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    if deliveryNPC ~= nil then
        DeleteEntity(deliveryNPC)
        deliveryNPC = nil
    end
    
    currentDelivery = nil
end

-- Function to purchase weapon
function PurchaseWeapon(weapon, price)
    TriggerServerEvent('weapons_shop:purchaseWeapon', weapon, price)
end

-- Initialize resource
Citizen.CreateThread(function()
    -- Create shop blip
    CreateShopBlip()
    
    -- Main loop
    while true do
        Citizen.Wait(0)
        
        -- Check if player is near shop
        isNearShop = IsPlayerNearShop()
        
        -- Display interaction prompt if near shop
        if isNearShop then
            Draw3DText(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z + 1.0, Config.InteractionText)
            
            -- Handle interaction
            if IsControlJustPressed(0, Config.InteractionKey) then
                OpenWeaponsShopMenu()
            end
        end
        
        -- Handle delivery NPC interaction
        if currentDelivery ~= nil and deliveryNPC ~= nil then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local npcCoords = GetEntityCoords(deliveryNPC)
            local distance = #(playerCoords - npcCoords)
            
            if distance <= 3.0 then
                Draw3DText(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "Press ~INPUT_CONTEXT~ to collect your weapon")
                
                if IsControlJustPressed(0, Config.InteractionKey) then
                    CompleteDelivery()
                end
            end
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('login', function(data, cb)
    TriggerServerEvent('weapons_shop:loginAttempt', data.username, data.password)
    cb('ok')
end)

RegisterNUICallback('purchaseWeapon', function(data, cb)
    if not loggedIn then
        cb({success = false, message = 'You are not logged in.'})
        return
    end
    
    PurchaseWeapon(data.weapon, data.price)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    CloseWeaponsShopMenu()
    cb('ok')
end)

RegisterNUICallback('logout', function(data, cb)
    loggedIn = false
    currentUser = nil
    TriggerEvent('weapons_shop:showNotification', 'You have been logged out.', 'info')
    cb('ok')
end)

-- Event handlers
RegisterNetEvent('weapons_shop:loginResult')
AddEventHandler('weapons_shop:loginResult', function(success, username, userData)
    if success then
        loggedIn = true
        currentUser = username
        SendNUIMessage({
            type = 'loginSuccess',
            username = username,
            name = userData.name,
            weapons = userData.weapons
        })
        TriggerEvent('weapons_shop:showNotification', 'Welcome back, ' .. userData.name, 'success')
    else
        SendNUIMessage({
            type = 'loginFailure'
        })
        TriggerEvent('weapons_shop:showNotification', 'Login failed. Invalid credentials.', 'error')
    end
end)

RegisterNetEvent('weapons_shop:purchaseResult')
AddEventHandler('weapons_shop:purchaseResult', function(success, weapon, message)
    if success then
        SendNUIMessage({
            type = 'purchaseSuccess',
            weapon = weapon
        })
        TriggerEvent('weapons_shop:showNotification', message, 'success')
        
        -- Create delivery
        currentDelivery = {
            weapon = weapon
        }
        local deliveryCoords = CreateDeliveryPoint()
        
        TriggerEvent('weapons_shop:showNotification', 'A delivery point has been marked on your map.', 'info')
        
        CloseWeaponsShopMenu()
    else
        SendNUIMessage({
            type = 'purchaseFailure',
            message = message
        })
        TriggerEvent('weapons_shop:showNotification', message, 'error')
    end
end)

RegisterNetEvent('weapons_shop:showNotification')
AddEventHandler('weapons_shop:showNotification', function(message, type)
    SendNUIMessage({
        type = 'notification',
        message = message,
        notificationType = type
    })
    
    -- Also show as a game notification
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end)
