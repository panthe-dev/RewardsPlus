if CLIENT then
    local popupFrameOpen = false

    net.Receive("Rewards.AfficherAdminPopup", function()
        local Giveaways = net.ReadTable()

        if popupFrameOpen then
            return
        end

        popupFrameOpen = true

        local frame = vgui.Create("DFrame")
        frame:SetSize(600, 300) -- Augmenter la taille pour inclure l'en-tête
        frame:SetTitle("")
        frame:Center()
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

        -- Header "Panel Admin"
        local headerLabel = vgui.Create("DLabel", frame)
        headerLabel:SetPos(0, 0)
        headerLabel:SetSize(600, 30)
        headerLabel:SetText("Admin Panel")
        headerLabel:SetFont("Trebuchet24")
        headerLabel:SetContentAlignment(5) -- Centre le texte
        headerLabel:SetTextColor(Color(255, 255, 255))
        headerLabel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 153, 230, 255))
        end

        -- Settings Button
        local imageButton = vgui.Create("DImageButton", frame)
        imageButton:SetPos(10, 8)
        imageButton:SetSize(15, 15)
        imageButton:SetImage("settingslogo.png")
        imageButton.DoClick = function()
            popupFrameOpen = false
            frame:Close()
            net.Start("Rewards.RefreshPopUp")
            net.SendToServer()

        end

        -- Close Button
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetPos(570, 5)
        closeButton:SetSize(25, 20)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold")
        closeButton:SetTextColor(Color(255, 255, 255))
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 50, 50, 0))
        end
        closeButton.DoClick = function()
            frame:Close()
            popupFrameOpen = false
        end

        -- PropertySheet for Tabs
        local propertySheet = vgui.Create("DPropertySheet", frame)
        propertySheet:SetSize(590, 270)
        propertySheet:SetPos(5, 30)
        propertySheet.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 20, w, h - 20, Color(43, 51, 62, 255))
        end

        -- Tab "Check Player Rewards"
        local checkRewardsPanel = vgui.Create("DPanel", propertySheet)
        checkRewardsPanel:SetSize(590, 345) -- Ajuster la taille pour tenir compte de la hauteur des onglets
        checkRewardsPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end   

        -- Entry for SteamID in "Check Player Rewards"
        local steamIDEntry = vgui.Create("DTextEntry", checkRewardsPanel)
        steamIDEntry:SetPos(135, 75)
        steamIDEntry:SetSize(300, 30)
        steamIDEntry:SetText("")
        steamIDEntry:SetPlaceholderText(Rewards.getTranslation("adminPopUpText1"))
        steamIDEntry:SetFont("DermaDefault")

        -- Button "Check" in "Check Player Rewards"
        local checkButton = vgui.Create("DButton", checkRewardsPanel)
        checkButton:SetPos(235, 125)
        checkButton:SetSize(100, 30)
        checkButton:SetText(Rewards.getTranslation("adminButton"))
        checkButton:SetFont("DermaDefaultBold")
        checkButton:SetTextColor(Color(255, 255, 255))
        checkButton.DoClick = function()
            local steamID = steamIDEntry:GetValue()
            if steamID == "" then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("adminPopUpText2"))
                return
            end

            net.Start("Rewards.RequestPlayerRewards")
            net.WriteString(steamID)
            net.SendToServer()
        end
        checkButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 200))
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 255))
            end
        end

        -- Tab "Create Giveaway"
        local createGiveawayPanel = vgui.Create("DPanel", propertySheet)
        createGiveawayPanel:SetSize(590, 345)
        createGiveawayPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

        -- Label for giveaway title
        local titleLabel = vgui.Create("DLabel", createGiveawayPanel)
        titleLabel:SetPos(50, 10)
        titleLabel:SetSize(300, 30)
        titleLabel:SetText(Rewards.getTranslation("descAdmin1"))
        titleLabel:SetTextColor(Color(255, 255, 255))

        -- Entry for titre
        local titleEntry = vgui.Create("DTextEntry", createGiveawayPanel)
        titleEntry:SetPos(150, 10)
        titleEntry:SetSize(300, 30)
        titleEntry:SetText("")
        titleEntry:SetPlaceholderText(Rewards.getTranslation("descAdmin2"))

        -- Label for reward type
        local rewardTypeLabel = vgui.Create("DLabel", createGiveawayPanel)
        rewardTypeLabel:SetPos(50, 90)
        rewardTypeLabel:SetSize(300, 30)
        rewardTypeLabel:SetText(Rewards.getTranslation("descAdmin3"))
        rewardTypeLabel:SetTextColor(Color(255, 255, 255))

        -- Scroll menu for reward type
        local rewardTypeCombo = vgui.Create("DComboBox", createGiveawayPanel)
        rewardTypeCombo:SetPos(150, 90)
        rewardTypeCombo:SetSize(300, 30)
        rewardTypeCombo:SetValue(Rewards.getTranslation("descAdmin4"))
        rewardTypeCombo:AddChoice("DarkRP")
        rewardTypeCombo:AddChoice("aShop")
        rewardTypeCombo:AddChoice("SH Pointshop")
        rewardTypeCombo:AddChoice("giftcard")

        -- Scroll menu for requirement type
        local rewardReqCombo = vgui.Create("DComboBox", createGiveawayPanel)
        rewardReqCombo:SetPos(150, 50)
        rewardReqCombo:SetSize(300, 30)
        rewardReqCombo:SetValue(Rewards.getTranslation("descAdmin16"))
        rewardReqCombo:AddChoice("discord")
        rewardReqCombo:AddChoice("steam")
        rewardReqCombo:AddChoice("ref")
        rewardReqCombo:AddChoice("VIP")
        rewardReqCombo:AddChoice("None")

        -- Entry for amount or giftcard
        local rewardEntry = vgui.Create("DTextEntry", createGiveawayPanel)
        rewardEntry:SetPos(150, 130)
        rewardEntry:SetSize(300, 30)
        rewardEntry:SetText("")
        rewardEntry:SetVisible(false)

        -- Giftcard or Amount
        rewardTypeCombo.OnSelect = function(index, value, data)           
            if data == "Giftcard" then
                rewardEntry:SetVisible(true)
                rewardEntry:SetPlaceholderText(Rewards.getTranslation("descAdmin5"))
            else
                rewardEntry:SetVisible(true)
                rewardEntry:SetPlaceholderText(Rewards.getTranslation("descAdmin6"))
            end
        end

        -- Create Giveaway button
        local createButton = vgui.Create("DButton", createGiveawayPanel)
        createButton:SetPos(250, 180)
        createButton:SetSize(100, 30)
        createButton:SetText(Rewards.getTranslation("descAdmin7"))
        createButton:SetFont("DermaDefaultBold")
        createButton:SetTextColor(Color(255, 255, 255))
        createButton.DoClick = function()
            local title = titleEntry:GetValue()
            local rewardType = rewardTypeCombo:GetValue()
            local rewardDetails = rewardEntry:GetValue()
            local rewardReq = rewardReqCombo:GetValue()
            
            if title == "" then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("descAdmin8"))
                return
            end
            
            if rewardType == Rewards.getTranslation("descAdmin4") then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("descAdmin9"))
                return
            end
            
            if rewardDetails == "" then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("descAdmin10"))
                return
            end

            if rewardReq == "" then
                chat.AddText(Color(255, 0, 0), Rewards.getTranslation("descAdmin17"))
                return
            end

            RunConsoleCommand("set_giveaway", title, rewardType, rewardDetails, rewardReq)
            frame:Close()
            popupFrameOpen = false          
        end

        createButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 200))
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, Color(0, 153, 230, 255))
            end
        end

        -- Tab "Manage Giveaway"
        local manageGiveawayPanel = vgui.Create("DPanel", propertySheet)
        manageGiveawayPanel:SetSize(590, 270)
        manageGiveawayPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(49, 57, 68, 255))
        end

        -- Scroll bar Giveaway
        local giveawayScrollPanel = vgui.Create("DScrollPanel", manageGiveawayPanel)
        giveawayScrollPanel:Dock(FILL)
        CustomizeScrollBar(giveawayScrollPanel)

        -- Add giveaways in tab Giveaways
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

            local delButton = vgui.Create("DButton", giveawayPanel)
            delButton:SetText(Rewards.getTranslation("descAdmin12"))
            delButton:SetFont("DermaDefaultBold")
            delButton:SetTextColor(Color(255, 255, 255))
            delButton:SetSize(50, 30)
            delButton:SetPos(490, 25)
            delButton.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(204, 0, 0, 255))
            end

            delButton.DoClick = function()
                frame:Close()
                popupFrameOpen = false
                RunConsoleCommand("del_giveaway", giveaway.name)
            end

            local randButton = vgui.Create("DButton", giveawayPanel)
            randButton:SetText(Rewards.getTranslation("descAdmin13"))
            randButton:SetFont("DermaDefaultBold")
            randButton:SetTextColor(Color(255, 255, 255))
            randButton:SetSize(90, 30)
            randButton:SetPos(380, 25)
            randButton.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 153, 230, 255))
            end

            if giveaway.winner then
                randButton:SetEnabled(false)
                randButton.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(128, 128, 128, 255))
                end
            else
                randButton.DoClick = function()
                    frame:Close()
                    popupFrameOpen = false
                    RunConsoleCommand("rand_giveaway", giveaway.name)
                end
            end
            giveawayYPos = giveawayYPos + 90
        end

        -- Add tabs
        AddCustomSheet(propertySheet, Rewards.getTranslation("onglet3"), checkRewardsPanel, "icon16/user.png")
        AddCustomSheet(propertySheet, Rewards.getTranslation("onglet4"), createGiveawayPanel, "icon16/medal_gold_1.png")
        AddCustomSheet(propertySheet, Rewards.getTranslation("onglet5"), manageGiveawayPanel, "icon16/table_edit.png")     
    end)

    net.Receive("Rewards.SendPlayerRewards", function()
        local rewardsData = net.ReadTable()

        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 400)
        frame:SetTitle("")
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(49, 57, 68, 240))
            draw.RoundedBoxEx(10, 0, 0, w, 40, Color(0, 153, 230, 250), true, true, false, false)
            draw.SimpleText("Player Rewards", "DermaDefaultBold", w / 2, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold")
        closeButton:SetTextColor(Color(255, 255, 255))
        closeButton:SetSize(30, 30)
        closeButton:SetPos(frame:GetWide() - 40, 5)
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 50, 50, 0))
        end
        closeButton.DoClick = function()
            frame:Close()
        end

        local rewardsList = vgui.Create("DListView", frame)
        rewardsList:SetPos(10, 50)
        rewardsList:SetSize(480, 340)
        rewardsList:AddColumn("Reward Type"):SetWide(240)
        rewardsList:AddColumn("Value"):SetWide(240)

        for rewardType, value in pairs(rewardsData) do
            local line = rewardsList:AddLine(rewardType, value)
        end
    end)
end
