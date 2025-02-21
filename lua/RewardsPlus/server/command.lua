if SERVER then

    local function EnvoyerPopup(ply, activeTab, coorScroll)
        RewardsPlus.networkTask(ply)
        RewardsPlus.networkRewardValues(ply)
        RewardsPlus.networkUI(ply, activeTab, coorScroll)
        RewardsPlus.networkGiveaway(ply)
        RewardsPlus.openRewardMenu(ply)
    end

    local function AfficherPopup(ply)
        if RewardsPlus.EnablePopUpSpawn then
            timer.Simple(1, function()
                EnvoyerPopup(ply)
            end)
        end

        local title
        
        RewardsPlus.getHighlightedGiveaway(function(val)
            title = val
        end)

        if title then
            net.Start("Rewards.openHl")
            net.WriteString(title)
            net.Send(ply)
        end
    end

    local function RafraichirPopup(ply, activeTab, coorScroll)
        EnvoyerPopup(ply, activeTab, coorScroll)
    end

    -- display popup when spawning
    hook.Add("PlayerInitialSpawn", "RewardsPlus_AfficherPopupAuSpawn", AfficherPopup)

    -- display popup when !rewards
    hook.Add("PlayerSay", "RewardsPlus_cmdrewards", function(ply, _text, public)
        if (_text == "!rewards") then
            ply:ConCommand("rewards")
                EnvoyerPopup(ply)
            return ""
        end
    end)

    -- refresh page after clicking a button
    net.Receive("Rewards.RefreshPopUp", function(len, ply)
        local activeTab = net.ReadUInt(8) or 1
        local coorScroll = net.ReadUInt(16) or 1
        RafraichirPopup(ply, activeTab, coorScroll)
    end)
    
end

