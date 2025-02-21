local function EnvoyerAdminPopup(ply, activeTab, coorScroll)

    if IsValid(ply) and RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        RewardsPlus.networkUI(ply, activeTab, coorScroll)
        RewardsPlus.networkGiveaway(ply)
        RewardsPlus.openAdminMenu(ply)
    else
        ply:ChatPrint(RewardsPlus.getTranslation("adminMsg"))
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
        ply:ChatPrint(RewardsPlus.getTranslation("InvalidSteamId"))
        return
    end

    RewardsPlus.CreerCheckData(targetPlayer, function(checkData)   
        net.Start("Rewards.SendPlayerRewards")
            --net.WriteBool(checkData.daily)
            net.WriteBool(checkData.discord)
            net.WriteBool(checkData.ref)
            net.WriteBool(checkData.steam)
            --net.WriteBool(checkData.vip)
        net.Send(ply)
    end)
end)

net.Receive("Rewards.redGiveaway", function(len, ply)
    local giveawayName = net.ReadString()
    local steamID = ply:SteamID()

    -- Vérifier si le giveaway spécifié existe
    RewardsPlus.giveawayExists(giveawayName, function(exists)
        if not exists then
            ply:ChatPrint(RewardsPlus.getTranslation("err9"))
            return
        end

        -- Vérifier si le joueur a gagné le giveaway
        RewardsPlus.checkGiveawayWinner(giveawayName, steamID, function(isWinner)
            if not isWinner then
                ply:ChatPrint(RewardsPlus.getTranslation("err20"))
                return
            end

            -- Vérifier si le giveaway a déjà été réclamé
            RewardsPlus.isGiveawayRedeemed(giveawayName, function(isRedeemed)
                if isRedeemed then
                    ply:ChatPrint(RewardsPlus.getTranslation("err21"))
                    return
                end

                -- Récupérer les informations du giveaway pour obtenir le type de récompense et la valeur
                RewardsPlus.getGiveawayDetails(giveawayName, function(giveaway)
                    if not giveaway then
                        ply:ChatPrint("Failed to retrieve giveaway details.")
                        return
                    end

                    -- Récompenser le joueur
                    if giveaway.rewardtype == "giftcard" then
                        if RewardsPlus.types[giveaway.rewardtype] and RewardsPlus.types[giveaway.rewardtype].OnClaim then
                            RewardsPlus.types[giveaway.rewardtype].OnClaim(ply, giveaway.amount)
                        end
                    else
                        if RewardsPlus.types[giveaway.rewardtype] and RewardsPlus.types[giveaway.rewardtype].OnClaim then
                            RewardsPlus.types[giveaway.rewardtype].OnClaim(ply, giveaway.amount)
                        end
                    end

                    -- Marquer le giveaway comme réclamé
                    RewardsPlus.markGiveawayAsRedeemed(giveawayName, function(success)
                        if success then
                            ply:ChatPrint(RewardsPlus.getTranslation("err22") .. giveawayName .. RewardsPlus.getTranslation("err23"))
                        else
                            ply:ChatPrint("Failed to mark giveaway as redeemed.")
                        end
                    end)
                end)
            end)
        end)
    end)
end)





