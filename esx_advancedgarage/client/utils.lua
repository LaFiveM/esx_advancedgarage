--████╗██╗░░░░░░█████╗░░░░░██╗███████╗██╗██╗░░░██╗███████╗███╗░░░███╗████╗
--██╔═╝██║░░░░░██╔══██╗░░░██╔╝██╔════╝██║██║░░░██║██╔════╝████╗░████║╚═██║
--██║░░██║░░░░░███████║░░██╔╝░█████╗░░██║╚██╗░██╔╝█████╗░░██╔████╔██║░░██║
--██║░░██║░░░░░██╔══██║░██╔╝░░██╔══╝░░██║░╚████╔╝░██╔══╝░░██║╚██╔╝██║░░██║
--████╗███████╗██║░░██║██╔╝░░░██║░░░░░██║░░╚██╔╝░░███████╗██║░╚═╝░██║████║
--╚═══╝╚══════╝╚═╝░░╚═╝╚═╝░░░░╚═╝░░░░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝╚═══╝

--░██████╗░█████╗░██████╗░██╗██████╗░████████╗░██████╗
--██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
--╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░╚█████╗░
--░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░╚═══██╗
--██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░██████╔╝
--╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░╚═════╝░

HandleCamera = function(toggle)



    local Camerapos = this_Garage.Camera

    if not Camerapos then return end

	if not toggle then

		if this_Garage.cam then



			DestroyCam(this_Garage.cam)



		end

		if DoesEntityExist(this_Garage.vehicle) then

			DeleteEntity(this_Garage.vehicle)

		end

		RenderScriptCams(0, 1, 750, 1, 0)

		return

	end

	if this_Garage.cam then



		DestroyCam(this_Garage.cam)



	end

	this_Garage.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(this_Garage.cam, Camerapos["x"], Camerapos["y"], Camerapos["z"])

	SetCamRot(this_Garage.cam, Camerapos["rotationX"], Camerapos["rotationY"], Camerapos["rotationZ"])

	SetCamActive(this_Garage.cam, true)

	RenderScriptCams(1, 1, 750, 1, 1)

    Citizen.Wait(500)

    

end







SetVehicleProperties = function(vehicle, vehicleProps)

    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)

    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)

    SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 1000.0)

    if vehicleProps["windows"] ~= nil and type(vehicleProps["windows"]) == "table" then

        for windowId = 1, 13, 1 do

            if vehicleProps["windows"][windowId] == false and windowId ~= 10 then

                SmashVehicleWindow(vehicle, windowId)

            end

        end

    end



    if vehicleProps["tyres"] ~= nil and type(vehicleProps["tyres"]) == "table" then

        for tyreId = 1, 7, 1 do

            if vehicleProps["tyres"][tyreId] ~= false then

                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)

            end

        end

    end







    if vehicleProps["doors"] ~= nil and type(vehicleProps["doors"]) == "table" then

        for doorId = 0, 5, 1 do

            if vehicleProps["doors"][doorId] ~= false then

                SetVehicleDoorBroken(vehicle, doorId - 1, true)

            end

        end

    end

end







GetVehicleProperties = function(vehicle)

    if DoesEntityExist(vehicle) then

        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}

        vehicleProps["windows"] = {}

        vehicleProps["doors"] = {}

        for id = 1, 7 do

            local tyreId = IsVehicleTyreBurst(vehicle, id, false)     

            if tyreId then

                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId

                if tyreId == false then

                    tyreId = IsVehicleTyreBurst(vehicle, id, true)

                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId

                end

            else

                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false

            end

        end

        for id = 1, 13 do

            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then

                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId

            else

                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true

            end

        end

        for id = 0, 5 do

            local doorId = IsVehicleDoorDamaged(vehicle, id)

            if doorId then

                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId

            else

                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false

            end

        end



        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)

        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)

        vehicleProps["fuelLevel"] = GetVehicleFuelLevel(vehicle)



        return vehicleProps

    end

end







SpawnLocalVehicle = function(vehicleProps)

	local spawnpoint = this_Garage.PreviewCar

	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(this_Garage.vehicle) then

		DeleteEntity(this_Garage.vehicle)

	end



	if not ESX.Game.IsSpawnPointClear(vector3(spawnpoint.x, spawnpoint.y, spawnpoint.z), 3.0) then 

		ESX.ShowNotification("Egy jármü útban van.")

		return

	end



	if not IsModelValid(vehicleProps["model"]) then

		return

	end







	ESX.Game.SpawnLocalVehicle(vehicleProps["model"], vector3(spawnpoint.x, spawnpoint.y, spawnpoint.z), spawnpoint.h, function(yourVehicle)

		this_Garage.vehicle = yourVehicle

		SetVehicleProperties(yourVehicle, vehicleProps)

		SetModelAsNoLongerNeeded(vehicleProps["model"])

	end)

end











WaitForModel = function(model)

    local DrawScreenText = function(text, red, green, blue, alpha)

        SetTextFont(4)

        SetTextScale(0.0, 0.5)

        SetTextColour(red, green, blue, alpha)

        SetTextDropshadow(0, 0, 0, 0, 255)

        SetTextEdge(1, 0, 0, 0, 255)

        SetTextDropShadow()

        SetTextOutline()

        SetTextCentre(true)

        BeginTextCommandDisplayText("STRING")

        AddTextComponentSubstringPlayerName(text)

        EndTextCommandDisplayText(0.5, 0.5)

    end



    if not IsModelValid(model) then

         --ESX.ShowNotification("This model does not exist ingame.")

        return exports['mythic_notify']:DoHudText('error', 'Nincs ilyen autó a szerveren, szólj egy fejlesztőnek!', 3000, { ['background-color'] = '#ff0000', ['color'] = '#ffffff' })

    end



	if not HasModelLoaded(model) then

		RequestModel(model)

	end



	while not HasModelLoaded(model) do

		Citizen.Wait(0)

		DrawScreenText("Betöltés " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)

	end

end







ToggleBlip = function(entity)

    if DoesBlipExist(carBlips[entity]) then

        RemoveBlip(carBlips[entity])

    else

        if DoesEntityExist(entity) then

            carBlips[entity] = AddBlipForEntity(entity)

            SetBlipSprite(carBlips[entity], GetVehicleClass(entity) == 8 and 226 or 523)

            SetBlipScale(carBlips[entity], 1.05)

            SetBlipColour(carBlips[entity], 30)

            BeginTextCommandSetBlipName("STRING")

            AddTextComponentString("Személygépjármü - " .. GetVehicleNumberPlateText(entity))

            EndTextCommandSetBlipName(carBlips[entity])

        end

    end

end