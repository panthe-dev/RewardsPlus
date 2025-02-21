net.Receive("Rewards.actionDaily", function(len, ply)

    local steamid64 = ply:SteamID64()

    net.Start("Rewards.checkDaily")
    net.WriteString(steamid64)
    net.Send(ply) 
end)

local function verifySteamName(steamid, callback)
    steamworks.RequestPlayerInfo(steamid, function(steamName)
        if steamName and string.sub(steamName, 1, #RewardsPlus.ServerTag) == RewardsPlus.ServerTag then
            callback(true)
        else
            callback(false)
        end
    end)
end

net.Receive("Rewards.resDaily", function(len, ply)
    local steamName = net.ReadString()
    local steamID = ply:SteamID()

    if(string.sub(steamName, 1, #RewardsPlus.ServerTag) == RewardsPlus.ServerTag) then
        RewardsPlus.isOnCooldown(steamID, "Reward_Daily", function(isOnCooldown, remainingSeconds)
            if isOnCooldown then
                local formattedTime = RewardsPlus.formatTime(remainingSeconds)
                ply:ChatPrint(RewardsPlus.getTranslation("DailyText1") .. formattedTime)
            else
                local currentDateTime = os.date("%Y-%m-%d %H:%M:%S")
                RewardsPlus.updateReward(steamID, "Reward_Daily", currentDateTime)
                if RewardsPlus.types[RewardsPlus.Config.DailyRewardType] and RewardsPlus.types[RewardsPlus.Config.DailyRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.DailyRewardType].OnClaim(ply, RewardsPlus.Config.DailyReward) end
            end
        end)
    else
        ply:ChatPrint(RewardsPlus.getTranslation("DailyText2"))
    end
end)

