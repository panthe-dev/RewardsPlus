net.Receive("Rewards.actionDiscord", function(len, ply)
    local steamid64 = ply:SteamID64()

    net.Start("Rewards.checkDiscord")
    net.WriteString(steamid64)
    net.Send(ply)   
end)

net.Receive("Rewards.resDiscord", function(len, ply)
    local verified = net.ReadBool()
    local steamID = ply:SteamID()

    RewardsPlus.getValue(steamID, "Reward_Discord", function(val)
        if not val or val == 0 then
            if verified then
                RewardsPlus.updateReward(steamID, "Reward_Discord", true)
                if RewardsPlus.types[RewardsPlus.Config.DiscordRewardType] and RewardsPlus.types[RewardsPlus.Config.DiscordRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.DiscordRewardType].OnClaim(ply, RewardsPlus.Config.DiscordReward) end
            else
                net.Start("Rewards.openDiscord")
                net.WriteString(RewardsPlus.Config.DiscordID)
                net.Send(ply)
            end
        else
            ply:ChatPrint(RewardsPlus.getTranslation("RewardText2"))
        end
    end)
end)

net.Receive("Rewards.actionNonDef", function(len, ply)
   ply:ChatPrint("Action non définie")
end)