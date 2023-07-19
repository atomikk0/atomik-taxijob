local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("atomik-maden:kazmaal")
AddEventHandler("atomik-maden:kazmaal", function()
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local amount = 300

    if xPlayer.Functions.RemoveMoney('cash', amount, "Kazma Alış") then
        
        xPlayer.Functions.AddItem("kazma", 1)
    else
        TriggerClientEvent('QBCore:Notify', source, 'Yeterli Paran Yok.', 'error')
    end
end)

RegisterNetEvent("atomik-maden:tokensat")
AddEventHandler("atomik-maden:tokensat", function()
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local token = xPlayer.Functions.GetItemByName("mdntoken")


    if token then
        local amount = token.amount * 10
        xPlayer.Functions.RemoveItem("mdntoken", tokenmiktar.amount)
        Citizen.Wait(500)
        xPlayer.Functions.AddMoney('cash', amount, "Token Satış")
    else
        TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Token Yok', 'error')
    end
end)

RegisterNetEvent("atomik-maden:kaya")
AddEventHandler("atomik-maden:kaya", function()
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer.Functions.AddItem("kaya", 1) then
        -- TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["kaya"], 'add')
        TriggerClientEvent('QBCore:Notify', source, 'Taş Kazdın.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Yer Yok', 'error')
    end
end)

RegisterNetEvent("atomik-maden:kayaerit")
AddEventHandler("atomik-maden:kayaerit", function()
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local kaya = xPlayer.Functions.GetItemByName("kaya")

    if kaya.amount >= 1 then
        if Player.Functions.AddItem("iron", kaya * 6) and Player.Functions.AddItem("plastic", kaya * 6) and Player.Functions.AddItem("steel", kaya * 6) and Player.Functions.AddItem("metalscrap", kaya * 6) and Player.Functions.AddItem("glass", kaya * 6) and Player.Functions.AddItem("rubber", kaya * 6) and Player.Functions.AddItem("copper", kaya * 6) then
            xPlayer.Functions.RemoveItem("kaya", kaya.amount)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Yer Yok', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Kaya Yok', 'error')
    end             
end)

-- RegisterNetEvent("atomik-maden:tokenal")
-- AddEventHandler("atomik-maden:tokenal", function()
--     local xPlayer = QBCore.Functions.GetPlayer(source)
--     local tas = xPlayer.Functions.GetItemByName("tas")

--     if tas.amount >= 1 then
--         if xPlayer.Functions.AddItem("mdntoken", tas.amount * 10) then
--             xPlayer.Functions.RemoveItem("tas", tas.amount)
--         else
--             TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Yer Yok', 'error')
--         end
--     else
--         TriggerClientEvent('QBCore:Notify', source, 'Üzerinde Taş Yok', 'error')
--     end             
-- end)

QBCore.Functions.CreateCallback("atomik-maden:itemkontrol", function(source, cb)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local kazma = xPlayer.Functions.GetItemByName("kazma")

    if kazma.amount >= 1 then
        cb(true)
    else
        cb(false) 
    end
end)