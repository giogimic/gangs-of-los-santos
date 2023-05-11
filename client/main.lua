local zones = {}
local pedModels = {}
local bossModels = {}
local enemyStats = {}

local spawnedPeds = {}

Citizen.CreateThread(function()
    LoadConfig()

    while true do
        Citizen.Wait(5000)

        for _, zone in ipairs(zones) do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local isInZone = false

            for _, coord in ipairs(zone.coords) do
                local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))

                if distance < 50.0 then
                    isInZone = true
                    break
                end
            end

            if isInZone then
                local pedSet = pedModels[zone.gang]
                local bossModel = bossModels[zone.gang]
                local bossChance = math.random(1, 10)

                for i = 1, 5 do
                    local pedModel = pedSet[i]
                    local pedCoords = GetOffsetFromEntityInWorldCoords(playerPed, math.random(-20, 20) + 0.0, math.random(-20, 20) + 0.0, 0.0)
                    local pedHeading = GetHeadingFromVector_2d(player.x - pedCoords.x, playerCoords.y - pedCoords.y)

                    RequestModel(pedModel)

                    while not HasModelLoaded(pedModel) do
                        Citizen.Wait(0)
                    end

                    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, true, false)

                    if i == 5 and bossChance == 1 then
                        RequestModel(bossModel)

                        while not HasModelLoaded(bossModel) do
                            Citizen.Wait(0)
                        end

                        local bossPed = CreatePed(4, bossModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, true, false)
                        SetPedAsBoss(bossPed, true)
                        SetPedCanRagdoll(bossPed, false)
                        SetPedCombatAttributes(bossPed, enemyStats.bossCombatAttributes, true)
                        NetworkRegisterEntityAsNetworked(bossPed)
                        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(bossPed), true)
                    end

                    SetPedAsEnemy(ped, true)
                    SetPedCanRagdoll(ped, false)
                    SetPedCombatAttributes(ped, enemyStats.combatAttributes, true)
                    SetPedCombatAbility(ped, enemyStats.combatAbility)
                    SetPedCombatRange(ped, enemyStats.combatRange)
                    SetPedCombatMovement(ped, enemyStats.combatMovement)
                    SetPedFleeAttributes(ped, enemyStats.fleeAttributes[1], enemyStats.fleeAttributes[2])
                    SetPedRelationshipGroupHash(ped, GetHashKey("ENEMY"))
                    NetworkRegisterEntityAsNetworked(ped)
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(ped), true)

                    for _, weapon in ipairs(enemyStats.weapons) do
                        GiveWeaponToPed(ped, GetHashKey(weapon), 9999, false, true)
                        SetPedInfiniteAmmo(ped, true, GetHashKey(weapon))
                    end

                    table.insert(spawnedPeds, ped)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        for i, ped in ipairs(spawnedPeds) do
            if not DoesEntityExist(ped) then
                table.remove(spawnedPeds, i)
            end
        end
    end
end)

function LoadConfig()
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config.json")
    local config = json.decode(configFile)

    zones = config.zones
    pedModels = config.pedModels
    bossModels = config.bossModels
    enemyStats = config.enemyStats
end
