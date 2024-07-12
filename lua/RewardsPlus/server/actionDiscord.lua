net.Receive("Rewards.actionDiscord", function(len, ply)
    local steamid64 = ply:SteamID64()

    net.Start("Rewards.checkDiscord")
    net.WriteString(steamid64)
    net.Send(ply)   
end)

net.Receive("Rewards.resDiscord", function(len, ply)
    local verified = net.ReadBool()

    if ply:GetPData("rewards_discord") == 'false' or ply:GetPData("rewards_discord") == nil then
        if verified then
            ply:SetPData( "rewards_discord", 'true' )
            if Rewards.types[Rewards.Config.DiscordRewardType] and Rewards.types[Rewards.Config.DiscordRewardType].OnClaim then Rewards.types[Rewards.Config.DiscordRewardType].OnClaim(ply, Rewards.Config.DiscordReward) end
        else
            net.Start("Rewards.openDiscord")
            net.WriteString(Rewards.Config.DiscordID)
            net.Send(ply)
        end
    else
        ply:ChatPrint(Rewards.getTranslation("RewardText2"))
    end
end)

net.Receive("Rewards.actionNonDef", function(len, ply)
   ply:ChatPrint("Action non définie")
end)