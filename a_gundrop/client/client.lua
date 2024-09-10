local dropChance = Config.DropChance
local droppableWeapons = Config.DroppableWeapons
local ammoDropChance = Config.AmmoDropChance 


local ammoDroppedWeapons = {}


function isWeaponDroppable(weapon)
    for _, droppableWeapon in ipairs(droppableWeapons) do
        if weapon == GetHashKey(droppableWeapon) then
            return true
        end
    end
    return false
end


function RemoveWeaponAmmo(playerPed, weapon)
    local currentAmmo = GetAmmoInPedWeapon(playerPed, weapon)
    if currentAmmo > 0 then
        SetPedAmmo(playerPed, weapon, 0)
    end
end

-
function attemptDropWeapon(weapon)
    local playerPed = PlayerPedId()
    
    if weapon and weapon ~= GetHashKey("WEAPON_UNARMED") and isWeaponDroppable(weapon) then
        
        local randomChance = math.random()
        local randomAmmoChance = math.random()

        
        if randomChance < dropChance then
            
            SetPedDropsWeapon(playerPed)
            RemoveWeaponFromPed(playerPed, weapon)  
            TriggerEvent('ox_lib:notify', { 
                type = 'error', 
                description = "You dropped your weapon and were disarmed!", 
                icon = 'ban' 
            })
        end

       
        local currentAmmo = GetAmmoInPedWeapon(playerPed, weapon) -- Get the current ammo count in the weapon
        if currentAmmo > 0 and randomAmmoChance < ammoDropChance then
           
            RemoveWeaponAmmo(playerPed, weapon)

            
            ammoDroppedWeapons[weapon] = true

            TriggerEvent('ox_lib:notify', { 
                type = 'error', 
                description = "You accidentally dropped your clip and lost all your ammo!", 
                icon = 'exclamation' 
            })
        end
    end
end

-- Thread to monitor weapon changes and ammo resets
Citizen.CreateThread(function()
    local lastWeapon = nil
    while true do
        Citizen.Wait(500) -- Check every 500ms
        local playerPed = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(playerPed)
        
        
        if currentWeapon ~= lastWeapon then
            lastWeapon = currentWeapon

            if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
                
                if ammoDroppedWeapons[currentWeapon] then
                    SetPedAmmo(playerPed, currentWeapon, 0)
                else
                    attemptDropWeapon(currentWeapon) 
                end
            end
        end
    end
end)
