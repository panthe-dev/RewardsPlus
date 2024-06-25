local Utilities = include("rewards/shared/utilities.lua")
local Data = include("rewards/shared/data.lua")
local cooldownTime = Rewards.Cooldown 
local saveFile = "viprewards_cooldowns.txt"
local cooldowns = Data.loadCooldowns(saveFile) or {}


hook.Add("ShutDown", "SaveCooldownsOnShutdown", function()
    Data.saveCooldowns(saveFile, cooldowns)
end)


net.Receive("Rewards.actionVIP", function(len, ply)

    local allowedGroups = Rewards.VIPgroup
    
    if(table.HasValue(allowedGroups, ply:GetUserGroup())) then
        if Utilities.isPlayerOnCooldown(ply, cooldowns, cooldownTime) then
            local remainingTime = cooldownTime - (os.time() - cooldowns[ply:SteamID()])
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            local seconds = remainingTime % 60

            ply:ChatPrint(string.format(Rewards.getTranslation("DailyText1"), hours, minutes, seconds))
        else
            cooldowns[ply:SteamID()] = os.time()
            Data.saveCooldowns(saveFile, cooldowns)

            if Rewards.Config.VIPRewardType == "AShop" then
                ply:ashop_addCoinsSafe(Rewards.Config.VIPReward, false)
            elseif Rewards.Config.VIPRewardType == "SH Pointshop" then
                RunConsoleCommand("sh_pointshop_add_standard_points", ply:SteamID(), tostring(Rewards.Config.VIPReward))
            else
                ply:addMoney(Rewards.Config.VIPReward)                  
            end
            ply:ChatPrint(Rewards.getTranslation("RewardText")..Rewards.Config.VIPReward.. " "..Rewards.Config.Currency)
        end
    else
        ply:ChatPrint(Rewards.getTranslation("VIPText1"))
        net.Start("Rewards.openShop")
        net.WriteString(Rewards.Config.Shop)
        net.Send(ply)
    end
end)

