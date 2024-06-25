if CLIENT then
    
    local popupFrameOpen = false

    net.Receive("Rewards.AfficherPopup", function(len, ply)
        local Giveaways = net.ReadTable()
        local Tasks = net.ReadTable()   
        local checkData = net.ReadTable()
        local steamid = net.ReadString()

        if(popupFrameOpen) then -- prevent from opening multiple menus
            return
        end

        popupFrameOpen = true

        -- Window
        local popupFrame = vgui.Create("DFrame")
        popupFrame:SetSize(600, 300)
        popupFrame:SetTitle("")
        popupFrame:Center()
        popupFrame:SetVisible(true)
        popupFrame:SetDraggable(false)
        popupFrame:ShowCloseButton(false)
        popupFrame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

        local propertySheet = vgui.Create("DPropertySheet", popupFrame)
        propertySheet:SetSize(590, 270)
        propertySheet:SetPos(5, 30)
        propertySheet.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 20, w, h - 20, Color(43, 51, 62, 255))
        end

         -- task tab
        local taskWindow = vgui.Create("DPanel", propertySheet)
        taskWindow:SetSize(590, 270)
        taskWindow.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

         -- giveaway tab
        local giveawaysWindow = vgui.Create("DPanel", propertySheet)
        giveawaysWindow:SetSize(590, 270)
        giveawaysWindow.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

        -- tabs
        AddCustomSheet(propertySheet, Rewards.getTranslation("onglet1"), taskWindow, "icon16/star.png")       
        AddCustomSheet(propertySheet, Rewards.getTranslation("onglet2"), giveawaysWindow, "icon16/medal_gold_1.png")

        -- scroll bar

        local taskScrollPanel = vgui.Create("DScrollPanel", taskWindow)
        taskScrollPanel:Dock(FILL)

        local giveawayScrollPanel = vgui.Create("DScrollPanel", giveawaysWindow)
        giveawayScrollPanel:Dock(FILL)

        CustomizeScrollBar(taskScrollPanel)
        CustomizeScrollBar(giveawayScrollPanel)

        -- Header
        local titleLabel = vgui.Create("DLabel", popupFrame)
        titleLabel:SetText(Rewards.getTranslation("popUpTitle"))
        titleLabel:SetFont("Trebuchet24")
        titleLabel:SetContentAlignment(5)
        titleLabel:SetSize(600, 30)
        titleLabel:SetPos(0, 0)
        titleLabel:SetTextColor(Color(255, 255, 255))
        titleLabel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 153, 230, 255))
        end

        local imageButton = vgui.Create("DImageButton", popupFrame)
        imageButton:SetPos(10, 8)
        imageButton:SetSize(15, 15)
        imageButton:SetImage("settingslogo.png")
        imageButton.DoClick = function()
            popupFrameOpen = false
            popupFrame:Close()
            net.Start("Rewards.AdminPopup")
            net.SendToServer()

        end

        local closeButton = vgui.Create("DButton", popupFrame)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold")
        closeButton:SetSize(25, 20)
        closeButton:SetPos(570, 5)
        closeButton:SetTextColor(Color(255, 255, 255))
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 50, 50, 0))
        end
        closeButton.DoClick = function()
            popupFrame:Close()
            popupFrameOpen = false
        end

        local yPos = 10 -- Position Y initial 1st element

        for _, task in ipairs(Tasks) do
            local taskPanel = vgui.Create("DPanel", taskScrollPanel)
            taskPanel:SetPos(10, yPos)
            taskPanel:SetSize(550, 60)
            taskPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(43, 51, 62, 255))
            end

            local iconImage = vgui.Create("DImage", taskPanel)
            iconImage:SetPos(5, 5)
            iconImage:SetSize(50, 50)
            iconImage:SetImage(task.image)

            local actionDescriptionLabel = vgui.Create("DLabel", taskPanel)
            actionDescriptionLabel:SetText(task.description)
            actionDescriptionLabel:SetFont("Trebuchet18")
            actionDescriptionLabel:SizeToContents()

            local textWidth = actionDescriptionLabel:GetWide()
            local panelWidth = taskPanel:GetWide()
            local textPosX = (panelWidth - textWidth) / 2

            actionDescriptionLabel:SetPos(textPosX, 20)
            actionDescriptionLabel:SetTextColor(Color(255, 255, 255))

            -- Création du bouton "Redeem Reward"
            if (checkData.steam == 'true' and task.name == "Steam Group") or 
                (checkData.discord == 'true' and task.name == "Discord") or
                (checkData.ref == 'true' and task.name == "Referral Code")
             then

                local checkImage = vgui.Create("DImage", taskPanel)
                checkImage:SetPos(510, 15)
                checkImage:SetSize(30, 30)
                checkImage:SetImage("checklogo.png")

            elseif (checkData.daily and task.name == "Daily Reward") or 
                    (checkData.vip and task.name == "VIP Reward")
             then
                local timerImage = vgui.Create("DImage", taskPanel)
                timerImage:SetPos(510, 15)
                timerImage:SetSize(30, 30)
                timerImage:SetImage("timerlogo.png")
                
            else
                local redeemButton = vgui.Create("DButton", taskPanel)
                redeemButton:SetText("+")
                redeemButton:SetFont("DermaDefaultBold")
                redeemButton:SetTextColor(Color(255, 255, 255))
                redeemButton:SetSize(30, 30)
                redeemButton:SetPos(510, 15)
                redeemButton.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 153, 230, 255))
                end

                redeemButton.DoClick = function()
                    redeemButton:SetEnabled(false)
                    net.Start(task.action)
                    net.SendToServer()
                    timer.Simple(0.3, function()    
                        net.Start("Rewards.RefreshPopUp")
                        net.SendToServer()
                    end)
                    timer.Simple(1, function() popupFrame:Close()end) 
                    popupFrameOpen = false             
                end
            end
            yPos = yPos + 70 -- Augmenter la position Y pour le prochain élément
        end

        -- Ajouter le séparateur après la liste des tâches
        local separator = vgui.Create("DPanel", taskScrollPanel)
        separator:SetSize(600, 2)
        separator:SetPos(0, yPos + 10) -- Positionnez juste après la liste des tâches avec un espace de 10 pixels
        separator.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        end

        -- Création du label de référence en dessous du séparateur
        local refLabel = vgui.Create("DLabel", taskScrollPanel)
        refLabel:SetText(Rewards.getTranslation("refCodeTitle") .. checkData.refcode)
        refLabel:SetFont("Trebuchet24")
        refLabel:SetContentAlignment(5)
        refLabel:SetSize(600, 30)
        refLabel:SetPos(0, yPos + 30) -- Positionnez juste après le séparateur avec un espace supplémentaire de 20 pixels
        refLabel:SetTextColor(Color(255, 255, 255))

        -- Ajouter le séparateur après la liste des tâches
        local separator2 = vgui.Create("DPanel", taskScrollPanel)
        separator2:SetSize(600, 2)
        separator2:SetPos(0, yPos + 75) -- Positionnez juste après la liste des tâches avec un espace de 10 pixels
        separator2.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        end

        -- Ajout des giveaways dans l'onglet Giveaways
        local giveawayYPos = 10

        for _, giveaway in ipairs(Giveaways) do
            local giveawayPanel = vgui.Create("DPanel", giveawayScrollPanel)
            giveawayPanel:SetPos(10, giveawayYPos)
            giveawayPanel:SetSize(570, 80)
            giveawayPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(43, 51, 62, 255))
            end

            local giveawayImage = vgui.Create("DImage", giveawayPanel)
            giveawayImage:SetPos(5, 5)
            giveawayImage:SetSize(70, 70)
            if giveaway.rewardtype == "DarkRP" then
                giveawayImage:SetImage("moneylogo.png")
            elseif giveaway.rewardtype == "giftcard" then
                giveawayImage:SetImage("giftcardlogo.png")
            else 
                giveawayImage:SetImage("coinlogo.png")
            end

            local giveawayNameLabel = vgui.Create("DLabel", giveawayPanel)
            giveawayNameLabel:SetText(giveaway.name .. " | " .. giveaway.rewardtype)
            giveawayNameLabel:SetFont("Trebuchet18")
            giveawayNameLabel:SetTextColor(Color(255, 255, 255))
            giveawayNameLabel:SizeToContents()
            giveawayNameLabel:SetPos(100, 10)

            local participantCount = giveaway.players
            local participantCountLabel = vgui.Create("DLabel", giveawayPanel)
            participantCountLabel:SetText(Rewards.getTranslation("descAdmin31") .. participantCount)
            participantCountLabel:SetFont("Trebuchet18")
            participantCountLabel:SetTextColor(Color(255, 255, 255))
            participantCountLabel:SizeToContents()
            participantCountLabel:SetPos(100, 30)

            local reqlabel = vgui.Create("DLabel", giveawayPanel)
            reqlabel:SetText(Rewards.getTranslation("descAdmin18") .. giveaway.requirement)
            reqlabel:SetFont("Trebuchet18")
            reqlabel:SetTextColor(Color(255, 255, 255))
            reqlabel:SizeToContents()
            reqlabel:SetPos(100, 50)

            if giveaway.winner then
                local giveawayWinnerLabel = vgui.Create("DLabel", giveawayPanel)
                giveawayWinnerLabel:SetText(Rewards.getTranslation("descAdmin11")..giveaway.winner)
                giveawayWinnerLabel:SetFont("Trebuchet18")
                giveawayWinnerLabel:SetTextColor(Color(255, 255, 255))
                giveawayWinnerLabel:SizeToContents()
                giveawayWinnerLabel:SetPos(390, 2)
            end

            local joinButton = vgui.Create("DButton", giveawayPanel)
            joinButton:SetText(Rewards.getTranslation("descAdmin15"))
            joinButton:SetFont("DermaDefaultBold")
            joinButton:SetTextColor(Color(255, 255, 255))
            joinButton:SetSize(50, 30)
            joinButton:SetPos(490, 25)
            if giveaway.hasJoined or giveaway.winner then
                joinButton:SetDisabled(true)
            end
            joinButton.Paint = function(self, w, h)
                if joinButton:GetDisabled() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(169, 169, 169, 255)) -- Grey color for disabled button
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 153, 230, 255)) -- Original color for enabled button
                end
            end

            joinButton.DoClick = function()
                if not joinButton:GetDisabled() then
                    popupFrame:Close()
                    popupFrameOpen = false
                    RunConsoleCommand("join_giveaway", giveaway.name)
                end
            end

            if giveaway.winner == steamid then
                
                local redButton = vgui.Create("DButton", giveawayPanel)
                redButton:SetText(Rewards.getTranslation("descAdmin14"))
                redButton:SetFont("DermaDefaultBold")
                redButton:SetTextColor(Color(255, 255, 255))
                redButton:SetSize(70, 30)
                redButton:SetPos(400, 25)
                if giveaway.redeem then
                    redButton:SetDisabled(true)
                end
                redButton.Paint = function(self, w, h)
                if redButton:GetDisabled() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(169, 169, 169, 255)) -- Grey color for disabled button
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(204, 204, 0, 255)) -- Original color for enabled button
                end

                redButton.DoClick = function()
                if not redButton:GetDisabled() then
                    popupFrame:Close()
                    popupFrameOpen = false
                    net.Start("Rewards.redGiveaway")
                    net.WriteString(giveaway.name)
                    net.SendToServer()       
                end
            end
        end
    end
giveawayYPos = giveawayYPos + 90
end   
end)
end
