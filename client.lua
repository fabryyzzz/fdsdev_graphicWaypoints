local waypointCoords = nil

local THREADING_WP = {}
function newWaypoint()
    THREADING_WP = true
    Citizen.CreateThread(function()
        while THREADING_WP do
            local WaypointHandle = GetFirstBlipInfoId(8)

            if DoesBlipExist(WaypointHandle) then
                waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                DrawMarker(1, waypointCoords.x,waypointCoords.y,0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, nil, nil, false)
            end
            Citizen.Wait(7)
        end
    end)
end

local function RotationToDirection(rotation)
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

local function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end


RegisterKeyMapping('+waypoint', Config.KeybindTitle, Config.ButtonType, Config.Button)
RegisterCommand('+waypoint', function(source, args)
    local hit, coords, entity = RayCastGamePlayCamera(10000000.0)
    print(coords.x, coords.y)
    if coords.x == 0 and coords.y == 0 then
        THREADING_WP = false
    else
        THREADING_WP = false
        newWaypoint()
        SetNewWaypoint(coords.x, coords.y)
        waypointCoords = vec3(coords.x, coords.y, coords.z)
    end
end)
