local QBCore = exports['qb-core']:GetCoreObject()


function MadenMenu(data)

    exports['qb-menu']:openMenu({
        {
            header = "Taksi Menüsü",
            isMenuHeader = true, -- Set to true to make a nonclickable title
        },
        {
            header = "Araç Al",
            txt = "Taksi aracınızı alın.",
            params = {
                event = "atomik-taxi:aracal",
                args = {
                    number = 1,
                }
            }
        },
        {
            header = "Depoya Eriş",
            txt = "Taksi deponuza erişin.",
            params = {
                event = "atomik-taxi:depo",
                args = {
                    number = 2,
                }
            }
        },
    })

end

RegisterNetEvent("atomik-taxi:aracal")
AddEventHandler("atomik-taxi:aracal", function()
    local ped = PlayerPedId()
    
    QBCore.Functions.SpawnVehicle(Config.Arac, function(veh)
        SetVehicleNumberPlateText(veh, 'TAKSI')
        SetEntityHeading(veh, 240.50)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, Config.Araccikarma, true)
end)

RegisterNetEvent("atomik-taxi:depo")
AddEventHandler("atomik-taxi:depo", function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "taksi_depo")
    TriggerEvent("inventory:client:SetCurrentStash", "taksi_depo")
end)

RegisterNetEvent("atomik-taxi:arackoy")
AddEventHandler("atomik-taxi:arackoy", function()
    local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    SetEntityAsMissionEntity(currentVehicle, true, true)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    SetEntityCoords(PlayerPedId(), x - 2, y, z)
    DeleteVehicle(currentVehicle)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo.name
end)

Citizen.CreateThread(function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job.name
    while true do
        local sleep = 2000
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        local dst = GetDistanceBetweenCoords(playercoords, Config.Menu.x, Config.Menu.y, Config.Menu.z, true)
        local dst2 = GetDistanceBetweenCoords(playercoords, Config.Menu.x, Config.Menu.y, Config.Menu.z, true)
        if dst2 < 5 and PlayerJob == "taxi" then
            sleep = 2
            DrawMarker(2, Config.Menu.x, Config.Menu.y, Config.Menu.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255, 0, 0, 255, 0, 0, 0, 1, 0, 0, 0)
            if dst2 < 2 then
                DrawText3Ds(Config.Menu.x, Config.Menu.y, Config.Menu.z + 0.5, '[E] Menüyü Aç')
                if IsControlJustReleased(0, 38) then
                    MadenMenu()
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job.name
    while true do
        local sleep = 2000
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        local dst = GetDistanceBetweenCoords(playercoords, Config.Araccikarma.x, Config.Araccikarma.y, Config.Araccikarma.z, true)
        local dst2 = GetDistanceBetweenCoords(playercoords, Config.Araccikarma.x, Config.Araccikarma.y, Config.Araccikarma.z, true)
        if IsPedSittingInAnyVehicle(PlayerPedId()) then 
        if dst2 < 5 and PlayerJob == "taxi" then
            sleep = 2
            DrawMarker(2, Config.Araccikarma.x, Config.Araccikarma.y, Config.Araccikarma.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 255, 0, 0, 0, 1, 0, 0, 0)
            if dst2 < 2 then
                DrawText3Ds(Config.Araccikarma.x, Config.Araccikarma.y, Config.Araccikarma.z + 0.5, '[E] Aracı Koy')
                if IsControlJustReleased(0, 38) then
                    TriggerEvent("atomik-taxi:arackoy")
                end
            end
        end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Menu)

	SetBlipSprite (blip, 198)
	SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.6)
    SetBlipColour (blip, 5)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Taksi Durağı")
	EndTextCommandSetBlipName(blip)
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 250
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 75)
end
