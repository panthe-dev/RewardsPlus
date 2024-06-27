 local function CustomizeTab(tab)
    tab:SetTextColor(Color(255, 255, 255))
    tab.Paint = function(self, w, h)
        if self:IsActive() then
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 153, 230, 255))
        else
            draw.RoundedBox(8, 0, 0, w, h, Color(43, 51, 62, 255))
        end
    end
end

-- Fonction pour ajouter des onglets avec personnalisation
function Rewards.AddCustomSheet(sheet, label, panel, icon)
    local tab = sheet:AddSheet(label, panel, icon)
    CustomizeTab(tab.Tab)
    return tab
end

 function Rewards.CustomizeScrollBar(scrollPanel)
    local vScrollBar = scrollPanel:GetVBar()

    vScrollBar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200)) -- Fond noir transparent
    end

    vScrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 50)) -- Bouton de saisie noir transparent
    end

    vScrollBar:SetWide(5) -- Définir une largeur plus fine pour la barre de défilement
end


