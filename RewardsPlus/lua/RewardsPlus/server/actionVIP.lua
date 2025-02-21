local cooldownTime = Rewards.Cooldown 
local saveFile = "viprewards_cooldowns.txt"
local cooldowns = Rewards.loadCooldowns(saveFile) or {}


hook.Add("ShutDown", "RewardsPlus_SaveCooldownsOnShutdown", function()
    Rewards.saveCooldowns(saveFile, cooldowns)
end)


net.Receive("Rewards.actionVIP", function(len, ply)

    local allowedGroups = Rewards.VIPgroup
    
    if allowedGroups[ply:GetUserGroup()] == true then
        if Rewards.isPlayerOnCooldown(ply, cooldowns, cooldownTime) then
            local remainingTime = cooldownTime - (os.time() - cooldowns[ply:SteamID()])
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            local seconds = remainingTime % 60

            ply:ChatPrint(string.format(Rewards.getTranslation("DailyText1"), hours, minutes, seconds))
        else
            cooldowns[ply:SteamID()] = os.time()
            Rewards.saveCooldowns(saveFile, cooldowns)
            if Rewards.types[Rewards.Config.VIPRewardType] and Rewards.types[Rewards.Config.VIPRewardType].OnClaim then Rewards.types[Rewards.Config.VIPRewardType].OnClaim(ply, Rewards.Config.VIPReward) end
        end
    else
        ply:ChatPrint(Rewards.getTranslation("VIPText1"))
        net.Start("Rewards.openShop")
        net.WriteString(Rewards.Config.Shop)
        net.Send(ply)
    end
end)

