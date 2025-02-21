net.Receive("Rewards.actionVIP", function(len, ply)

    local allowedGroups = RewardsPlus.VIPgroup
    local steamID = ply:SteamID()
    
    if allowedGroups[ply:GetUserGroup()] == true then
        RewardsPlus.isOnCooldown(steamID, "Reward_VIP", function(isOnCooldown, remainingSeconds)
            if isOnCooldown then
                local formattedTime = RewardsPlus.formatTime(remainingSeconds)
                ply:ChatPrint(RewardsPlus.getTranslation("DailyText1") .. formattedTime)
            else
                local currentDateTime = os.date("%Y-%m-%d %H:%M:%S")
                RewardsPlus.updateReward(steamID, "Reward_VIP", currentDateTime)
                if RewardsPlus.types[RewardsPlus.Config.VIPRewardType] and RewardsPlus.types[RewardsPlus.Config.VIPRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.VIPRewardType].OnClaim(ply, RewardsPlus.Config.VIPReward) end
            end
        end)
    else
        ply:ChatPrint(RewardsPlus.getTranslation("VIPText1"))
        net.Start("Rewards.openShop")
        net.WriteString(RewardsPlus.Config.Shop)
        net.Send(ply)
    end
end)

