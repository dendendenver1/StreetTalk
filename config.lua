Config = {}

Config.UseESX = false

Config.Framework = {
    ESX = {
        enabled = Config.UseESX,
        resourceName = 'es_extended',
        moneyAccount = 'money',
        drugItem = 'weed'
    }
}

Config.Interactions = {
    maxDistance = 2.0,
    cooldownTime = 30000,
    
    outcomes = {
        directions = {
            helpful = 60,
            unhelpful = 30,
            rude = 10
        },
        
        begging = {
            success = 25,
            refuse = 50,
            callPolice = 25,
            minAmount = 5,
            maxAmount = 20
        },
        
        threatening = {
            success = 30,
            flee = 35,
            callPolice = 35,
            minAmount = 20,
            maxAmount = 100
        },
        
        buyDrugs = {
            success = 20,
            refuse = 60,
            callPolice = 20,
            minPrice = 50,
            maxPrice = 200
        },
        
        sellJunk = {
            success = 40,
            refuse = 60,
            minAmount = 10,
            maxAmount = 50
        },
        
        flirt = {
            positive = 30,
            neutral = 50,
            negative = 20
        }
    }
}

Config.Streets = {
    "Vinewood Boulevard",
    "Del Perro Freeway", 
    "Great Ocean Highway",
    "Elgin Avenue",
    "Hawick Avenue",
    "Las Lagunas Boulevard",
    "Mirror Park Boulevard",
    "Strawberry Avenue",
    "Grove Street",
    "Davis Avenue",
    "Forum Drive",
    "Innocence Boulevard"
}

Config.Responses = {
    smallTalk = {
        "Nice weather we're having, isn't it?",
        "This city gets crazier every day.",
        "Did you hear about that thing on the news?",
        "Traffic's been terrible lately.",
        "I love what they've done with this neighborhood.",
        "You look familiar, do I know you?",
        "Been living here my whole life.",
        "Things were different back in my day."
    }
}
