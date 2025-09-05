local lib = exports.ox_lib
local interactionCooldowns = {}
local nearbyNPCs = {}

local function getNearbyNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for ped in EnumeratePeds() do
        if ped ~= playerPed and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
            local npcCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - npcCoords)
            
            if distance <= Config.Interactions.maxDistance then
                return ped, distance
            end
        end
    end
    return nil, nil
end

local function EnumeratePeds()
    return coroutine.wrap(function()
        local iter, id = FindFirstPed()
        if not id or id == 0 then
            EndFindPed(iter)
            return
        end
        
        local enum = {handle = iter, destructor = EndFindPed}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
            coroutine.yield(id)
            next, id = FindNextPed(iter)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        EndFindPed(iter)
    end)
end

entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
    end
}

local function canInteract(npcId)
    local currentTime = GetGameTimer()
    local cooldownTime = interactionCooldowns[npcId]
    
    if not cooldownTime then
        return true
    end
    
    return (currentTime - cooldownTime) > Config.Interactions.cooldownTime
end

local function setCooldown(npcId)
    interactionCooldowns[npcId] = GetGameTimer()
end

local function alertPolice(action)
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent('npc-interact:alertPolice', {
        action = action,
        coords = playerCoords,
        street = GetStreetNameFromHashKey(GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z))
    })
end

local function handleDirections()
    local outcomes = {
        {chance = Config.Interactions.outcomes.directions.helpful, result = function()
            local street = Config.Streets[math.random(#Config.Streets)]
            lib:notify({
                title = 'NPC Response',
                description = 'Head down ' .. street .. ', you can\'t miss it.',
                type = 'inform'
            })
        end},
        {chance = Config.Interactions.outcomes.directions.unhelpful, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Sorry, I\'m not from around here.',
                type = 'inform'
            })
        end},
        {chance = Config.Interactions.outcomes.directions.rude, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Get lost, I don\'t have time for this.',
                type = 'error'
            })
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function handleSmallTalk()
    lib:notify({
        title = 'NPC Response',
        description = Config.Responses.smallTalk[math.random(#Config.Responses.smallTalk)],
        type = 'inform'
    })
end

local function handleBegMoney()
    local outcomes = {
        {chance = Config.Interactions.outcomes.begging.success, result = function()
            local amount = math.random(Config.Interactions.outcomes.begging.minAmount, Config.Interactions.outcomes.begging.maxAmount)
            TriggerServerEvent('npc-interact:giveMoney', amount)
            lib:notify({
                title = 'NPC Response',
                description = 'Here, take this. Hope it helps.',
                type = 'success'
            })
        end},
        {chance = Config.Interactions.outcomes.begging.refuse, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Sorry, I don\'t have any spare change.',
                type = 'inform'
            })
        end},
        {chance = Config.Interactions.outcomes.begging.callPolice, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'I\'m calling the police! This is harassment!',
                type = 'error'
            })
            alertPolice('Begging')
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function handleThreaten()
    local outcomes = {
        {chance = Config.Interactions.outcomes.threatening.success, result = function()
            local amount = math.random(Config.Interactions.outcomes.threatening.minAmount, Config.Interactions.outcomes.threatening.maxAmount)
            TriggerServerEvent('npc-interact:giveMoney', amount)
            lib:notify({
                title = 'NPC Response',
                description = 'Please don\'t hurt me! Take this!',
                type = 'success'
            })
        end},
        {chance = Config.Interactions.outcomes.threatening.flee, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'The NPC runs away in fear!',
                type = 'inform'
            })
            local npc, _ = getNearbyNPC()
            if npc then
                TaskSmartFleePed(npc, PlayerPedId(), 100.0, -1, false, false)
            end
        end},
        {chance = Config.Interactions.outcomes.threatening.callPolice, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Help! Police! This person is threatening me!',
                type = 'error'
            })
            alertPolice('Threatening')
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function handleBuyDrugs()
    local outcomes = {
        {chance = Config.Interactions.outcomes.buyDrugs.success, result = function()
            local price = math.random(Config.Interactions.outcomes.buyDrugs.minPrice, Config.Interactions.outcomes.buyDrugs.maxPrice)
            TriggerServerEvent('npc-interact:buyDrugs', price)
            lib:notify({
                title = 'NPC Response',
                description = 'Meet me around the corner in 5 minutes.',
                type = 'success'
            })
        end},
        {chance = Config.Interactions.outcomes.buyDrugs.refuse, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'I don\'t know what you\'re talking about.',
                type = 'inform'
            })
        end},
        {chance = Config.Interactions.outcomes.buyDrugs.callPolice, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'You\'re crazy! I\'m calling the cops!',
                type = 'error'
            })
            alertPolice('Drug Solicitation')
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function handleSellJunk()
    local outcomes = {
        {chance = Config.Interactions.outcomes.sellJunk.success, result = function()
            local amount = math.random(Config.Interactions.outcomes.sellJunk.minAmount, Config.Interactions.outcomes.sellJunk.maxAmount)
            TriggerServerEvent('npc-interact:giveMoney', amount)
            lib:notify({
                title = 'NPC Response',
                description = 'I guess I could use this. Here\'s some cash.',
                type = 'success'
            })
        end},
        {chance = Config.Interactions.outcomes.sellJunk.refuse, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'I don\'t need any of that junk.',
                type = 'inform'
            })
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function handleFlirt()
    local outcomes = {
        {chance = Config.Interactions.outcomes.flirt.positive, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Well aren\'t you charming!',
                type = 'success'
            })
        end},
        {chance = Config.Interactions.outcomes.flirt.neutral, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Thanks, but I\'m not interested.',
                type = 'inform'
            })
        end},
        {chance = Config.Interactions.outcomes.flirt.negative, result = function()
            lib:notify({
                title = 'NPC Response',
                description = 'Ew, get away from me creep!',
                type = 'error'
            })
        end}
    }
    
    local roll = math.random(100)
    local cumulative = 0
    
    for _, outcome in ipairs(outcomes) do
        cumulative = cumulative + outcome.chance
        if roll <= cumulative then
            outcome.result()
            break
        end
    end
