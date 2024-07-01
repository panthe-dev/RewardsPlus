if CLIENT then
    
    local popupFrameOpen = false

    local colBluesky = Color(0, 153, 230, 255)
    local colBluesky3 = Color(0, 153, 230, 200)
    local colGrey = Color(49, 57, 68, 255)
    local colBlack = Color(43, 51, 62, 255)
    local colWhite = Color(255, 255, 255)
    local lightGray = Color(169, 169, 169, 255)
    local colGold = Color(204, 204, 0, 255)
    local colGold2 = Color(204, 204, 0, 200)
    local colBlack2 = Color(0, 0, 0, 100)
    local colInv = Color(200, 50, 50, 0)

    net.Receive("Rewards.AfficherPopup", function(len, ply)

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

        local Tasks = {}
        local numTasks = net.ReadUInt(8)
        
        for i = 1, numTasks do
            local task = {
                action = net.ReadString(), 
                description = net.ReadString(),
                image = net.ReadString(),
                name = net.ReadString()
            }
            table.insert(Tasks, task)
        end
 
        local checkData = {
            daily = net.ReadBool(),
            discord = net.ReadBool(),
            ref = net.ReadString(),
            refcode = net.ReadString(),
            steam = net.ReadBool(),
            vip = net.ReadBool()
        }

        local steamid = net.ReadString()
        local activeTab = net.ReadUInt(8) or 1
        local coorScroll = net.ReadUInt(16) or 1

        if(popupFrameOpen) then -- prevent from opening multiple menus
            return
        end

        popupFrameOpen = true

        -- Window
        local popupFrame = vgui.Create("DFrame")
        popupFrame:SetSize(Rewards.AdapteResolution(600,300))
        popupFrame:SetTitle("")
        popupFrame:Center()
        popupFrame:SetVisible(true)
        popupFrame:SetDraggable(false)
        popupFrame:ShowCloseButton(false)
        popupFrame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

        local propertySheet = vgui.Create("DPropertySheet", popupFrame)
        propertySheet:SetSize(Rewards.AdapteResolution(590,270))
        propertySheet:SetPos(Rewards.AdapteResolution(5, 30))
        propertySheet.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 20, w, h - 20, colBlack)
        end

         -- task tab
        local taskWindow = vgui.Create("DPanel", propertySheet)
        taskWindow:SetSize(Rewards.AdapteResolution(590,270))
        taskWindow.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

         -- giveaway tab
        local giveawaysWindow = vgui.Create("DPanel", propertySheet)
        giveawaysWindow:SetSize(Rewards.AdapteResolution(590,270))
        giveawaysWindow.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colGrey)
        end

        -- tabs
        Rewards.AddCustomSheet(propertySheet, Rewards.getTranslation("onglet1"), taskWindow, "icon16/star.png")       
        Rewards.AddCustomSheet(propertySheet, Rewards.getTranslation("onglet2"), giveawaysWindow, "icon16/medal_gold_1.png")      

        -- scroll bar

        local taskScrollPanel = vgui.Create("DScrollPanel", taskWindow)
        taskScrollPanel:Dock(FILL)      

        local giveawayScrollPanel = vgui.Create("DScrollPanel", giveawaysWindow)
        giveawayScrollPanel:Dock(FILL)

        Rewards.CustomizeScrollBar(taskScrollPanel)
        Rewards.CustomizeScrollBar(giveawayScrollPanel)
        propertySheet:SetFadeTime(0)

        if activeTab then
            propertySheet:SetActiveTab(propertySheet:GetItems()[activeTab].Tab )
        end
        if coorScroll then
            if activeTab == 1 then
                taskScrollPanel:GetVBar():AnimateTo( coorScroll,0,0,-1 )
            else
                giveawayScrollPanel:GetVBar():AnimateTo( coorScroll,0,0,-1 )
            end         
        end 
        
        -- Header
        local titleLabel = vgui.Create("DLabel", popupFrame)
        titleLabel:SetText(Rewards.getTranslation("popUpTitle"))
        titleLabel:SetFont("Trebuchet24")
        titleLabel:SetContentAlignment(5)
        titleLabel:SetSize(Rewards.AdapteResolution(600,30))
        titleLabel:SetPos(Rewards.AdapteResolution(0, 0))
        titleLabel:SetTextColor(colWhite)
        titleLabel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colBluesky)
        end

        local imageButton = vgui.Create("DImageButton", popupFrame)
        imageButton:SetPos(Rewards.AdapteResolution(10, 8))
        imageButton:SetSize(Rewards.AdapteResolution(15, 15))
        imageButton:SetImage("settingslogo.png")
        imageButton.DoClick = function()
            popupFrameOpen = false
            popupFrame:Close()
            net.Start("Rewards.AdminPopup")
            net.SendToServer()
        end

        local closeButton = vgui.Create("DButton", popupFrame)
        closeButton:SetText("X")
        closeButton:SetFont("DermaDefaultBold_Adaptive")
        closeButton:SetSize(Rewards.AdapteResolution(25, 20))
        closeButton:SetPos(Rewards.AdapteResolution(570, 5))
        closeButton:SetTextColor(colWhite)
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colInv)
        end
        closeButton.DoClick = function()
            popupFrame:Close()
            popupFrameOpen = false
        end

        local yPos = 10 -- Position Y initial 1st element

        for _, task in ipairs(Tasks) do
            local taskPanel = vgui.Create("DPanel", taskScrollPanel)
            taskPanel:SetPos(Rewards.AdapteResolution(10, yPos))
            taskPanel:SetSize(Rewards.AdapteResolution(550, 60))
            taskPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, colBlack)
            end

            local iconImage = vgui.Create("DImage", taskPanel)
            iconImage:SetPos(Rewards.AdapteResolution(5, 5))
            iconImage:SetSize(Rewards.AdapteResolution(50, 50))
            iconImage:SetImage(task.image)

            local actionDescriptionLabel = vgui.Create("DLabel", taskPanel)
            actionDescriptionLabel:SetText(task.description)
            actionDescriptionLabel:SetFont("Trebuchet18_Adaptive")
            actionDescriptionLabel:SizeToContents()

            local textWidth = actionDescriptionLabel:GetWide()
            local panelWidth = taskPanel:GetWide()
            local textPosX = (panelWidth - textWidth) / 2

            actionDescriptionLabel:SetPos(Rewards.AdapteResolution(textPosX, 20))
            actionDescriptionLabel:SetTextColor(colWhite)

            -- Création du bouton "Redeem Reward"
            if (checkData.steam and task.name == "Steam Group") or 
                (checkData.discord and task.name == "Discord") or
                (checkData.ref == 'true' and task.name == "Referral Code")
             then

                local checkImage = vgui.Create("DImage", taskPanel)
                checkImage:SetPos(Rewards.AdapteResolution(510, 15))
                checkImage:SetSize(Rewards.AdapteResolution(30, 30))
                checkImage:SetImage("checklogo.png")

            elseif (checkData.daily and task.name == "Daily Reward") or 
                    (checkData.vip and task.name == "VIP Reward")
             then
                local timerImage = vgui.Create("DImage", taskPanel)
                timerImage:SetPos(Rewards.AdapteResolution(510, 15))
                timerImage:SetSize(Rewards.AdapteResolution(30, 30))
                timerImage:SetImage("timerlogo.png")
                
            else
                local redeemButton = vgui.Create("DButton", taskPanel)
                redeemButton:SetText("+")
                redeemButton:SetFont("DermaDefaultBold_Adaptive")
                redeemButton:SetTextColor(colWhite)
                redeemButton:SetSize(Rewards.AdapteResolution(30, 30))
                redeemButton:SetPos(Rewards.AdapteResolution(510, 15))
                redeemButton.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, colBluesky3)
                    if self:IsHovered() then
                        draw.RoundedBox(5, 0, 0, w, h, colBluesky)
                    end
                end

                redeemButton.DoClick = function()
                    local activeTab = Rewards.getActiveTabIndex(propertySheet)
                    local coorScroll = taskScrollPanel:GetVBar():GetScroll()

                    redeemButton:SetEnabled(false)
                    net.Start(task.action)
                    net.SendToServer()
                    timer.Simple(0.3, function()    
                        net.Start("Rewards.RefreshPopUp")
                        net.WriteUInt(activeTab, 8)
                        net.WriteUInt(coorScroll, 16)
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
        separator:SetSize(Rewards.AdapteResolution(600, 2))
        separator:SetPos(Rewards.AdapteResolution(0, yPos + 10)) -- Positionnez juste après la liste des tâches avec un espace de 10 pixels
        separator.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colBlack2)
        end

        -- Création du label de référence en dessous du séparateur
        local refLabel = vgui.Create("DLabel", taskScrollPanel)
        refLabel:SetText(Rewards.getTranslation("refCodeTitle") .. checkData.refcode)
        refLabel:SetFont("Trebuchet24_Adaptive")
        refLabel:SetContentAlignment(5)
        refLabel:SetSize(Rewards.AdapteResolution(600, 30))
        refLabel:SetPos(Rewards.AdapteResolution(0, yPos + 30)) -- Positionnez juste après le séparateur avec un espace supplémentaire de 20 pixels
        refLabel:SetTextColor(colWhite)

        -- Ajouter le séparateur après la liste des tâches
        local separator2 = vgui.Create("DPanel", taskScrollPanel)
        separator2:SetSize(Rewards.AdapteResolution(600, 2))
        separator2:SetPos(Rewards.AdapteResolution(0, yPos + 75)) -- Positionnez juste après la liste des tâches avec un espace de 10 pixels
        separator2.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colBlack2)
        end

        -- Ajout des giveaways dans l'onglet Giveaways
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

            local joinButton = vgui.Create("DButton", giveawayPanel)
            joinButton:SetText(Rewards.getTranslation("descAdmin15"))
            joinButton:SetFont("DermaDefaultBold_Adaptive")
            joinButton:SetTextColor(colWhite)
            joinButton:SetSize(Rewards.AdapteResolution(50, 30))
            joinButton:SetPos(Rewards.AdapteResolution(490, 25))
            if giveaway.hasJoined or giveaway.winner ~= "" then
                joinButton:SetDisabled(true)
            end
            joinButton.Paint = function(self, w, h)
                
                if joinButton:GetDisabled() then
                    draw.RoundedBox(4, 0, 0, w, h, lightGray) -- Grey color for disabled button
                else
                    draw.RoundedBox(4, 0, 0, w, h, colBluesky3)
                    if self:IsHovered() then
                        draw.RoundedBox(5, 0, 0, w, h, colBluesky)
                    end
                end
            end

            joinButton.DoClick = function()
                local activeTab = Rewards.getActiveTabIndex(propertySheet)
                local coorScroll = giveawayScrollPanel:GetVBar():GetScroll()

                if not joinButton:GetDisabled() then
                    RunConsoleCommand("join_giveaway", giveaway.name)
                    timer.Simple(0.3, function()    
                        net.Start("Rewards.RefreshPopUp")
                        net.WriteUInt(activeTab, 8)
                        net.WriteUInt(coorScroll, 16)
                        net.SendToServer()
                    end)
                    timer.Simple(1, function() popupFrame:Close()end)
                    popupFrameOpen = false 
                end
            end

            if giveaway.winner == steamid then
                
                local redButton = vgui.Create("DButton", giveawayPanel)
                redButton:SetText(Rewards.getTranslation("descAdmin14"))
                redButton:SetFont("DermaDefaultBold_Adaptive")
                redButton:SetTextColor(colWhite)
                redButton:SetSize(Rewards.AdapteResolution(70, 30))
                redButton:SetPos(Rewards.AdapteResolution(400, 25))
                if giveaway.redeem then
                    redButton:SetDisabled(true)
                end
                redButton.Paint = function(self, w, h)
                if redButton:GetDisabled() then
                    draw.RoundedBox(4, 0, 0, w, h, lightGray) -- Grey color for disabled button
                else
                    draw.RoundedBox(4, 0, 0, w, h, colGold2)
                    if self:IsHovered() then
                        draw.RoundedBox(5, 0, 0, w, h, colGold)
                    end
                end

                redButton.DoClick = function()
                if not redButton:GetDisabled() then
                    local activeTab = Rewards.getActiveTabIndex(propertySheet)
                    local coorScroll = giveawayScrollPanel:GetVBar():GetScroll()

                    net.Start("Rewards.redGiveaway")
                    net.WriteString(giveaway.name)
                    net.SendToServer()
                    timer.Simple(0.3, function()    
                        net.Start("Rewards.RefreshPopUp")
                        net.WriteUInt(activeTab, 8)
                        net.WriteUInt(coorScroll, 16)
                        net.SendToServer()
                    end)
                    timer.Simple(1, function() popupFrame:Close()end)
                    popupFrameOpen = false   
                end
            end 
        end     
    end
giveawayYPos = giveawayYPos + 90
end
 
end)
end
