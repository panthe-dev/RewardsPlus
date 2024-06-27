function Rewards.sendAnnounce(ply, message)
    for _, player in ipairs(player.GetAll()) do
        player:ChatPrint(message)
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
        

        local giveaway = {
            name = giveawayData.name or "Unnamed Giveaway",
            rewardtype = giveawayData.rewardtype or "Unknown Reward Type",
            amount = giveawayData.amount or 0,  
            hasJoined = table.HasValue(players, ply:SteamID()),
            winner = giveawayData.winner or "",
            redeem = giveawayData.redeem or false,
            players = #players or 0,
            requirement = requirement
            
        }
        table.insert(giveawaysTable, giveaway)
    end

    return giveawaysTable
end