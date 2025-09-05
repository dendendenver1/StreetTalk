local ESX = nil

if Config.UseESX then
    ESX = exports[Config.Framework.ESX.resourceName]:getSharedObject()
end

RegisterServerEvent('npc-interact:giveMoney')
AddEventHandler('npc-interact:giveMoney', function(amount)
    local src = source
    
    if Config.UseESX and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(amount)
        end
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Money Received',
        description = 'You received $' .. amount,
        type = 'success'
    })
end)

RegisterServerEvent('npc-interact:buyDrugs')
AddEventHandler('npc-interact:buyDrugs', function(price)
    local src = source
    
    if Config.UseESX and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if xPlayer.getMoney() >= price then
                xPlayer.removeMoney(price)
                xPlayer.addInventoryItem(Config.Framework.ESX.drugItem, 1)
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Purchase Complete',
                    description = 'You bought some ' .. Config.Framework.ESX.drugItem .. ' for $' .. price,
                    type = 'success'
                })
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Transaction Failed',
                    description = 'You don\'t have enough money',
                    type = 'error'
                })
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Complete',
            description = 'You bought some drugs for $' .. price .. ' (No framework integration)',
            type = 'success'
        })
    end
end)

RegisterServerEvent('npc-interact:alertPolice')
AddEventHandler('npc-interact:alertPolice', function(data)
    local src = source
    
    if Config.UseESX and ESX then
        local xPlayers = ESX.GetPlayers()
        
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer and xPlayer.job.name == 'police' then
                TriggerClientEvent('ox_lib:notify', xPlayers[i], {
                    title = 'Police Alert',
                    description = 'Suspicious activity reported: ' .. data.action .. ' on ' .. data.street,
                    type = 'inform',
                    position = 'top'
                })
            end
        end
    else
        local players = GetPlayers()
        for i = 1, #players do
            TriggerClientEvent('ox_lib:notify', players[i], {
                title = 'Police Alert',
                description = 'Suspicious activity reported: ' .. data.action .. ' on ' .. data.street,
                type = 'inform',
                position = 'top'
            })
        end
    end
end)
