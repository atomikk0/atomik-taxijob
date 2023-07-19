local QBCore = exports['qb-core']:GetCoreObject()
local coreLoaded = false
Citizen.CreateThread(function()
    while QBCore == nil do
        Citizen.Wait(200)
    end
    coreLoaded = true
end)

local playerPed = PlayerPedId()
local inVeh = IsPedInAnyVehicle(playerPed)
local playerCoords = GetEntityCoords(playerPed)
local playerVehicle = 0
local inTaxi = false


RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo.name
end)

Citizen.CreateThread(function()
    while true do
        if coreLoaded then
            playerPed = PlayerPedId()
            inVeh = IsPedInAnyVehicle(playerPed)
            playerCoords = GetEntityCoords(playerPed)
            if inVeh then
                playerVehicle = GetVehiclePedIsIn(playerPed)
				inDriveSeat = GetPedInVehicleSeat(playerVehicle, -1) == playerPed
				inTaxi = GetEntityModel(playerVehicle) == -956048545
				if not inTaxi then
					Citizen.Wait(15000)
				end
            else
				playerVehicle, inDriveSeat, inTaxi = 0, false, false
			end
        end
        Citizen.Wait(5000)
    end
end)

-- Settings
local enableTaxiGui = true -- Enables the GUI (Default: true)
local fareCost = 1.66 --(1.66 = $100 per minute) Cost per second
local costPerMile = 100.0
local initialFare = 50.0 -- the cost to start a fare

DecorRegister("fares", 1)
DecorRegister("miles", 1)
DecorRegister("meteractive", 2)
DecorRegister("initialFare", 1)
DecorRegister("costPerMile", 1)
DecorRegister("fareCost", 1)

-- NUI Variables
local meterOpen = false
local meterActive = false

-- Open Gui and Focus NUI
function openGui()
  	SendNUIMessage({openMeter = true})
end

-- Close Gui and disable NUI
function closeGui()
	SendNUIMessage({openMeter = false})
	meterOpen = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if inVeh then
			if inTaxi and not inDriveSeat then
				TriggerEvent('taxi:updatefare', playerVehicle)
				openGui()
				meterOpen = true
			end
			if meterActive and inDriveSeat then
				local _fare = DecorGetFloat(playerVehicle, "fares")
				local _miles = DecorGetFloat(playerVehicle, "miles")
				local _fareCost = DecorGetFloat(playerVehicle, "fareCost")

				if _fareCost ~= 0 then
					DecorSetFloat(playerVehicle, "fares", _fare + _fareCost)
				else
					DecorSetFloat(playerVehicle, "fares", _fare + fareCost)
				end
				DecorSetFloat(playerVehicle, "miles", _miles + round(GetEntitySpeed(playerVehicle) * 0.000621371, 5))
				TriggerEvent('taxi:updatefare', playerVehicle)
			end

			if inTaxi and not inDriveSeat then
				TriggerEvent('taxi:updatefare', playerVehicle)
			end
		end
	end
end)

-- If GUI setting turned on, listen for INPUT_PICKUP keypress
Citizen.CreateThread(function()
	local PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job.name
	while true do
		local time = 1000
		if inTaxi then
			time = 1
			if not inTaxi then
				QBCore.Functions.Notify("Taksimetreyi açmak için F6 tuşuna bas")
			end

			inTaxi = true
			if inDriveSeat then
				if IsControlJustReleased(0, 167) and PlayerJob == "taxi" then -- HOME
					TriggerEvent('taxi:toggleDisplay')
					Citizen.Wait(100)
				end
				if IsControlJustReleased(0, 29) and PlayerJob == "taxi"  then -- B
					TriggerEvent('taxi:toggleHire')
					Citizen.Wait(100)
				end
				if IsControlJustReleased(0,7) and PlayerJob == "taxi" then -- L
					TriggerEvent('taxi:resetMeter')
					Citizen.Wait(100)
				end
			end
		else
			if(meterOpen) then
				closeGui()
			end
			meterOpen = false
		end

		Citizen.Wait(time)
	end
end)

