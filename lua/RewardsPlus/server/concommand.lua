if SERVER then

 local function checkRewards(ply, reqtype, callback)


    local steamID = ply:SteamID()

    if reqtype == "VIP" then
        callback(RewardsPlus.VIPgroup[ply:GetUserGroup()] == true)
    end

    RewardsPlus.getValue(steamID, reqtype, function(val)
        callback(val)
    end)
end   
    
-- Fonction pour définir les valeurs des récompenses pour un joueur
local function SetRewardsValue(ply, cmd, args)

    if not IsValid(ply) or not RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        print(RewardsPlus.getTranslation("noperm"))
        return
    end

    if not args[1] then
        print("set_rewards_value <SteamID> <reward type> <true/false>")
        return
    end

    local target = player.GetBySteamID(args[1])

    if not IsValid(target) then
        ply:ChatPrint(RewardsPlus.getTranslation("noplayer"))
        return
    end

    if not args[2] then
        print(RewardsPlus.getTranslation("rewardtype"))
        return
    end

    local rewardType = args[2]

    local value = args[3]
    if value ~= 'true' and value ~= 'false' then
        print(RewardsPlus.getTranslation("err1"))
        return
    end

    target:SetPData("rewards_" .. rewardType, value)
    print("Value of rewards_" .. rewardType .. " for " .. target:Nick() .. " defined to " .. value)
end

-- Fonction de suggestion pour le type de récompense
local function Suggestions(cmd, args)
    if #args == 1 then
        return {"discord", "daily", "vip", "steam", "ref"}
    end
end

-- Ajout de la commande console avec la suggestion de type de récompense
concommand.Add("set_rewards_value", SetRewardsValue, Suggestions, RewardsPlus.getTranslation("setrewardvalue"))


