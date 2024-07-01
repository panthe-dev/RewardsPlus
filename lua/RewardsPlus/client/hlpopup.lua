if CLIENT then
    local popupFrameOpen = false

    local colBluesky = Color(0, 153, 230, 255)
    local colBluesky2 = Color(0, 153, 230, 250)
    local colBluesky3 = Color(0, 153, 230, 200)
    local colGrey = Color(49, 57, 68, 240)
    local colRed = Color(255, 0, 0,255)
    local colRed2 = Color(204, 0, 0, 200)
    local colWhite = Color(255, 255, 255)
    local colInv = Color(200, 50, 50, 0)


    local function CreateGiveawayBanner(giveawayTitle)

        GiveawayBanner = vgui.Create("DPanel")
        GiveawayBanner:SetSize(Rewards.AdapteResolution(1920,60))
        GiveawayBanner:SetPos(Rewards.AdapteResolution(0, 0))
        GiveawayBanner:SetBackgroundColor(colGrey) -- Couleur de fond avec transparence

        local titleLabel = vgui.Create("DLabel", GiveawayBanner)
        titleLabel:SetText(Rewards.getTranslation("descAdmin1").." "..giveawayTitle)
        titleLabel:SetFont("Trebuchet30_Adaptive")
        titleLabel:SizeToContents()
        titleLabel:SetPos(Rewards.AdapteResolution(100,15))
        titleLabel:SetTextColor(colWhite)

        local joinButton = vgui.Create("DButton", GiveawayBanner)
        joinButton:SetText(Rewards.getTranslation("descAdmin15"))
        joinButton:SetFont("Trebuchet30_Adaptive")
        joinButton:SetSize(Rewards.AdapteResolution(200, 30))
        joinButton:SetPos(Rewards.AdapteResolution(1600, 15))
        joinButton:SetTextColor(colWhite)
        joinButton.DoClick = function()
            RunConsoleCommand("join_giveaway", giveawayTitle)
            GiveawayBanner:Remove()
        end
        joinButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colBluesky3)
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, colBluesky)
            end
        end

        -- Option pour fermer la bannière manuellement
        local closeButton = vgui.Create("DButton", GiveawayBanner)
        closeButton:SetText("X")
        closeButton:SetFont("Trebuchet30_Adaptive")
        closeButton:SetSize(Rewards.AdapteResolution(30, 30))
        closeButton:SetPos(Rewards.AdapteResolution(1850, 15))
        closeButton:SetTextColor(colWhite)
        closeButton.DoClick = function()
            GiveawayBanner:Remove()
        end
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colRed2)
            if self:IsHovered() then
                draw.RoundedBox(5, 0, 0, w, h, colRed)
            end
        end
    end

    -- Exemple d'utilisation
    net.Receive("Rewards.openHl", function()
        local giveawayTitle = net.ReadString()
        CreateGiveawayBanner(giveawayTitle)
    end)
end

