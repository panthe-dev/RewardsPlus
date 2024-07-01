if SERVER then

 local function checkRewards(ply, reqtype)
    if reqtype == "VIP" then
        return Rewards.VIPgroup[ply:GetUserGroup()] == true
    end
    return ply:GetPData("rewards_"..reqtype) == "true"
end   
    
-- Fonction pour définir les valeurs des récompenses pour un joueur
local function SetRewardsValue(ply, cmd, args)

    if not IsValid(ply) or not Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        print(Rewards.getTranslation("noperm"))
        return
    end

    if not args[1] then
        print("set_rewards_value <SteamID> <reward type> <true/false>")
        return
    end

    local target = player.GetBySteamID(args[1])

    if not IsValid(target) then
        ply:ChatPrint(Rewards.getTranslation("noplayer"))
        return
    end

    if not args[2] then
        print(Rewards.getTranslation("rewardtype"))
        return
    end

    local rewardType = args[2]

    local value = args[3]
    if value ~= 'true' and value ~= 'false' then
        print(Rewards.getTranslation("err1"))
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
concommand.Add("set_rewards_value", SetRewardsValue, Suggestions, Rewards.getTranslation("setrewardvalue"))


concommand.Add("set_giveaway", function(ply, cmd, args)
    local filePath = "rewards/giveaways.json"

    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        print(Rewards.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 3 then
        print("Usage: set_giveaway <title> <reward_type> <amount/giftcard_code> <requirement>")
        return
    end

    -- Récupérer les arguments
    local title = args[1]
    local rewardType = args[2]
    local amountOrGiftcardCode = args[3]
    local requirementType = args[4]
    print(requirementType)

    -- Vérifier le type de récompense
    local validRewardTypes = {
        ["DarkRP"] = true,
        ["aShop"] = true,
        ["SH Pointshop"] = true,
        ["giftcard"] = true
    }

    local reqTypes = {
        ["steam"] = true,
        ["discord"] = true,
        ["ref"] = true,
        ["VIP"] = true,
        ["None"] = true,
    }

    if not validRewardTypes[rewardType] then
        print(Rewards.getTranslation("err2"))
        return
    end

    if not reqTypes[requirementType] then
        print(Rewards.getTranslation("err26"))
        return
    end

    -- Charger les giveaways depuis le fichier JSON
    local giveawaysData = {giveaways = {}}
    if file.Exists(filePath, "DATA") then
        local fileContent = file.Read(filePath, "DATA")
        if fileContent then
            giveawaysData = util.JSONToTable(fileContent) or {giveaways = {}}
        end
    end

    local giveaways = giveawaysData.giveaways

    -- Vérifier si le titre du giveaway existe déjà
    if giveaways[title] ~= nil then
        print(Rewards.getTranslation("err3"))
        return
    end

    -- Créer une table de données de giveaway
    local giveawayData = {
        name = title,
        rewardtype = rewardType,
        requirement = requirementType,
        players = nil,
        winner = "",
        redeem = false
    }

    -- Ajouter des informations supplémentaires selon le type de récompense
    if rewardType == "giftcard" then
        giveawayData.giftcode = amountOrGiftcardCode
    else
        if string.match(amountOrGiftcardCode, "^%d+$") ~= nil then
            giveawayData.amount = tonumber(amountOrGiftcardCode)
        else
            print(Rewards.getTranslation("err4"))
            return
        end
    end

    -- Ajouter le giveaway à la table principale des giveaways
    giveaways[title] = giveawayData

    -- Convertir la table de giveaways en format JSON et écrire dans le fichier
    file.Write(filePath, util.TableToJSON(giveawaysData, true))

    print(Rewards.getTranslation("err5"))
    Rewards.sendAnnounce(ply,Rewards.getTranslation("ann1"))
end)


concommand.Add("del_giveaway", function(ply, cmd, args)
    local filePath = "rewards/giveaways.json"

    -- Vérifier les permissions de l'utilisateur
    if not IsValid(ply) or not Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        print(Rewards.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: del_giveaway <title>")
        return
    end

    -- Récupérer le titre du giveaway à supprimer
    local title = args[1]

    -- Charger les giveaways existants s'ils sont présents
    local giveaways = {}
    if file.Exists(filePath, "DATA") then
        local fileContent = file.Read(filePath, "DATA")
        if fileContent then
            giveaways = util.JSONToTable(fileContent) or {}
        end
    end

    -- Vérifier si la clé 'giveaways' existe dans la table
    if not giveaways.giveaways then
        print(Rewards.getTranslation("err6"))
        return
    end

    -- Vérifier si le giveaway avec le titre donné existe
    if not giveaways.giveaways[title] then
        print("Giveaway with title '" .. title .. "' not found.")
        return
    end

    -- Supprimer le giveaway de la table
    giveaways.giveaways[title] = nil

    -- Mettre à jour le fichier de giveaways
    file.Write(filePath, util.TableToJSON(giveaways, true))

    ply:ChatPrint("Giveaway '" .. title .. Rewards.getTranslation("err7"))
end)

concommand.Add("join_giveaway", function(ply, cmd, args)
    if not IsValid(ply) then
        print(Rewards.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: join_giveaway <title>")
        return
    end

    local title = args[1]
    local filePath = "rewards/giveaways.json"

    -- Vérifier si le fichier de giveaways existe
    if not file.Exists(filePath, "DATA") then
        print(Rewards.getTranslation("err8"))
        return
    end

    -- Charger les giveaways depuis le fichier JSON
    local giveawaysData = util.JSONToTable(file.Read(filePath, "DATA")) or {}
    local giveaways = giveawaysData.giveaways

    -- Vérifier si le giveaway spécifié existe
    local giveaway = giveaways[title]
    if not giveaway then
        print(Rewards.getTranslation("err9"))
        return
    end
    if giveaway.winner ~= "" then
        ply:ChatPrint(Rewards.getTranslation("err10"))
        return
    end
    if giveaway.requirement ~= "None" then
        if not checkRewards(ply, giveaway.requirement) then
            ply:ChatPrint(Rewards.getTranslation("err27"))
            return
        end
    end

    -- Initialiser la liste des participants si elle n'existe pas
    if not giveaway.players then
        giveaway.players = {}
    end

    -- Vérifier si le joueur est déjà dans la liste des participants
    for _, steamID in ipairs(giveaway.players) do
        if steamID == ply:SteamID() then
            ply:ChatPrint(Rewards.getTranslation("err11"))
            return
        end
    end

    -- Ajouter le SteamID du joueur à la liste des participants
    table.insert(giveaway.players, ply:SteamID())

    -- Mettre à jour le fichier JSON avec le nouveau joueur
    file.Write(filePath, util.TableToJSON(giveawaysData, true))

    ply:ChatPrint(Rewards.getTranslation("err12") .. title .. Rewards.getTranslation("err13"))
end)

concommand.Add("rand_giveaway", function(ply, cmd, args)
    local filePath = "rewards/giveaways.json"

    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        print(Rewards.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: rand_giveaway <title>")
        return
    end

    local title = args[1]

    -- Vérifier si le fichier de giveaways existe
    if not file.Exists(filePath, "DATA") then
        print(Rewards.getTranslation("err14"))
        return
    end

    -- Charger les giveaways depuis le fichier JSON
    local fileContent = file.Read(filePath, "DATA")
    local giveawaysData = util.JSONToTable(fileContent) or {}

    -- Vérifier si le giveaway spécifié existe
    local giveaway = giveawaysData.giveaways[title]
    if not giveaway then
        print(Rewards.getTranslation("err15"))
        return
    end

    -- Vérifier si le giveaway a des participants
    if not giveaway.players or #giveaway.players == 0 then
        ply:ChatPrint(Rewards.getTranslation("err16"))
        return
    end

    -- Tirer au sort un joueur parmi les participants
    local winnerIndex = math.random(1, #giveaway.players)
    local winnerSteamID = giveaway.players[winnerIndex]

    -- Ajouter le champ winner avec le Steam ID du joueur
    giveaway.winner = winnerSteamID

    -- Mettre à jour le fichier JSON avec le gagnant
    file.Write(filePath, util.TableToJSON(giveawaysData))

    Rewards.sendAnnounce(ply, Rewards.getTranslation("err17") .. title .. Rewards.getTranslation("err18") .. winnerSteamID)
end)

concommand.Add("hl_giveaway", function(ply, cmd, args)
    local filePath = "rewards/giveaways.json"

    -- Vérifier les permissions de l'administrateur
    if not IsValid(ply) or not Rewards.Config.AdminGroup[ply:GetUserGroup()] then
        print(Rewards.getTranslation("noperm"))
        return
    end

    -- Vérifier les arguments
    if #args < 1 then
        print("Usage: hl_giveaway <title>")
        return
    end

    local title = args[1]

    -- Vérifier si le fichier de giveaways existe
    if not file.Exists(filePath, "DATA") then
        print(Rewards.getTranslation("err14"))
        return
    end

    -- Charger les giveaways depuis le fichier JSON
    local fileContent = file.Read(filePath, "DATA")
    local giveawaysData = util.JSONToTable(fileContent) or {}

    -- Vérifier si le giveaway spécifié existe
    local giveaway = giveawaysData.giveaways[title]
    if not giveaway then
        print(Rewards.getTranslation("err15"))
        return
    end

    -- Mettre à jour le champ hl de tous les giveaways
    for k, v in pairs(giveawaysData.giveaways) do
        if k == title then
            v.hl = true
        else
            v.hl = false
        end
    end

    ply:ChatPrint("Giveaway '" .. title .. Rewards.getTranslation("err28"))

    -- Mettre à jour le fichier JSON avec le gagnant
    file.Write(filePath, util.TableToJSON(giveawaysData))
end)

    
end