concommand.Add("set_giveaway", function(ply, cmd, args)
    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        print(RewardsPlus.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 4 then
        print("Usage: set_giveaway <title> <reward_type> <amount/giftcard_code> <requirement>")
        return
    end

    -- Récupérer les arguments
    local title = args[1]
    local rewardType = args[2]
    local amountOrGiftcardCode = args[3]
    local requirementType = args[4]

    -- Vérifier le type de récompense
    local validRewardTypes = {
        ["DarkRP"] = true,
        ["aShop"] = true,
        ["PS1"] = true,
        ["PS2"] = true,
        ["PS2 Premium"] = true,
        ["giftcard"] = true
    }

    local reqTypes = {
        ["Reward_Steam"] = true,
        ["Reward_Discord"] = true,
        ["Reward_Ref"] = true,
        ["VIP"] = true,
        ["None"] = true,
    }

    if not validRewardTypes[rewardType] then
        print(RewardsPlus.getTranslation("err2"))
        return
    end

    if not reqTypes[requirementType] then
        print(RewardsPlus.getTranslation("err26"))
        return
    end

    -- Ajouter des informations supplémentaires selon le type de récompense
    local amount = nil
    local giftcode = nil

    if rewardType == "giftcard" then
        giftcode = amountOrGiftcardCode
    else
        if string.match(amountOrGiftcardCode, "^%d+$") ~= nil then
            amount = tonumber(amountOrGiftcardCode)
        else
            print(RewardsPlus.getTranslation("err4"))
            return
        end
    end

    -- Ajouter le giveaway à la base de données
    RewardsPlus.addGiveaway(title, rewardType, amount or giftcode, "", false, {}, false, requirementType)

    print(RewardsPlus.getTranslation("err5"))
    RewardsPlus.sendAnnounce(ply, RewardsPlus.getTranslation("ann1"))
end)

concommand.Add("del_giveaway", function(ply, cmd, args)
    -- Vérifier les permissions de l'utilisateur
    if not IsValid(ply) or not RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        ply:ChatPrint(RewardsPlus.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        ply:ChatPrint("Usage: del_giveaway <title>")
        return
    end

    -- Récupérer le titre du giveaway à supprimer
    local title = args[1]

    -- Vérifier si le giveaway avec le titre donné existe
    RewardsPlus.giveawayExists(title, function(exists)
        if not exists then
            ply:ChatPrint("Giveaway with title '" .. title .. "' not found.")
            return
        end

        -- Supprimer le giveaway
        RewardsPlus.deleteGiveaway(title, function(success)
            if success then
                ply:ChatPrint("Giveaway '" .. title .. RewardsPlus.getTranslation("err7"))
            else
                ply:ChatPrint("Failed to delete giveaway '" .. title .. "'.")
            end
        end)
    end)
end)

concommand.Add("join_giveaway", function(ply, cmd, args)
    if not IsValid(ply) then
        print(RewardsPlus.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: join_giveaway <title>")
        return
    end

    local title = args[1]

    RewardsPlus.getGiveaway(title, function(giveaway)
        if not giveaway then
            ply:ChatPrint(RewardsPlus.getTranslation("err9"))
            return
        end

        if giveaway.winner and giveaway.winner ~= "" then
            ply:ChatPrint(RewardsPlus.getTranslation("err10"))
            return
        end

        if giveaway.requirement and giveaway.requirement ~= "None" then
            checkRewards(ply, giveaway.requirement, function(val)
                if not val then
                    ply:ChatPrint(RewardsPlus.getTranslation("err27"))
                    return
                end
            end)
        end

        local players = giveaway.players and RewardsPlus.stringToTable(giveaway.players) or {}
        for _, playerID in ipairs(players) do
            if playerID == ply:SteamID() then
                ply:ChatPrint(RewardsPlus.getTranslation("err11"))
                return
            end
        end

        RewardsPlus.addPlayerToGiveaway(title, ply:SteamID(), function(success)
            if success then
                ply:ChatPrint(RewardsPlus.getTranslation("err12") .. title .. RewardsPlus.getTranslation("err13"))
            else
                ply:ChatPrint(RewardsPlus.getTranslation("err14"))
            end
        end)
    end)
end)

concommand.Add("rand_giveaway", function(ply, cmd, args)
    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        print(RewardsPlus.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: rand_giveaway <title>")
        return
    end

    local title = args[1]

    -- Vérifier si le giveaway spécifié existe
    RewardsPlus.giveawayExists(title, function(exists)
        if not exists then
            print(RewardsPlus.getTranslation("err15"))
            return
        end

        -- Obtenir les participants du giveaway
        RewardsPlus.getGiveawayPlayers(title, function(players)
            if not players or next(players) == nil then
                ply:ChatPrint(RewardsPlus.getTranslation("err16"))
                return
            end

            -- Tirer au sort un joueur parmi les participants
            local steamIDs = {}
            for _, steamID in ipairs(players) do
                table.insert(steamIDs, steamID)
            end
            local winnerIndex = math.random(1, #steamIDs)
            local winnerSteamID = steamIDs[winnerIndex]

            -- Mettre à jour le champ winner avec le Steam ID du joueur
            RewardsPlus.updateGiveawayWinner(title, winnerSteamID, function(success)
                if success then
                    RewardsPlus.sendAnnounce(ply, RewardsPlus.getTranslation("err17") .. title .. RewardsPlus.getTranslation("err18") .. winnerSteamID)
                else
                    ply:ChatPrint("Failed to update giveaway winner.")
                end
            end)
        end)
    end)
end)

concommand.Add("hl_giveaway", function(ply, cmd, args)
    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not RewardsPlus.Config.AdminGroup[ply:GetUserGroup()] then
        print(RewardsPlus.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: hl_giveaway <title>")
        return
    end

    local title = args[1]

    -- Vérifier si le giveaway spécifié existe
    RewardsPlus.giveawayExists(title, function(exists)
        if not exists then
            print(RewardsPlus.getTranslation("err15"))
            return
        end

        -- Mettre à jour le champ hl pour le giveaway spécifié
        RewardsPlus.updateGiveawayHL(title, function(success)
            if success then
                ply:ChatPrint("Giveaway '" .. title .. RewardsPlus.getTranslation("err28"))

                -- Obtenir le titre du giveaway mis en évidence et envoyer aux joueurs
                RewardsPlus.getHighlightedGiveaway(function(hlTitle)
                    if hlTitle then
                        net.Start("Rewards.openHl")
                        net.WriteString(hlTitle)
                        net.Send(ply)
                    end
                end)
            else
                ply:ChatPrint("Failed to highlight the giveaway.")
            end
        end)
    end)
end)


    
end