end

local function openInteractionMenu(npcId)
    if not canInteract(npcId) then
        lib:notify({
            title = 'Interaction',
            description = 'This person doesn\'t want to talk right now.',
            type = 'error'
        })
        return
    end
    
    lib:registerContext({
        id = 'npc_interaction',
        title = 'Talk to Citizen',
        options = {
            {
                title = 'Ask for Directions',
                description = 'Ask where something is located',
                icon = 'map-marker-alt',
                onSelect = function()
                    handleDirections()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Small Talk',
                description = 'Have a casual conversation',
                icon = 'comments',
                onSelect = function()
                    handleSmallTalk()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Beg for Money',
                description = 'Ask for spare change',
                icon = 'hand-holding-usd',
                onSelect = function()
                    handleBegMoney()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Threaten',
                description = 'Intimidate them for money',
                icon = 'fist-raised',
                onSelect = function()
                    handleThreaten()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Buy Drugs',
                description = 'Ask about illegal substances',
                icon = 'pills',
                onSelect = function()
                    handleBuyDrugs()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Sell Junk',
                description = 'Try to sell random items',
                icon = 'shopping-bag',
                onSelect = function()
                    handleSellJunk()
                    setCooldown(npcId)
                end
            },
            {
                title = 'Flirt',
                description = 'Try to charm them',
                icon = 'heart',
                onSelect = function()
                    handleFlirt()
                    setCooldown(npcId)
                end
            }
        }
    })
    
    lib:showContext('npc_interaction')
end

CreateThread(function()
    while true do
        local npc, distance = getNearbyNPC()
        
        if npc and distance then
            lib:showTextUI('[E] Talk to Citizen', {
                position = "top-center",
                icon = 'fa-solid fa-user'
            })
            
            if IsControlJustReleased(0, 38) then
                local npcId = GetEntityModel(npc)
                openInteractionMenu(npcId)
            end
        else
            lib:hideTextUI()
        end
        
        Wait(100)
    end
end)
