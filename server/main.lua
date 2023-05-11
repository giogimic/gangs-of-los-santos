local zones = {}
local pedModels = {}
local bossModels = {}
local enemyStats = {}

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    LoadConfig()
end)

RegisterCommand("reloadconfig", function(source, args, rawCommand)
    if source ~= 0 then
        return
    end

    LoadConfig()
    print("Configuration file reloaded.")
end)

function LoadConfig()
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config.json")
    local config = json.decode(configFile)

    zones = config.zones
    pedModels = config.pedModels
    bossModels = config.bossModels
    enemyStats = config.enemyStats
end
