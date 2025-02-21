-- Fonction pour mélanger les participants
local function shuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- Fonction pour créer le panneau de roulette
local function createRoulettePanel(participants)
    if IsValid(rouletteFrame) then
        rouletteFrame:Remove()
    end

    local frameWidth, frameHeight = Rewards.AdapteResolution(800, 200)

    rouletteFrame = vgui.Create("DFrame")
    rouletteFrame:SetSize(frameWidth, frameHeight)
    rouletteFrame:SetTitle("")
    rouletteFrame:Center()
    rouletteFrame:MakePopup()

    local scrollPanel = vgui.Create("DPanel", rouletteFrame)
    scrollPanel:Dock(FILL)

    -- Ajouter le curseur (barre rouge) au rouletteFrame
    local cursor = vgui.Create("DPanel", rouletteFrame)
    cursor:SetSize(4, frameHeight)
    cursor:SetPos(frameWidth / 2, 0)
    cursor:SetBackgroundColor(Color(255, 0, 0, 255))  -- Couleur rouge

    local avatarSize = 100
    local numAvatars = math.ceil(frameWidth / avatarSize) + 1
    local totalParticipants = #participants

    -- Calcule le nombre de duplications nécessaires pour chaque participant
    local duplicationFactor = math.ceil(numAvatars / totalParticipants)

    local duplicatedParticipants = {}

    for i = 1, duplicationFactor do
        for _, steamID in ipairs(participants) do
            table.insert(duplicatedParticipants, steamID)
        end
    end

    -- Limite le nombre de participants dupliqués pour qu'il corresponde au nombre nécessaire
    while #duplicatedParticipants > numAvatars do
        table.remove(duplicatedParticipants)
    end

    duplicatedParticipants = shuffleTable(duplicatedParticipants)

    local totalWidth = 0

    for i, steamID in ipairs(duplicatedParticipants) do
        local avatar = vgui.Create("AvatarImage", scrollPanel)
        avatar:SetSize(avatarSize, avatarSize)
        avatar:SetSteamID(steamID, 64)
        avatar:SetPos(totalWidth, 0)
        totalWidth = totalWidth + avatarSize
    end

    return scrollPanel, duplicatedParticipants
end

local function startRoulette(scrollPanel, participants, winnerSteamID)
    local speed = 2000    -- Vitesse initiale
    local deceleration = 500  -- Décélération
    local minSpeed = 10  -- Vitesse minimale avant l'arrêt

    local avatarSize = 100
    local winnerIndex = table.KeyFromValue(participants, winnerSteamID)
    local frameWidth = scrollPanel:GetWide()
    local halfFrameWidth = frameWidth / 2
    local targetX = (winnerIndex - 1) * avatarSize - halfFrameWidth + (avatarSize / 2)
    print(targetX)

    local totalWidth = #participants * avatarSize -- Largeur totale des images
    local currentOffset = 0  -- Position actuelle du défilement

    local function moveChildren()
        currentOffset = currentOffset + speed * FrameTime()  -- Déplacement vers la droite

        -- Récupérer la position réelle (en boucle)
        local realOffset = currentOffset % totalWidth

        -- Mettre à jour la position des enfants
        for i, child in ipairs(scrollPanel:GetChildren()) do
            local newPos = realOffset - (i - 1) * avatarSize
            if newPos > scrollPanel:GetWide() then
                newPos = newPos - totalWidth
            elseif newPos < -avatarSize then
                newPos = newPos + totalWidth
            end
            child:SetPos(newPos, 0)
        end

        -- Ralentissement progressif
        if speed > minSpeed then
            speed = speed - deceleration * FrameTime()
        else
            -- Arrêter la roulette précisément sur le gagnant
                 
            local distance = math.abs(realOffset - (targetX % totalWidth))
            print(distance)
           
            if distance < 10 then -- Si la distance est petite, arrêter
                return true
            end
            speed = math.max(speed - deceleration * FrameTime(), 100) -- Ralentir considérablement pour le dernier ajustement
        end

        return false
    end

    scrollPanel.Think = function(self)
        if moveChildren() then
            self.Think = nil -- Arrêter le Think une fois terminé
        end
    end
end


concommand.Add("roulette", function()
    -- Définissez les participants et le gagnant aléatoire
    local participants = {
        "76561198079372232",
        "76561197966477898",
        "76561197966187231",
        "76561198079373232"
    }

    local winnerSteamID = participants[1]--participants[math.random(#participants)]

    -- Créez et démarrez la roulette
    local scrollPanel,shuffledParticipants  = createRoulettePanel(participants)
    startRoulette(scrollPanel, shuffledParticipants, winnerSteamID)
end)
