local Data = include("rewards/shared/data.lua")
local saveFile = "refcodes.txt"
local refCodes = Data.loadCooldowns(saveFile) or {}

-- Fonction pour générer un code aléatoire de 5 lettres
local function generateRandomCode(length)
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local code = ""
    for i = 1, length do
        local randIndex = math.random(1, #letters)
        code = code .. letters:sub(randIndex, randIndex)
    end
    return code
end

-- Fonction pour générer un code de référence unique
local function generateRefCode()
    local code
    repeat
        code = generateRandomCode(5)
        -- Vérifier si le code est déjà utilisé
        local codeExists = false
        for _, existingCode in pairs(refCodes) do
            if existingCode == code then
                codeExists = true
                break
            end
        end
    until not codeExists
    return code
end

-- Hook pour assigner un code de référence au joueur lors de sa première connexion
hook.Add("PlayerInitialSpawn", "CheckPlayerRefCode", function(ply)
    local steamID = ply:SteamID()
    if not refCodes[steamID] then
        local newRefCode = generateRefCode()
        refCodes[steamID] = newRefCode -- Assigner le code au SteamID du joueur
        Data.saveCooldowns(saveFile, refCodes) -- Sauvegarder les codes de référence
    end
end)

hook.Add("PlayerInitialSpawn", "CheckPendingRewards", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            local steamID = ply:SteamID()
            local pendingReward = tonumber(ply:GetPData("pending_reward", "0"))

            if pendingReward > 0 then

                if Rewards.Config.RefRewardType == "AShop" then
                    ply:ashop_addCoinsSafe(pendingReward, false)
                elseif Rewards.Config.RefRewardType == "SH Pointshop" then
                    RunConsoleCommand("sh_pointshop_add_standard_points", ply:SteamID(), tostring(pendingReward))
                else
                    ply:addMoney(pendingReward)                  
                end
                ply:ChatPrint(Rewards.getTranslation("RewardText") .. pendingReward .. " "..Rewards.Config.Currency..Rewards.getTranslation("RefText1"))
                ply:SetPData("pending_reward", 0)
            end
        end
    end)
end)


net.Receive("Rewards.submitRefCode", function(len, ply)
    local refCode = net.ReadString()
    local steamID = ply:SteamID()

    -- Vérifiez si le code de référence appartient au joueur lui-même
    if refCodes[steamID] == refCode then
        ply:ChatPrint(Rewards.getTranslation("RefText2"))
        return
    end

    -- Vérifiez si le code de référence est valide et appartient à un autre joueur
    local isValidCode = false
    local refOwnerSteamID = nil
    for storedSteamID, storedCode in pairs(refCodes) do
        if storedCode == refCode then
            isValidCode = true
            refOwnerSteamID = storedSteamID
            break
        end
    end

    if isValidCode then
        ply:SetPData("rewards_ref", 'true')

        if Rewards.Config.RefRewardType == "AShop" then
            ply:ashop_addCoinsSafe(Rewards.Config.RefReward, false)
        elseif Rewards.Config.RefRewardType == "SH Pointshop" then
            RunConsoleCommand("sh_pointshop_add_standard_points", ply:SteamID(), tostring(Rewards.Config.RefReward))
        else
            ply:addMoney(Rewards.Config.RefReward)                  
        end
        ply:ChatPrint(Rewards.getTranslation("RewardText")..Rewards.Config.RefReward.. " "..Rewards.Config.Currency)

        local refOwner = player.GetBySteamID(refOwnerSteamID)
        if refOwner then

            if Rewards.Config.RefRewardType == "AShop" then
                refOwner:ashop_addCoinsSafe(Rewards.Config.RefReward, false)
            elseif Rewards.Config.RefRewardType == "SH Pointshop" then
                RunConsoleCommand("sh_pointshop_add_standard_points", refOwnerSteamID, tostring(Rewards.Config.RefReward))
            else
                refOwner:addMoney(Rewards.Config.RefReward)                  
            end
            refOwner:ChatPrint(Rewards.getTranslation("RewardText")..Rewards.Config.RefReward.. " "..Rewards.Config.Currency)

        else
            -- Si le propriétaire du code n'est pas en ligne, stockez la récompense pour une utilisation ultérieure
            local pendingReward = tonumber(ply:GetPData("pending_reward", 0))
            pendingReward = pendingReward + Rewards.Config.RefReward
            util.SetPData(refOwnerSteamID, "pending_reward", pendingReward)
        end
    else
        ply:ChatPrint(Rewards.getTranslation("RefText3"))
    end
end)

    

net.Receive("Rewards.actionRef", function(len, ply)

        if (ply:GetPData("rewards_ref") == 'false' or ply:GetPData("rewards_ref") == nil) then
            net.Start("Rewards.openRef")
            net.Send(ply)          
        else
            ply:ChatPrint(Rewards.getTranslation("RewardText2"))
        end
end)
