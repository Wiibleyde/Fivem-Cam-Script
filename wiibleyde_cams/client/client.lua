local holdingCam = false
local usingCam = false
local camModel = "prop_v_cam_01"
local camanimDict = "missfinale_c2mcs_1"
local camanimName = "fin_c2_mcs_1_camman"
local cam_net = nil
local UI = { 
	x =  0.000,
	y = -0.001,
}

local helicoCams = {
	"polmav",
	"buzzard",
	"frogger",
	"maverick",
	"conada",
}

RegisterNetEvent("Cam:ToggleCam")
AddEventHandler("Cam:ToggleCam", function()
    if not holdingCam then
        RequestModel(GetHashKey(camModel))
        while not HasModelLoaded(GetHashKey(camModel)) do
            Citizen.Wait(100)
        end
		
        local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local camspawned = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        Citizen.Wait(1000)
        local netid = ObjToNet(camspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(camspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        cam_net = netid
        holdingCam = true
    else
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(cam_net), 1, 1)
        DeleteEntity(NetToObj(cam_net))
        cam_net = nil
        holdingCam = false
        usingCam = false
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if holdingCam then
			while not HasAnimDictLoaded(camanimDict) do
				RequestAnimDict(camanimDict)
				Citizen.Wait(100)
			end

			if not IsEntityPlayingAnim(PlayerPedId(), camanimDict, camanimName, 3) then
				TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0)
				TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			end
				
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0,25,true)
			DisableControlAction(0, 44,  true)
			DisableControlAction(0,37,true)
			SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
		end
	end
end)

local fov_max = 70.0
local fov_min = 3.0
local zoomspeed = 5.0
local speed_lr = 8.0
local speed_ud = 8.0

local camera = false
local fov = (fov_max+fov_min)*0.5

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local lPed = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(lPed)
		if holdingCam then
			newscamera = true
			local cam2 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
			if IsPedInAnyHeli(lPed) then
				SetTimecycleModifier("default")
				SetTimecycleModifierStrength(0.3)
				local lPed = GetPlayerPed(-1)
				AttachCamToEntity(cam2, lPed, 0.0,2.0,-1.5, true)
				SetCamRot(cam2, 2.0,1.0,GetEntityHeading(lPed))
				SetCamFov(cam2, fov)
				RenderScriptCams(true, false, 0, 1, 0)
			else
				SetTimecycleModifier("default")
				SetTimecycleModifierStrength(0.3)
				AttachCamToEntity(cam2, lPed, 0.0,0.0,1.0, true)
				SetCamRot(cam2, 2.0,1.0,GetEntityHeading(lPed))
				SetCamFov(cam2, fov)
				RenderScriptCams(true, false, 0, 1, 0)
			end
			while newscamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) do
				if IsControlJustPressed(1, 177) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					newscamera = false
					TriggerEvent("Cam:ToggleCam")
				end
				SetEntityRotation(lPed, 0, 0, new_z,2, true)
				local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
				CheckInputRotation(cam2, zoomvalue)
				HideHUDThisFrame()
				HandleZoom(cam2)
				local camHeading = GetGameplayCamRelativeHeading()
				local camPitch = GetGameplayCamRelativePitch()
				if camPitch < -70.0 then
					camPitch = -70.0
				elseif camPitch > 42.0 then
					camPitch = 42.0
				end
				camPitch = (camPitch + 70.0) / 112.0
				if camHeading < -180.0 then
					camHeading = -180.0
				elseif camHeading > 180.0 then
					camHeading = 180.0
				end
				camHeading = (camHeading + 180.0) / 360.0
				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Pitch", camPitch)
				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Heading", camHeading * -1.0 + 1.0)
				Citizen.Wait(1)
			end
			newscamera = false
			ClearTimecycleModifier()
			fov = (fov_max+fov_min)*0.5
			RenderScriptCams(false, false, 0, 1, 0)
			DestroyCam(cam2, false)
			SetNightvision(false)
			SetSeethrough(false)
		end
	end
end)

RegisterNetEvent('camera:Activate')
AddEventHandler('camera:Activate', function()
	camera = not camera
end)

function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1)
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(3)
	HideHudComponentThisFrame(4)
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13)
	HideHudComponentThisFrame(11)
	HideHudComponentThisFrame(12)
	HideHudComponentThisFrame(15)
	HideHudComponentThisFrame(18)
	HideHudComponentThisFrame(19)
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local lPed = GetPlayerPed(-1)
	if not ( IsPedSittingInAnyVehicle( lPed ) ) then
		if IsControlJustPressed(0,241) or IsControlJustPressed(0,172) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) or IsControlJustPressed(0,299) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else	
		if IsControlJustPressed(0,241) or IsControlJustPressed(0,172) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) or IsControlJustPressed(0,299) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	end
end

function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end
