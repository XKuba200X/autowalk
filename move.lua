ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local moving = false

RegisterKeyMapping('+moving_forward', 'Tryb automatycznego chodzenia', 'keyboard', '')
RegisterCommand("+moving_forward",function()
    local ped = PlayerPedId()
    if IsControlPressed(0, 32) and not IsPedInAnyVehicle(ped) then
        moving = not moving
		if moving then
			Citizen.CreateThread(function()
				while moving do
					Wait(0)
					ESX.ShowHelpNotification("~INPUT_VEH_HEADLIGHT~ aby przerwać tryb ciągłego chodzenia")
					if IsControlJustReleased(0, 74) or IsPedInAnyVehicle(ped) then
						moving = false
						Wait(300)
						ClearPedTasksImmediately(ped)
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
