-- Vérifie si un joueur est membre d'un groupe Steam en utilisant l'API Steam
local function IsPlayerInSteamGroup(ply, groupID, callback)
    if not IsValid(ply) or not ply:IsPlayer() then
        print("Joueur invalide ou non valide.")
        return false
    end

    local steamID64 = ply:SteamID64()

    -- Vérifie si le joueur a un SteamID64 valide
    if not steamID64 then
        print("Impossible d'obtenir l'ID Steam64 du joueur.")
        return false
    end

    local url = 'https://api.steampowered.com/ISteamUser/GetUserGroupList/v1/?format=json&key=' .. RewardsPlus.Config.SteamAPIKey .. '&steamid=' .. steamID64

    -- Effectue une requête HTTP pour vérifier l'appartenance au groupe Steam
    http.Fetch(url, function(body, _, _, _)
        local data = util.JSONToTable(body)

        if data and data.response.success == true then
            ply.inGroup = false

            for _, group in ipairs(data.response.groups) do
                if tostring(group.gid) == tostring(groupID) then
                    ply.inGroup = true
                    break
                end
            end

            callback(ply)

        else
            print("Erreur lors de la vérification de l'appartenance au groupe Steam.")
            if callback then
                callback(false)
            end
        end
    end, function(error)
        print("Erreur lors de la requête HTTP : " .. error)
        if callback then
            callback(false)
        end
    end)
end

net.Receive("Rewards.actionSteam", function(len, ply)
    local steamID = ply:SteamID()
    IsPlayerInSteamGroup(ply, RewardsPlus.Config.SteamGroupID, function(inGroup)
        if not inGroup then
            net.Start("Rewards.openSteam")
            net.WriteString(RewardsPlus.Config.SteamGroupID)
            net.Send(ply)
            return
        end

        RewardsPlus.getValue(steamID, "Reward_Steam", function(val)
            if not val or val == 0 then
                RewardsPlus.updateReward(steamID, "Reward_Steam", true)
                if RewardsPlus.types[RewardsPlus.Config.SteamRewardType] and RewardsPlus.types[RewardsPlus.Config.SteamRewardType].OnClaim then
                    RewardsPlus.types[RewardsPlus.Config.SteamRewardType].OnClaim(ply, RewardsPlus.Config.SteamReward)
                end
            else
                ply:ChatPrint(RewardsPlus.getTranslation("RewardText2"))
            end
        end)
    end)
end)