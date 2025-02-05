local seatbeltOn = false
local seatbeltCallback = function ()
    return seatbeltOn
end

local speedLimitEnabled = false
local speedLimit = 0  -- Speed limit değişkeni

local speedLimitCallback = function () 
    return speedLimit
end

AddEventHandler('gameEventTriggered', function (event, data)
    if event == 'CEventNetworkPlayerEnteredVehicle' then
        local player, vehicle = table.unpack(data)
        if player == PlayerId() then
            local vehicleModel = GetEntityModel(vehicle)
            if not IsThisModelABicycle(vehicleModel) then
                SendNUIMessage({
                    action = 'open'
                })
                CreateThread(function ()
                    local hide = false
                    local maxSpeed = GetVehicleModelEstimatedMaxSpeed(vehicleModel)
                    local maxFuel = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
                    while true do
                        if not hide and IsPauseMenuActive() then
                            SendNUIMessage({
                                action = 'close'
                            })
                            hide = true
                        elseif hide and not IsPauseMenuActive() then
                            SendNUIMessage({
                                action = 'open'
                            })
                            hide = false
                        end
                        local playerPed = PlayerPedId()
                        if not IsPedInAnyVehicle(playerPed) then
                            SendNUIMessage({
                                action = 'close'
                            })
                            return
                        end
                        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                            local tiresAlert = false
                            for _, wheelId in ipairs({0, 1, 2, 3, 4, 5, 45, 47}) do
                                if IsVehicleTyreBurst(vehicle, wheelId) then
                                    tiresAlert = true
                                end
                            end
                            local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                            SendNUIMessage({
                                passenger = false,
                                doors = GetVehicleDoorLockStatus(vehicle),
                                blinkers = GetVehicleIndicatorLights(vehicle),
                                tires = tiresAlert,
                                engine = GetVehicleEngineHealth(vehicle),
                                speed = GetEntitySpeed(vehicle),
                                maxSpeed = maxSpeed,
                                lights = lightsOn,
                                highbeams = highbeamsOn,
                                fuel = GetVehicleFuelLevel(vehicle) * 100 / maxFuel,
                                maxFuel = maxFuel,
                                seatbelt = seatbeltCallback(),
                                speedLimit = speedLimitCallback()
                            })
                        else
                            SendNUIMessage({
                                passenger = true,
                                doors = GetVehicleDoorLockStatus(vehicle),
                                seatbelt = seatbeltCallback()
                            })
                        end
                        Wait(50)
                    end
                end)
            end
        end
    end
end)

function registerSeatbeltFunction(callback)
    seatbeltCallback = callback
end

function registerSpeedLimitFunction(callback)
    speedLimitCallback = callback
end

-- Keybind for toggling seatbelt
RegisterCommand('toggleSeatbelt', function()
    seatbeltOn = not seatbeltOn
    -- Kemer takıldığında yeşil ışık gösterilecek, takılı değilse ışık kapanacak
    if seatbeltOn then
        -- Yeşil ışık gösterilecek
        SendNUIMessage({ action = 'updateSeatbeltLight', color = 'green' })
        TriggerEvent('seatbelt:engaged') -- Kemer takıldı etkinliği
    else
        -- Kemer çıkartıldığında ışık kapanacak
        SendNUIMessage({ action = 'updateSeatbeltLight', color = 'transparent' })
        TriggerEvent('seatbelt:disengaged') -- Kemer çıkartıldı etkinliği
    end
end)

RegisterKeyMapping('toggleSeatbelt', 'Toggle Seatbelt', 'keyboard', 'B') -- "B" tuşu, değiştirebilirsiniz

-- Speed limit toggle
RegisterCommand('toggleSpeedLimit', function()
    speedLimitEnabled = not speedLimitEnabled
    if speedLimitEnabled then
        speedLimit = 60 -- Örnek speed limit, değiştirebilirsiniz
        SendNUIMessage({ action = 'updateSpeedLimitLight', color = 'red' })
        TriggerEvent('speedlimit:activated') -- Speed limit etkinliği
    else
        speedLimit = 0
        SendNUIMessage({ action = 'updateSpeedLimitLight', color = 'transparent' })
        TriggerEvent('speedlimit:deactivated') -- Speed limit devre dışı etkinliği
    end
end)

RegisterKeyMapping('toggleSpeedLimit', 'Toggle Speed Limit', 'keyboard', 'N') -- "N" tuşu, değiştirebilirsiniz
