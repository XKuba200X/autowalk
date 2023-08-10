ESX = exports["es_extended"]:getSharedObject()

local moving = false
local walkStyles = {
    "move_m@brave",
    "move_m@confident",
    "move_m@shadyped@a",
    "move_m@drunk@verydrunk",
    "move_m@buzzed",
    "move_m@injured"
}

local walkStyleNames = {
    "Normalny",
    "Pewny siebie",
    "Gangster",
    "Pijak",
    "Dziwka",
    "Skręcona kostka"
}

local currentWalkStyle = 1

RegisterKeyMapping('moving_forward', 'Tryb automatycznego chodzenia', 'keyboard', '')
RegisterCommand("moving_forward",function()
    local ped = PlayerPedId()
    if IsControlPressed(0, 32) and not IsPedInAnyVehicle(ped) then
        moving = not moving
        if moving then
            Citizen.CreateThread(function()
                while moving do
                    Wait(0)
                    ESX.ShowHelpNotification("~INPUT_VEH_HEADLIGHT~ aby przerwać tryb ciągłego chodzenia | ~INPUT_CELLPHONE_DOWN~ i ~INPUT_CELLPHONE_UP~ aby zmienić styl chodzenia")
                    if IsControlJustReleased(0, 74) or IsPedInAnyVehicle(ped) then
                        moving = false
                        Wait(300)
                        ClearPedTasksImmediately(ped)
                    end

                    if IsControlJustReleased(0, 173) then -- Arrow Down
                        currentWalkStyle = currentWalkStyle + 1
                        if currentWalkStyle > #walkStyles then
                            currentWalkStyle = 1
                        end
                        SetPlayerWalkStyle(ped, walkStyles[currentWalkStyle], currentWalkStyle)
                    elseif IsControlJustReleased(0, 172) then -- Arrow Up
                        currentWalkStyle = currentWalkStyle - 1
                        if currentWalkStyle < 1 then
                            currentWalkStyle = #walkStyles
                        end
                        SetPlayerWalkStyle(ped, walkStyles[currentWalkStyle], currentWalkStyle)
                    end

                end
            end)
            while moving do
                Wait(250)
                local hit, coords, entity = RayCastGamePlayCamera(25.0)
                local heading = GetEntityHeading(ped)
                TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, heading)
            end
            ClearPedTasksImmediately(ped)
        end
    end
end)

function SetPlayerWalkStyle(ped, anim, index)
    RequestAnimSet(anim)
    while not HasAnimSetLoaded(anim) do
        Citizen.Wait(0)
    end
    SetPedMovementClipset(ped, anim, 0.5)
    ESX.ShowNotification("Wybrano styl chodzenia: " .. walkStyleNames[index])
end

function RotationToDirection(rotation)
    local adjustedRotation = 
    { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = 
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = 
    { 
        x = cameraCoord.x + direction.x * distance, 
        y = cameraCoord.y + direction.y * distance, 
        z = cameraCoord.z + direction.z * distance 
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 1, 0, 0))
    return b, c, e
end
