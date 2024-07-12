local cooldownTime = Rewards.Cooldown 
local saveFile = "dailyrewards_cooldowns.txt"
local cooldowns = Rewards.loadCooldowns(saveFile) or {}

net.Receive("Rewards.actionDaily", function(len, ply)

    local steamid64 = ply:SteamID64()

    net.Start("Rewards.checkDaily")
    net.WriteString(steamid64)
    net.Send(ply) 
end)

local function verifySteamName(steamid, callback)
    steamworks.RequestPlayerInfo(steamid, function(steamName)
        if steamName and string.sub(steamName, 1, #Rewards.ServerTag) == Rewards.ServerTag then
            callback(true)
        else
            callback(false)
        end
    end)
end

hook.Add("ShutDown", "RewardsPlus_SaveCooldownsOnShutdown", function()
    Rewards.saveCooldowns(saveFile, cooldowns)
end)


net.Receive("Rewards.resDaily", function(len, ply)
    local steamName = net.ReadString()

    if(string.sub(steamName, 1, #Rewards.ServerTag) == Rewards.ServerTag) then
        if Rewards.isPlayerOnCooldown(ply, cooldowns, cooldownTime) then
            local remainingTime = cooldownTime - (os.time() - cooldowns[ply:SteamID()])
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            local seconds = remainingTime % 60

            ply:ChatPrint(string.format(Rewards.getTranslation("DailyText1"), hours, minutes, seconds))
        else
            cooldowns[ply:SteamID()] = os.time()
            Rewards.saveCooldowns(saveFile, cooldowns)
            if Rewards.types[Rewards.Config.DailyRewardType] and Rewards.types[Rewards.Config.DailyRewardType].OnClaim then Rewards.types[Rewards.Config.DailyRewardType].OnClaim(ply, Rewards.Config.DailyReward) end        end
    else
        ply:ChatPrint(Rewards.getTranslation("DailyText2"))
    end
end)

