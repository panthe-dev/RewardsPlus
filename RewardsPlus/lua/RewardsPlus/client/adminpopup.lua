if CLIENT then
    local popupFrameOpen = false

    local colBluesky = Color(0, 153, 230, 255)
    local colGrey = Color(49, 57, 68, 255)
    local colGrey2 = Color(49, 57, 68, 240)
    local colBlack = Color(43, 51, 62, 255)
    local colWhite = Color(255, 255, 255)
    local colWhite2 = Color(255, 255, 255, 255)
    local colInv = Color(200, 50, 50, 0)
    local colRed = Color(255, 0, 0,255)
    local colRed2 = Color(204, 0, 0, 200)
    local colOr = Color(128, 128, 128, 255)
    local colBluesky2 = Color(0, 153, 230, 250)
    local colBluesky3 = Color(0, 153, 230, 200)

    net.Receive("Rewards.AfficherAdminPopup", function()
        local Giveaways = {}
        local numGiveaways = net.ReadUInt(8)

        for i = 1, numGiveaways do
            local giveaway = {
                name = net.ReadString(),
                rewardtype = net.ReadString(),
                amount = net.ReadInt(32),
                hasJoined = net.ReadBool(),
                winner = net.ReadString(),
                redeem = net.ReadBool(),
                players = net.ReadInt(8),
                requirement = net.ReadString()
            }
            table.insert(Giveaways, giveaway)
        end
        local activeTab = net.ReadUInt(8) or 1
        local coorScroll = net.ReadUInt(16) or 1

        if popupFrameOpen then
            return
        end

        popupFrameOpen = true

        local frame = vgui.Create("DFrame")
        frame:SetSize(Rewards.AdapteResolution(600, 300)) -- Augmenter la taille pour inclure l'en-tête
        frame:SetTitle("")
        frame:Center()
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

        -- Header "Panel Admin"
        local headerLabel = vgui.Create("DLabel", frame)
        headerLabel:SetPos(Rewards.AdapteResolution(0, 0))
        headerLabel:SetSize(Rewards.AdapteResolution(600, 30))
        headerLabel:SetText("Admin Panel")
        headerLabel:SetFont("Trebuchet24_Adaptive")
        headerLabel:SetContentAlignment(5) -- Centre le texte
        headerLabel:SetTextColor(colWhite)
        headerLabel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colBluesky)
        end

        -- Settings Button
        local imageButton = vgui.Create("DImageButton", frame)
        imageButton:SetPos(Rewards.AdapteResolution(10, 8))
        imageButton:SetSize(Rewards.AdapteResolution(15, 15))
        imageButton:SetImage("settingslogo.png")
        imageButton.DoClick = function()
            popupFrameOpen = false
            frame:Close()
            net.Start("Rewards.RefreshPopUp")
            net.WriteUInt(1, 8)
            net.WriteUInt(1, 8)
            net.SendToServer()

        end

        -- Close Button
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetPos(Rewards.AdapteResolution(570, 5))
        closeButton:SetSize(Rewards.AdapteResolution(25, 20))
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold_Adaptive")
        closeButton:SetTextColor(colWhite)
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colInv)
        end
        closeButton.DoClick = function()
            frame:Close()
            popupFrameOpen = false
        end

        -- PropertySheet for Tabs
        local propertySheet = vgui.Create("DPropertySheet", frame)
        propertySheet:SetSize(Rewards.AdapteResolution(590, 270))
        propertySheet:SetPos(Rewards.AdapteResolution(5, 30))
        propertySheet.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 20, w, h - 20, colBlack)
        end


        -- Tab "Check Player Rewards"
        local checkRewardsPanel = vgui.Create("DPanel", propertySheet)
        checkRewardsPanel:SetSize(Rewards.AdapteResolution(590, 345)) -- Ajuster la taille pour tenir compte de la hauteur des onglets
        checkRewardsPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end   

        -- Entry for SteamID in "Check Player Rewards"
        local steamIDEntry = vgui.Create("DTextEntry", checkRewardsPanel)
        steamIDEntry:SetPos(Rewards.AdapteResolution(135, 75))
        steamIDEntry:SetSize(Rewards.AdapteResolution(300, 30))
        steamIDEntry:SetText("")
        steamIDEntry:SetPlaceholderText(Rewards.getTranslation("adminPopUpText1"))
        steamIDEntry:SetFont("DermaDefault_Adaptive")

        -- Button "Check" in "Check Player Rewards"
        local checkButton = vgui.Create("DButton", checkRewardsPanel)
        checkButton:SetPos(Rewards.AdapteResolution(235, 125))
        checkButton:SetSize(Rewards.AdapteResolution(100, 30))
        checkButton:SetText(Rewards.getTranslation("adminButton"))
        checkButton:SetFont("DermaDefaultBold_Adaptive")
        checkButton:SetTextColor(colWhite)
        checkButton.DoClick = function()
            local steamID = steamIDEntry:GetValue()
            if steamID == "" then
                chat.AddText(colRed, Rewards.getTranslation("adminPopUpText2"))
                return
            end
            net.Start("Rewards.RequestPlayerRewards")
            net.WriteString(steamID)
            net.SendToServer()
        end
        checkButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, colBluesky3)
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, colBluesky)
            end
        end

        -- Tab "Create Giveaway"
        local createGiveawayPanel = vgui.Create("DPanel", propertySheet)
        createGiveawayPanel:SetSize(Rewards.AdapteResolution(590, 345))
        createGiveawayPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

        -- Label for giveaway title
        local titleLabel = vgui.Create("DLabel", createGiveawayPanel)
        titleLabel:SetPos(Rewards.AdapteResolution(50, 10))
        titleLabel:SetSize(Rewards.AdapteResolution(300, 30))
        titleLabel:SetText(Rewards.getTranslation("descAdmin1"))
        titleLabel:SetTextColor(colWhite)

        -- Entry for titre
        local titleEntry = vgui.Create("DTextEntry", createGiveawayPanel)
        titleEntry:SetPos(Rewards.AdapteResolution(150, 10))
        titleEntry:SetSize(Rewards.AdapteResolution(300, 30))
        titleEntry:SetText("")
        titleEntry:SetPlaceholderText(Rewards.getTranslation("descAdmin2"))

        -- Label for reward type
        local rewardTypeLabel = vgui.Create("DLabel", createGiveawayPanel)
        rewardTypeLabel:SetPos(Rewards.AdapteResolution(50, 90))
        rewardTypeLabel:SetSize(Rewards.AdapteResolution(300, 30))
        rewardTypeLabel:SetText(Rewards.getTranslation("descAdmin3"))
        rewardTypeLabel:SetTextColor(colWhite)

        -- Scroll menu for reward type
        local rewardTypeCombo = vgui.Create("DComboBox", createGiveawayPanel)
        rewardTypeCombo:SetPos(Rewards.AdapteResolution(150, 90))
        rewardTypeCombo:SetSize(Rewards.AdapteResolution(300, 30))
        rewardTypeCombo:SetValue(Rewards.getTranslation("descAdmin4"))
        rewardTypeCombo:AddChoice("DarkRP")
        rewardTypeCombo:AddChoice("aShop")
        rewardTypeCombo:AddChoice("PS1")
        rewardTypeCombo:AddChoice("PS2")
        rewardTypeCombo:AddChoice("PS2 Premium")
        rewardTypeCombo:AddChoice("giftcard")

        -- Scroll menu for requirement type
        local rewardReqCombo = vgui.Create("DComboBox", createGiveawayPanel)
        rewardReqCombo:SetPos(Rewards.AdapteResolution(150, 50))
        rewardReqCombo:SetSize(Rewards.AdapteResolution(300, 30))
        rewardReqCombo:SetValue(Rewards.getTranslation("descAdmin16"))
        rewardReqCombo:AddChoice("discord")
        rewardReqCombo:AddChoice("steam")
        rewardReqCombo:AddChoice("ref")
        rewardReqCombo:AddChoice("VIP")
        rewardReqCombo:AddChoice("None")

        -- Entry for amount or giftcard
        local rewardEntry = vgui.Create("DTextEntry", createGiveawayPanel)
        rewardEntry:SetPos(Rewards.AdapteResolution(150, 130))
        rewardEntry:SetSize(Rewards.AdapteResolution(300, 30))
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
        createButton:SetPos(Rewards.AdapteResolution(250, 180))
        createButton:SetSize(Rewards.AdapteResolution(100, 30))
        createButton:SetText(Rewards.getTranslation("descAdmin7"))
        createButton:SetFont("DermaDefaultBold_Adaptive")
        createButton:SetTextColor(colWhite)
        createButton.DoClick = function()
            local title = titleEntry:GetValue()
            local rewardType = rewardTypeCombo:GetValue()
            local rewardDetails = rewardEntry:GetValue()
            local rewardReq = rewardReqCombo:GetValue()
            local activeTab = Rewards.getActiveTabIndex(propertySheet)
            
            
            if title == "" then
                chat.AddText(colRed, Rewards.getTranslation("descAdmin8"))
                return
            end
            
            if rewardType == Rewards.getTranslation("descAdmin4") then
                chat.AddText(colRed, Rewards.getTranslation("descAdmin9"))
                return
            end
            
            if rewardDetails == "" then
                chat.AddText(colRed, Rewards.getTranslation("descAdmin10"))
                return
            end

            if rewardReq == "" then
                chat.AddText(colRed, Rewards.getTranslation("descAdmin17"))
                return
            end

            RunConsoleCommand("set_giveaway", title, rewardType, rewardDetails, rewardReq)
            timer.Simple(0.3, function()    
                net.Start("Rewards.RefreshAdminPopUp")
                net.WriteUInt(activeTab, 8)
                net.SendToServer()
            end)
            timer.Simple(1, function() frame:Close()end) 
            popupFrameOpen = false              
        end

        createButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, colBluesky3)
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, colBluesky)
            end
        end

        -- Tab "Manage Giveaway"
        local manageGiveawayPanel = vgui.Create("DPanel", propertySheet)
        manageGiveawayPanel:SetSize(Rewards.AdapteResolution(590, 270))
        manageGiveawayPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

        -- Scroll bar Giveaway
        local giveawayScrollPanel = vgui.Create("DScrollPanel", manageGiveawayPanel)
        giveawayScrollPanel:Dock(FILL)
        Rewards.CustomizeScrollBar(giveawayScrollPanel)

        -- Add giveaways in tab Giveaways
        local giveawayYPos = 10
        for _, giveaway in ipairs(Giveaways) do
            local giveawayPanel = vgui.Create("DPanel", giveawayScrollPanel)
            giveawayPanel:SetPos(Rewards.AdapteResolution(10, giveawayYPos))
            giveawayPanel:SetSize(Rewards.AdapteResolution(555, 80))
            giveawayPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, colBlack)
            end

            local giveawayImage = vgui.Create("DImage", giveawayPanel)
            giveawayImage:SetPos(Rewards.AdapteResolution(5, 5))
            giveawayImage:SetSize(Rewards.AdapteResolution(70, 70))
            if giveaway.rewardtype == "DarkRP" then
                giveawayImage:SetImage("moneylogo.png")
            elseif giveaway.rewardtype == "giftcard" then
                giveawayImage:SetImage("giftcardlogo.png")
            else 
                giveawayImage:SetImage("coinlogo.png")
            end

            local giveawayNameLabel = vgui.Create("DLabel", giveawayPanel)
            giveawayNameLabel:SetText(giveaway.name .. " | " .. giveaway.rewardtype)
            giveawayNameLabel:SetFont("Trebuchet18_Adaptive")
            giveawayNameLabel:SetTextColor(colWhite)
            giveawayNameLabel:SizeToContents()
            giveawayNameLabel:SetPos(Rewards.AdapteResolution(100, 10))

            local participantCount = giveaway.players
            local participantCountLabel = vgui.Create("DLabel", giveawayPanel)
            participantCountLabel:SetText(Rewards.getTranslation("descAdmin31") .. participantCount)
            participantCountLabel:SetFont("Trebuchet18_Adaptive")
            participantCountLabel:SetTextColor(colWhite)
            participantCountLabel:SizeToContents()
            participantCountLabel:SetPos(Rewards.AdapteResolution(100, 30))

            local reqlabel = vgui.Create("DLabel", giveawayPanel)
            reqlabel:SetText(Rewards.getTranslation("descAdmin18") .. giveaway.requirement)
            reqlabel:SetFont("Trebuchet18_Adaptive")
            reqlabel:SetTextColor(colWhite)
            reqlabel:SizeToContents()
            reqlabel:SetPos(Rewards.AdapteResolution(100, 50))

            if giveaway.winner ~= "" then
                local giveawayWinnerLabel = vgui.Create("DLabel", giveawayPanel)
                giveawayWinnerLabel:SetText(Rewards.getTranslation("descAdmin11")..giveaway.winner)
                giveawayWinnerLabel:SetFont("Trebuchet18_Adaptive")
                giveawayWinnerLabel:SetTextColor(colWhite)
                giveawayWinnerLabel:SizeToContents()
                giveawayWinnerLabel:SetPos(Rewards.AdapteResolution(390, 2))
            end

            local highlightButton = vgui.Create("DImageButton", giveawayPanel)
            highlightButton:SetPos(Rewards.AdapteResolution(350, 32))
            highlightButton:SetSize(Rewards.AdapteResolution(16, 16))
            highlightButton:SetImage("icon16/star.png")
            highlightButton.DoClick = function()
                local activeTab = Rewards.getActiveTabIndex(propertySheet)
                local coorScroll = giveawayScrollPanel:GetVBar():GetScroll()

                RunConsoleCommand("hl_giveaway", giveaway.name)

                timer.Simple(0.3, function()    
                    net.Start("Rewards.RefreshAdminPopUp")
                    net.WriteUInt(activeTab, 8)
                    net.WriteUInt(coorScroll, 16)
                    net.SendToServer()
                end)
                timer.Simple(1, function() frame:Close()end) 
                popupFrameOpen = false

            end

            local delButton = vgui.Create("DButton", giveawayPanel)
            delButton:SetText(Rewards.getTranslation("descAdmin12"))
            delButton:SetFont("DermaDefaultBold_Adaptive")
            delButton:SetTextColor(colWhite)
            delButton:SetSize(Rewards.AdapteResolution(50, 30))
            delButton:SetPos(Rewards.AdapteResolution(490, 25))
            delButton.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, colRed2)
                if self:IsHovered() then
                    draw.RoundedBox(5, 0, 0, w, h, colRed)
                end
            end

            delButton.DoClick = function()
                local activeTab = Rewards.getActiveTabIndex(propertySheet)
                local coorScroll = giveawayScrollPanel:GetVBar():GetScroll()

                RunConsoleCommand("del_giveaway", giveaway.name)
                timer.Simple(0.3, function()    
                    net.Start("Rewards.RefreshAdminPopUp")
                    net.WriteUInt(activeTab, 8)
                    net.WriteUInt(coorScroll, 16)
                    net.SendToServer()
                end)
                timer.Simple(1, function() frame:Close()end) 
                popupFrameOpen = false    
            end

            local randButton = vgui.Create("DButton", giveawayPanel)
            randButton:SetText(Rewards.getTranslation("descAdmin13"))
            randButton:SetFont("DermaDefaultBold_Adaptive")
            randButton:SetTextColor(colWhite)
            randButton:SetSize(Rewards.AdapteResolution(90, 30))
            randButton:SetPos(Rewards.AdapteResolution(380, 25))
            randButton.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, colBluesky3)
                if self:IsHovered() then
                    draw.RoundedBox(5, 0, 0, w, h, colBluesky)
                end
            end

            if giveaway.winner ~= "" then
                randButton:SetEnabled(false)
                randButton.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, colOr)
                end
            else
                randButton.DoClick = function()
                    local activeTab = Rewards.getActiveTabIndex(propertySheet)
                    local coorScroll = giveawayScrollPanel:GetVBar():GetScroll()

                    RunConsoleCommand("rand_giveaway", giveaway.name)
                    timer.Simple(0.3, function()    
                        net.Start("Rewards.RefreshAdminPopUp")
                        net.WriteUInt(activeTab, 8)
                        net.WriteUInt(coorScroll, 16)
                        net.SendToServer()
                    end)
                    timer.Simple(1, function() frame:Close()end) 
                    popupFrameOpen = false    
                    
                end
            end
            giveawayYPos = giveawayYPos + 90
        end

        -- Add tabs
        Rewards.AddCustomSheet(propertySheet, Rewards.getTranslation("onglet3"), checkRewardsPanel, "icon16/user.png")
        Rewards.AddCustomSheet(propertySheet, Rewards.getTranslation("onglet4"), createGiveawayPanel, "icon16/medal_gold_1.png")
        Rewards.AddCustomSheet(propertySheet, Rewards.getTranslation("onglet5"), manageGiveawayPanel, "icon16/table_edit.png")

        if activeTab then
            propertySheet:SetActiveTab(propertySheet:GetItems()[activeTab].Tab )
        end
        if coorScroll then
            giveawayScrollPanel:GetVBar():AnimateTo( coorScroll,0,0,-1 )                  
        end 

    end)

    net.Receive("Rewards.SendPlayerRewards", function()
        local rewardsData = {}
        rewardsData["Discord Reward"] = net.ReadString()
        rewardsData["Steam Reward"] = net.ReadString()
        rewardsData["Playtime Reward"] = net.ReadString()
        rewardsData["Referral Reward"] = net.ReadString()


        local frame = vgui.Create("DFrame")
        frame:SetSize(Rewards.AdapteResolution(500, 400))
        frame:SetTitle("")
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, colGrey2)
            draw.RoundedBoxEx(10, 0, 0, w, 40, colBluesky2, true, true, false, false)
            draw.SimpleText("Player Rewards", "DermaDefaultBold_Adaptive", w / 2, 20, colWhite2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold_Adaptive")
        closeButton:SetTextColor(colWhite)
        closeButton:SetSize(Rewards.AdapteResolution(30, 30))
        closeButton:SetPos(Rewards.AdapteResolution(frame:GetWide() - 40, 5))
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colInv)
        end
        closeButton.DoClick = function()
            frame:Close()
        end

        local rewardsList = vgui.Create("DListView", frame)
        rewardsList:SetPos(Rewards.AdapteResolution(10, 50))
        rewardsList:SetSize(Rewards.AdapteResolution(480, 340))
        rewardsList:AddColumn("Reward Type"):SetWide(240)
        rewardsList:AddColumn("Value"):SetWide(240)

        for rewardType, value in pairs(rewardsData) do
            local line = rewardsList:AddLine(rewardType, value)
        end
    end)
end
