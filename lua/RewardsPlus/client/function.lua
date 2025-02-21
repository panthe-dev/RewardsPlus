 local colWhite = Color(255, 255, 255)
 local colBlueSky = Color(0, 153, 230, 255)
 local colBlack = Color(43, 51, 62, 255)
 local colBlack2 = Color(0, 0, 0, 200)
 local colBlack3 = Color(255, 255, 255, 50)

 local function CustomizeTab(tab)
    tab:SetTextColor(colWhite)
    tab.Paint = function(self, w, h)
        if self:IsActive() then
            draw.RoundedBox(8, 0, 0, w, h, colBlueSky)
        else
            draw.RoundedBox(8, 0, 0, w, h, colBlack)
        end
    end
end

function RewardsPlus.getActiveTabIndex(propertySheet)
    for index, sheet in ipairs(propertySheet.Items) do
        if sheet.Tab == propertySheet:GetActiveTab() then
            return index
        end
    end
    return 1 -- par défaut à 1 si aucun onglet n'est actif
end

-- Fonction pour ajouter des onglets avec personnalisation
function RewardsPlus.AddCustomSheet(sheet, label, panel, icon)
    local tab = sheet:AddSheet(label, panel, icon)
    CustomizeTab(tab.Tab)
    return tab
end

 function RewardsPlus.CustomizeScrollBar(scrollPanel)
    local vScrollBar = scrollPanel:GetVBar()

    vScrollBar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colBlack2) -- Fond noir transparent
    end

    vScrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colBlack3) -- Bouton de saisie noir transparent
    end

    vScrollBar:SetWide(5) -- Définir une largeur plus fine pour la barre de défilement
end

function RewardsPlus.AdapteResolution(value, value2)
    -- Résolution de référence
    local refWidth, refHeight = 1920, 1080
    local screenWidth, screenHeight = ScrW(), ScrH()

    return (screenWidth / refWidth) * value, (screenHeight / refHeight) * value2
end

function RewardsPlus.AdapteFontSize(fontSize)
    local refHeight = 1080
    local screenHeight = ScrH()
    local adaptedFontSize = (screenHeight / refHeight) * fontSize
    return math.max(8, adaptedFontSize)  
end

surface.CreateFont("Trebuchet18_Adaptive", {
    font = "Trebuchet MS",
    size = RewardsPlus.AdapteFontSize(18),
    weight = 500,
    antialias = true,
})

surface.CreateFont("Trebuchet24_Adaptive", {
    font = "Trebuchet MS",
    size = RewardsPlus.AdapteFontSize(24),
    weight = 500,
    antialias = true,
})

surface.CreateFont("Trebuchet30_Adaptive", {
    font = "Trebuchet MS",
    size = RewardsPlus.AdapteFontSize(30),
    weight = 800,
    antialias = true,
})


surface.CreateFont("DermaDefaultBold_Adaptive", {
    font = "DermaDefaultBold",
    size = RewardsPlus.AdapteFontSize(15),
    weight = 800,
    antialias = true,
})

surface.CreateFont("DermaDefault_Adaptive", {
    font = "DermaDefault",
    size = RewardsPlus.AdapteFontSize(14),
    weight = 500,
    antialias = true,
})

