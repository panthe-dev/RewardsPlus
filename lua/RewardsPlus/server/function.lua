function Rewards.sendAnnounce(ply, message)
    for _, player in ipairs(player.GetAll()) do
        player:ChatPrint(message)
        player:EmitSound( "Weapon_Crossbow.BoltElectrify",75, 100, 0.5, CHAN_AUTO  )
    end
end

function Rewards.sendAllGiveaways(ply)
    local filePath = "rewards/giveaways.json"

    if not file.Exists(filePath, "DATA") then
        print(Rewards.getTranslation("err14"))
        return {}
    end

    local fileContents = file.Read(filePath, "DATA")
    local giveaways = util.JSONToTable(fileContents)

    if not giveaways then
        print(Rewards.getTranslation("err19"))
        return {}
    end

    -- Tableau pour stocker tous les giveaways
    local giveawaysTable = {}

    -- Parcourir chaque giveaway et les ajouter au tableau
    for title, giveawayData in pairs(giveaways.giveaways) do
        local players = giveawayData.players or {}
        local requirement = Rewards.getTranslation("descAdmin24")

        if giveawayData.requirement == "steam" then requirement = Rewards.getTranslation("descAdmin20")
        elseif giveawayData.requirement == "discord" then requirement = Rewards.getTranslation("descAdmin21")
        elseif giveawayData.requirement == "ref" then requirement = Rewards.getTranslation("descAdmin22")
        elseif giveawayData.requirement == "VIP" then requirement = Rewards.getTranslation("descAdmin23")
        else requirement = Rewards.getTranslation("descAdmin24")
        end

        -- Calculer le nombre de participants
        local playerCount = 0
        for _ in pairs(players) do
            playerCount = playerCount + 1
        end   

        local giveaway = {
            name = giveawayData.name or "Unnamed Giveaway",
            rewardtype = giveawayData.rewardtype or "Unknown Reward Type",
            amount = giveawayData.amount or 0,  
            hasJoined = players[ply:SteamID()] or false,
            winner = giveawayData.winner or "",
            redeem = giveawayData.redeem or false,
            players = playerCount,
            requirement = requirement
            
        }
        table.insert(giveawaysTable, giveaway)
    end

    return giveawaysTable
end

function Rewards.GetHighlightedGiveaway()
    local filePath = "rewards/giveaways.json"

    -- Vérifier si le fichier de giveaways existe
    if not file.Exists(filePath, "DATA") then
        return nil
    end

    -- Charger les giveaways depuis le fichier JSON
    local fileContent = file.Read(filePath, "DATA")
    local giveawaysData = util.JSONToTable(fileContent) or {}

    -- Vérifier les giveaways pour trouver celui qui a `hl` à `true`
    for title, giveaway in pairs(giveawaysData.giveaways) do
        if giveaway.hl then
            return title
        end
    end

    -- Si aucun giveaway avec `hl` à `true` n'est trouvé, retourner le premier
    for title, _ in pairs(giveawaysData.giveaways) do
        return title
    end

    return nil
end


function Rewards.SteamIDTo64(steamID)
    if not steamID then return end
    local steamIDParts = string.Explode(":", steamID)
    local x = tonumber(steamIDParts[2])
    local y = tonumber(steamIDParts[3])
    local steamID64 = (y * 2) + x + 76561197960265728
    return tostring(steamID64)
end
