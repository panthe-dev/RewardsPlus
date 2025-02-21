function RewardsPlus.sendAnnounce(ply, message)
    for _, player in ipairs(player.GetAll()) do
        player:ChatPrint(message)
        player:EmitSound( "Weapon_Crossbow.BoltElectrify",75, 100, 0.5, CHAN_AUTO  )
    end
end

-- Fonction pour envoyer tous les giveaways à un joueur
function RewardsPlus.sendAllGiveaways(ply, callback)
    local giveawaysTable = {}
    local plySteamID = ply:SteamID()

    RewardsPlus.getAllGiveaways(function(giveaways)
        if not giveaways then
            print(RewardsPlus.getTranslation("err19"))
            ply:ChatPrint(RewardsPlus.getTranslation("err19"))
            return
        end

        local pendingRequests = #giveaways

        -- Fonction de callback pour vérifier si tous les giveaways sont traités
        local function checkAllProcessed()
            if pendingRequests == 0 then
                -- Tous les giveaways ont été traités, exécuter le callback avec les données
                callback(giveawaysTable)
            end
        end

        for _, giveawayData in pairs(giveaways) do
            RewardsPlus.getGiveawayPlayers(giveawayData.name, function(players)
                local requirement = RewardsPlus.getTranslation("descAdmin24")

                if giveawayData.requirement == "Reward_Steam" then
                    requirement = RewardsPlus.getTranslation("descAdmin20")
                elseif giveawayData.requirement == "Reward_Discord" then
                    requirement = RewardsPlus.getTranslation("descAdmin21")
                elseif giveawayData.requirement == "Reward_Ref" then
                    requirement = RewardsPlus.getTranslation("descAdmin22")
                elseif giveawayData.requirement == "VIP" then
                    requirement = RewardsPlus.getTranslation("descAdmin23")
                end

                local hasJoined = false
                local playerCount = table.Count(players)

                for _, player in ipairs(players) do
                    if plySteamID == player then
                        hasJoined = true
                    end
                end

                local giveaway = {
                    name = giveawayData.name or "Unnamed Giveaway",
                    rewardtype = giveawayData.rewardtype or "Unknown Reward Type",
                    amount = giveawayData.amount or 0,
                    hasJoined = hasJoined,
                    winner = giveawayData.winner or "",
                    redeem = tobool(giveawayData.redeem) or false,
                    players = playerCount,
                    requirement = requirement
                }

                table.insert(giveawaysTable, giveaway)

                pendingRequests = pendingRequests - 1
                checkAllProcessed()
            end)
        end

        -- Vérifier immédiatement si aucun giveaway n'est à traiter
        if #giveaways == 0 then
            checkAllProcessed()
        end
    end)
end


-- Fonction pour envoyer les giveaways par fragments
function RewardsPlus.sendGiveawaysFragmented(ply, giveawaysTable)
    local maxPerMessage = 10 -- Nombre de giveaways par message
    local totalGiveaways = #giveawaysTable/2
    local currentIndex = 1

    while currentIndex <= totalGiveaways do
        net.Start("RewardsPlus.networkGiveaway")
        local endIndex = math.min(currentIndex + maxPerMessage - 1, totalGiveaways)
        net.WriteUInt(endIndex - currentIndex + 1, 8)
        for i = currentIndex, endIndex do
            local giveaway = giveawaysTable[i]
            net.WriteString(giveaway.name)
            net.WriteString(giveaway.rewardtype)
            net.WriteInt(giveaway.amount, 32)
            net.WriteBool(giveaway.hasJoined)
            net.WriteString(giveaway.winner)
            net.WriteBool(giveaway.redeem)
            net.WriteInt(giveaway.players or 0, 8)
            net.WriteString(giveaway.requirement)
        end
        net.Send(ply)
        currentIndex = endIndex + 1
    end
end

function RewardsPlus.tableToString(tbl)
    return table.concat(tbl, ",")
end

function RewardsPlus.stringToTable(str)
    local tbl = {}
    for item in string.gmatch(str, '([^,]+)') do
        table.insert(tbl, item)
    end
    return tbl
end
