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
            if Rewards.Config.DiscordRewardType == "AShop" then
                ply:ashop_addCoinsSafe(Rewards.Config.DiscordReward, false)
            elseif Rewards.Config.DiscordRewardType == "SH Pointshop" then
                RunConsoleCommand("sh_pointshop_add_standard_points", ply:SteamID(), tostring(Rewards.Config.DiscordReward))
            else
                ply:addMoney(Rewards.Config.DiscordReward)                  
            end
            ply:ChatPrint(Rewards.getTranslation("RewardText")..Rewards.Config.DiscordReward.. " "..Rewards.Config.Currency)
        else
            net.Start("Rewards.openDiscord")
            net.WriteString(Rewards.Config.DiscordID)
            net.Send(ply)
        end
    else
        ply:ChatPrint(Rewards.getTranslation("RewardText2"))
    end
end)

-- net.Receive("Rewards.actionDiscord", function(len, ply)
--     print(ply:gmIntIsVerified())
--     if ply:GetPData("rewards_discord") == 'false' or ply:GetPData("rewards_discord") == nil then
--         if ply:gmIntIsVerified() then
--             ply:SetPData( "rewards_discord", 'true' )
--             ply:addMoney(Rewards.Config.DiscordReward)
--             ply:ChatPrint("Vous avez reçu "..Rewards.Config.DiscordReward.. " $")
--         else
--             net.Start("Rewards.openDiscord")
--             net.WriteString(Rewards.Config.DiscordID)
--             net.Send(ply)
--         end
--     else
--         ply:ChatPrint("Vous avez déjà obtenu cette récompense!")
--     end   
-- end)

net.Receive("Rewards.actionNonDef", function(len, ply)
   ply:ChatPrint("Action non définie")
end)