
local function EnvoyerAdminPopup(ply, activeTab, coorScroll)
    
    local giveawaytable = Rewards.sendAllGiveaways(ply)

    if IsValid(ply) and Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        net.Start("Rewards.AfficherAdminPopup")
        net.WriteUInt(#giveawaytable, 8)  
        for _, giveaway in ipairs(giveawaytable) do
            net.WriteString(giveaway.name)
            net.WriteString(giveaway.rewardtype)
            net.WriteInt(giveaway.amount, 32)
            net.WriteBool(giveaway.hasJoined)
            net.WriteString(giveaway.winner)
            net.WriteBool(giveaway.redeem)
            net.WriteInt(giveaway.players, 8)
            net.WriteString(giveaway.requirement)
        end
        net.WriteUInt(activeTab or 1, 8)
        net.WriteUInt(coorScroll or 1, 16)
        net.Send(ply)
    else
        ply:ChatPrint(Rewards.getTranslation("adminMsg"))
    end
end


local function RafraichirAdminPopup(ply, activeTab, coorScroll)
    EnvoyerAdminPopup(ply, activeTab, coorScroll)
end

net.Receive("Rewards.RefreshAdminPopUp", function(len, ply)
    local activeTab = net.ReadUInt(8)
    local coorScroll = net.ReadUInt(16) or 1
    RafraichirAdminPopup(ply, activeTab, coorScroll)
end)

net.Receive("Rewards.AdminPopUp", function(len, ply)
    EnvoyerAdminPopup(ply)
end)

net.Receive("Rewards.RequestPlayerRewards", function(len, ply)
    local steamID = net.ReadString()
    local targetPlayer = player.GetBySteamID(steamID)

    if not targetPlayer then
        ply:ChatPrint(Rewards.getTranslation("InvalidSteamId"))
        return
    end

    local rewardsData = {}

    -- Récupérer les valeurs des récompenses du joueur
    local discordReward = targetPlayer:GetPData("rewards_discord", "false")
    local steamReward = targetPlayer:GetPData("rewards_steam", "false")
    local playtimeReward = targetPlayer:GetPData("rewards_playtime", "false")
    local refReward = targetPlayer:GetPData("rewards_ref", "false")
    
    rewardsData["Discord Reward"] = discordReward
    rewardsData["Steam Reward"] = steamReward
    rewardsData["Playtime Reward"] = playtimeReward
    rewardsData["Referral Reward"] = refReward
    
    net.Start("Rewards.SendPlayerRewards")
    net.WriteString(rewardsData["Discord Reward"])
    net.WriteString(rewardsData["Steam Reward"])
    net.WriteString(rewardsData["Playtime Reward"])
    net.WriteString(rewardsData["Referral Reward"])
    net.Send(ply)
end)

net.Receive("Rewards.redGiveaway", function(len, ply)
    local giveawayName = net.ReadString()
    local steamID = ply:SteamID()
    local filePath = "rewards/giveaways.json"

    -- Vérifier si le fichier de giveaways existe
    if not file.Exists(filePath, "DATA") then
        ply:ChatPrint(Rewards.getTranslation("err8"))
        return
    end

    -- Charger les giveaways depuis le fichier JSON
    local giveawaysData = util.JSONToTable(file.Read(filePath, "DATA")) or {}
    local giveaways = giveawaysData.giveaways

    -- Vérifier si le giveaway spécifié existe
    local giveaway = giveaways[giveawayName]
    if not giveaway then
        ply:ChatPrint(Rewards.getTranslation("err9"))
        return
    end

    -- Vérifier si le joueur a gagné le giveaway
    if giveaway.winner ~= steamID then
        ply:ChatPrint(Rewards.getTranslation("err20"))
        return
    end

    -- Vérifier si le giveaway a déjà été réclamé
    if giveaway.redeem then
        ply:ChatPrint(Rewards.getTranslation("err21"))
        return
    end

    if giveaway.rewardtype == "DarkRP" then
        ply:addMoney(giveaway.amount)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. giveaway.amount .. " DarkRP Money !")
    elseif giveaway.rewardtype == "aShop" then
        ply:ashop_addCoinsSafe(giveaway.amount, false)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. giveaway.amount .. " points aShop !")
    elseif giveaway.rewardtype == "SH Pointshop" then
        RunConsoleCommand("sh_pointshop_add_standard_points", ply:SteamID(), tostring(giveaway.amount))
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. giveaway.amount .. " points SH Pointshop !")
    elseif giveaway.rewardtype == "giftcard" then
        -- Donner un code cadeau au joueur
        ply:ChatPrint(Rewards.getTranslation("err25") .. giveaway.giftcode)
    else
        ply:ChatPrint(Rewards.getTranslation("err24"))
        return
    end

    -- Marquer le giveaway comme réclamé
    giveaway.redeem = true

    -- Mettre à jour le fichier JSON avec le nouveau statut
    file.Write(filePath, util.TableToJSON(giveawaysData, true))

    ply:ChatPrint(Rewards.getTranslation("err22") .. giveawayName .. Rewards.getTranslation("err23"))
end)





