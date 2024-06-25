if CLIENT then
    local popupFrameOpen = false

    net.Receive("Rewards.openRef", function(len)
        if popupFrameOpen then
            return
        end

        popupFrameOpen = true

        -- Création de la fenêtre
        local popupFrame = vgui.Create("DFrame")
        popupFrame:SetSize(400, 180)
        popupFrame:SetTitle(Rewards.getTranslation("refPopUpTitle"))
        popupFrame:Center()
        popupFrame:SetVisible(true)
        popupFrame:SetDraggable(true)
        popupFrame:ShowCloseButton(false)  -- Désactiver le bouton de fermeture par défaut
        popupFrame:MakePopup()
        popupFrame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(49, 57, 68, 240))
            draw.RoundedBox(10, 0, 0, w, 30, Color(0, 153, 230, 250))
        end

        -- Bouton de fermeture personnalisé
        local closeButton = vgui.Create("DButton", popupFrame)
        closeButton:SetPos(370, 5)
        closeButton:SetSize(25, 20)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold")
        closeButton:SetTextColor(Color(255, 255, 255))
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 50, 50, 0))
        end
        closeButton.DoClick = function()
            popupFrame:Close()
            popupFrameOpen = false
        end

        -- Label d'instruction
        local instructionLabel = vgui.Create("DLabel", popupFrame)
        instructionLabel:SetPos(50, 40)
        instructionLabel:SetSize(300, 20)
        instructionLabel:SetText(Rewards.getTranslation("refPopUpText1"))
        instructionLabel:SetTextColor(Color(255, 255, 255))
        instructionLabel:SetFont("DermaDefaultBold")

        -- Champ de saisie pour le code de référence
        local refCodeEntry = vgui.Create("DTextEntry", popupFrame)
        refCodeEntry:SetPos(50, 70)
        refCodeEntry:SetSize(300, 30)
        refCodeEntry:SetText("")
        refCodeEntry:SetPlaceholderText(Rewards.getTranslation("refPopUpText2"))
        refCodeEntry:SetFont("DermaDefault")

        -- Bouton "OK"
        local okButton = vgui.Create("DButton", popupFrame)
        okButton:SetPos(150, 120)
        okButton:SetSize(100, 30)
        okButton:SetText("OK")
        okButton:SetFont("DermaDefaultBold")
        okButton:SetTextColor(Color(255, 255, 255))
        okButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 200))
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 255))
            end
        end

        okButton.DoClick = function()
            local refCode = refCodeEntry:GetValue()
            if refCode == "" then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("refPopUpText3"))
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