function round(num, numDecimalPlaces)
	local mult = 5^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
	closeGui()
	cb('ok')
end)

RegisterNetEvent('taxi:toggleDisplay')
AddEventHandler('taxi:toggleDisplay', function()
	if(inTaxi and inDriveSeat) then
		if meterOpen then
			closeGui()
			meterOpen = false
		else
			local _fare = DecorGetFloat(playerVehicle, "fares")
			if _fare < initialFare then
				DecorSetFloat(playerVehicle, "fares", initialFare)
			end
			TriggerEvent('taxi:updatefare', playerVehicle)
			openGui()
			meterOpen = true
		end
	end
end)

RegisterNetEvent('taxi:toggleHire')
AddEventHandler('taxi:toggleHire', function()
	if(inTaxi and inDriveSeat) then
		if meterActive then
			SendNUIMessage({meterActive = false})
			meterActive = false
			DecorSetBool(playerVehicle, "meteractive", false)
			Citizen.Trace("Trigger OFF")
		else
			SendNUIMessage({meterActive = true})
			meterActive = true
			DecorSetBool(playerVehicle, "meteractive", true)
			Citizen.Trace("Trigger ON")
		end
	end
end)

RegisterNetEvent('taxi:resetMeter')
AddEventHandler('taxi:resetMeter', function()
	if(inTaxi and inDriveSeat) then
		local _fare = DecorGetFloat(playerVehicle, "fares")
		local _miles = DecorGetFloat(playerVehicle, "miles")
		DecorSetFloat(playerVehicle, "initialFare", initialFare)
		DecorSetFloat(playerVehicle, "costPerMile", costPerMile)
		DecorSetFloat(playerVehicle, "fareCost", fareCost)
		DecorSetFloat(playerVehicle, "fares", DecorGetFloat(playerVehicle, "initialFare"))
		DecorSetFloat(playerVehicle, "miles", 0.0)
		TriggerEvent('taxi:updatefare', playerVehicle)
	end
end)

-- Send NUI message to update
RegisterNetEvent('taxi:updatefare')
AddEventHandler('taxi:updatefare', function(veh)
	local id = PlayerId()
	local playerName = GetPlayerName(id)
	local _fare = DecorGetFloat(veh, "fares")
	local _miles = DecorGetFloat(veh, "miles")
	local farecost = _fare + (_miles * DecorGetFloat(veh, "costPerMile"))
	SendNUIMessage({
		updateBalance = true,
		balance = string.format("%.2f", farecost),
		player = string.format("%.2f", _miles),
		meterActive = DecorGetBool(veh, "meteractive")
	})
end)

RegisterNetEvent('vRP_taxi:user_settings')
AddEventHandler('vRP_taxi:user_settings', function(action, value)
  if action ~= nil and inTaxi then
	if inDriveSeat then
	  if action == "show" then
		msg = "<b>Current meter values</b></b><br /><b>Initial</b> = $"..initialFare.."<br /><b>Fare per mile</b> = $"..costPerMile.."<br /><b>Fare per minute</b> = $"..fareCost*60
	  elseif action == "initial" then
		initialFare = value*1.0
		DecorSetFloat(playerVehicle, "fares", initialFare)
		TriggerEvent('taxi:updatefare', playerVehicle)
		msg = "<b>Initial fare set to </b>$"..value
		DecorSetFloat(playerVehicle, "initialFare", value*1.0)
	  elseif action == "mile" then
		costPerMile = value
		msg = "<b>Fare per mile set to </b>$"..value
		DecorSetFloat(playerVehicle, "costPerMile", value)
	  elseif action == "minute" then
		fareCost = value/60
		msg = "<b>Fare per minute set to </b>$"..value
		DecorSetFloat(playerVehicle, "fareCost", value/60)
	  end
	  if msg ~= nil then
		TriggerEvent("pNotify:SendNotification", {text = msg , type = "success", layout = "centerLeft", queue = "global", theme = "gta", timeout = 5000})
	  end
	end
  end
end)