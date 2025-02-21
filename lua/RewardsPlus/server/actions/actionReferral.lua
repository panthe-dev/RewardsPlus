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
        RewardsPlus.checkValue("Ref_Code", code, function(exists)
            codeExists = tobool(exists)
        end)
    until not codeExists
    return code
end

-- Hook pour assigner un code de référence au joueur lors de sa première connexion
hook.Add("PlayerInitialSpawn", "RewardsPlus_CheckPlayerRefCode", function(ply)
    local steamID = ply:SteamID()
    RewardsPlus.getValue(steamID, "Ref_Code", function(val)
        if tostring(val) == "NULL" or not val then
            local newRefCode = generateRefCode()
            RewardsPlus.updateReward(steamID,"Ref_Code", newRefCode)
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "RewardsPlus_CheckPendingRewards", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            local steamID = ply:SteamID()
            RewardsPlus.getValue(steamID, "Pending_Reward", function(val)
                local pendingReward = val
    
                if pendingReward > 0 then
                    if RewardsPlus.types[RewardsPlus.Config.RefRewardType] and RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim(ply, pendingReward) end
                    RewardsPlus.updateReward(steamID,"Pending_Reward", 0)
                end

            end)
        end
    end)
end)


net.Receive("Rewards.submitRefCode", function(len, ply)
    local refCode = net.ReadString()
    local steamID = ply:SteamID()

    -- Vérifiez si le code de référence appartient au joueur lui-même
    RewardsPlus.getValue(steamID, "Ref_Code", function(val)
        if val == refCode then
            ply:ChatPrint(RewardsPlus.getTranslation("RefText2"))
            return
        end
    end)

    -- Vérifiez si le code de référence est valide et appartient à un autre joueur
    local isValidCode = false
    local refOwnerSteamID = nil

    RewardsPlus.checkValue("Ref_Code", refCode, function(exists)
        isValidCode = tobool(exists)
        refOwnerSteamID = exists
    end)

    if isValidCode then
        RewardsPlus.updateReward(steamID, "Reward_Ref", true)
        if RewardsPlus.types[RewardsPlus.Config.RefRewardType] and RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim(ply, RewardsPlus.Config.RefReward) end
        local refOwner = player.GetBySteamID(refOwnerSteamID)
        if refOwner then
            if RewardsPlus.types[RewardsPlus.Config.RefRewardType] and RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim then RewardsPlus.types[RewardsPlus.Config.RefRewardType].OnClaim(refOwner, RewardsPlus.Config.RefReward) end
        else
            local pendingReward
            -- Si le propriétaire du code n'est pas en ligne, stockez la récompense pour une utilisation ultérieure
            RewardsPlus.getValue(refOwnerSteamID, "Pending_Reward", function(val)
                pendingReward = val
            end)
            
            pendingReward = pendingReward + RewardsPlus.Config.RefReward
            RewardsPlus.updateReward(refOwnerSteamID, "Pending_Reward", tostring(pendingReward))
        end
    else
        ply:ChatPrint(RewardsPlus.getTranslation("RefText3"))
    end
end)

    

net.Receive("Rewards.actionRef", function(len, ply)

    RewardsPlus.getValue(ply:SteamID(),"Reward_Ref", function(val)
        if not val or val == 0 then
            net.Start("Rewards.openRef")
            net.Send(ply)          
        else
            ply:ChatPrint(RewardsPlus.getTranslation("RewardText2"))
        end
    end)
end)
