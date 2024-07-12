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

    local url = 'https://api.steampowered.com/ISteamUser/GetUserGroupList/v1/?format=json&key=' .. Rewards.Config.SteamAPIKey .. '&steamid=' .. steamID64

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

    -- Appel de la fonction de vérification de l'appartenance au groupe Steam
    IsPlayerInSteamGroup(ply, Rewards.Config.SteamGroupID, function(inGroup)
        if ply:GetPData("rewards_steam") == 'false' or ply:GetPData("rewards_steam") == nil then
            if inGroup then
                ply:SetPData( "rewards_steam", 'true' )
                if Rewards.types[Rewards.Config.SteamRewardType] and Rewards.types[Rewards.Config.SteamRewardType].OnClaim then Rewards.types[Rewards.Config.SteamRewardType].OnClaim(ply, Rewards.Config.SteamReward) end
            else
                net.Start("Rewards.openSteam")
                net.WriteString(Rewards.Config.SteamGroupID)
                net.Send(ply)          
            end
        else
            ply:ChatPrint(Rewards.getTranslation("RewardText2"))
        end
    end)
end)
