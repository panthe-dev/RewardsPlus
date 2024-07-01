local function shuffleTable(t)
    local shuffled = {}
    for i = #t, 1, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
        table.insert(shuffled, t[i])
    end
    return shuffled
end


-- Fonction pour créer le panneau de roulette
local function createRoulettePanel(participants)
    if IsValid(rouletteFrame) then
        rouletteFrame:Remove()
    end

    rouletteFrame = vgui.Create("DFrame")
    rouletteFrame:SetSize(800, 200)
    rouletteFrame:SetTitle("")
    rouletteFrame:Center()
    rouletteFrame:MakePopup()

    local scrollPanel = vgui.Create("DPanel", rouletteFrame)
    scrollPanel:Dock(FILL)

    local duplicatedParticipants = {}
    for _, steamID in ipairs(participants) do
        for i = 1, #participants do -- Ajoutez chaque participant 4 fois
            table.insert(duplicatedParticipants, steamID)
        end
    end

    duplicatedParticipants = shuffleTable(duplicatedParticipants)

    local totalWidth = 0

    for i, steamID in ipairs(duplicatedParticipants) do
        local avatar = vgui.Create("AvatarImage", scrollPanel)
        avatar:SetSize(100, 100)
        avatar:SetSteamID(steamID, 64)
        avatar:SetPos(totalWidth, 0)
        totalWidth = totalWidth + 100 -- 100 + 20 pour l'espacement
    end



    return scrollPanel, duplicatedParticipants
end

-- Fonction de défilement avec ralentissement
local function startRoulette(scrollPanel, participants, winnerSteamID)
    local speed = 2000    -- Vitesse initiale
    local deceleration = 100  -- Décélération
    local minSpeed = 50  -- Vitesse minimale avant l'arrêt

    local winnerIndex = table.KeyFromValue(participants, winnerSteamID)
    local targetX = -(winnerIndex - 1) * 100 -- 100 (taille de l'image) + 20 (espacement)

    local offsetX = 0

    local function moveChildren()
        offsetX = offsetX + speed * FrameTime()

        -- Vérifier si un enfant est complètement sorti de l'écran
        for _, child in ipairs(scrollPanel:GetChildren()) do
            local x, y = child:GetPos()
            x = x + speed * FrameTime()  -- Déplacement vers la droite
            if x > scrollPanel:GetWide() then
                x = x - scrollPanel:GetWide() - 100 -- Remet à gauche après avoir passé la largeur
            end
            child:SetPos(x, y)
        end

        -- Ralentissement progressif
        if speed > minSpeed then
            speed = speed - deceleration * FrameTime()
        else

            
        end

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

    local winnerSteamID = participants[math.random(#participants)]

    -- Créez et démarrez la roulette
    local scrollPanel,shuffledParticipants  = createRoulettePanel(participants)
    startRoulette(scrollPanel, shuffledParticipants, winnerSteamID)
end)
