if CLIENT then
    local popupFrameOpen = false

    local colBluesky = Color(0, 153, 230, 255)
    local colBluesky2 = Color(0, 153, 230, 250)
    local colBluesky3 = Color(0, 153, 230, 200)
    local colGrey = Color(49, 57, 68, 240)
    local colRed = Color(255, 0, 0)
    local colWhite = Color(255, 255, 255)
    local colInv = Color(200, 50, 50, 0)

    net.Receive("Rewards.openRef", function(len)
        if popupFrameOpen then
            return
        end

        popupFrameOpen = true

        -- Création de la fenêtre
        local popupFrame = vgui.Create("DFrame")
        popupFrame:SetSize(RewardsPlus.AdapteResolution(400, 180))
        popupFrame:SetTitle(RewardsPlus.getTranslation("refPopUpTitle"))
        popupFrame:Center()
        popupFrame:SetVisible(true)
        popupFrame:SetDraggable(true)
        popupFrame:ShowCloseButton(false)  -- Désactiver le bouton de fermeture par défaut
        popupFrame:MakePopup()
        popupFrame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, colGrey)
            draw.RoundedBox(10, 0, 0, w, 30, colBluesky2)
        end

        -- Bouton de fermeture personnalisé
        local closeButton = vgui.Create("DButton", popupFrame)
        closeButton:SetPos(RewardsPlus.AdapteResolution(370, 5))
        closeButton:SetSize(RewardsPlus.AdapteResolution(25, 20))
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold_Adaptive")
        closeButton:SetTextColor(colWhite)
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colInv)
        end
        closeButton.DoClick = function()
            popupFrame:Close()
            popupFrameOpen = false
        end

        -- Label d'instruction
        local instructionLabel = vgui.Create("DLabel", popupFrame)
        instructionLabel:SetPos(RewardsPlus.AdapteResolution(50, 40))
        instructionLabel:SetSize(RewardsPlus.AdapteResolution(300, 20))
        instructionLabel:SetText(RewardsPlus.getTranslation("refPopUpText1"))
        instructionLabel:SetTextColor(colWhite)
        instructionLabel:SetFont("DermaDefaultBold_Adaptive")

        -- Champ de saisie pour le code de référence
        local refCodeEntry = vgui.Create("DTextEntry", popupFrame)
        refCodeEntry:SetPos(RewardsPlus.AdapteResolution(50, 70))
        refCodeEntry:SetSize(RewardsPlus.AdapteResolution(300, 30))
        refCodeEntry:SetText("")
        refCodeEntry:SetPlaceholderText(RewardsPlus.getTranslation("refPopUpText2"))
        refCodeEntry:SetFont("DermaDefault_Adaptive")

        -- Bouton "OK"
        local okButton = vgui.Create("DButton", popupFrame)
        okButton:SetPos(RewardsPlus.AdapteResolution(150, 120))
        okButton:SetSize(RewardsPlus.AdapteResolution(100, 30))
        okButton:SetText("OK")
        okButton:SetFont("DermaDefaultBold_Adaptive")
        okButton:SetTextColor(colWhite)
        okButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, colBluesky3)
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, colBluesky)
            end
        end

        okButton.DoClick = function()
            local refCode = refCodeEntry:GetValue()
            if refCode == "" then
                chat.AddText(colRed, RewardsPlus.getTranslation("refPopUpText3"))
                return
            end

            net.Start("Rewards.submitRefCode")
            net.WriteString(refCode)
            net.SendToServer()

            popupFrame:Close()
            popupFrameOpen = false
        end

        -- Fermer la popup si le bouton de fermeture est cliqué
        popupFrame.OnClose = function()
            popupFrameOpen = false
        end
    end)
end
