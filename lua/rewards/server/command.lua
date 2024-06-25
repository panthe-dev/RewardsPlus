if SERVER then
    local Utilities = include("rewards/shared/utilities.lua")
    local Data = include("rewards/shared/data.lua")
    local saveFile = "dailyrewards_cooldowns.txt"
    local cooldowns = Data.loadCooldowns(saveFile) or {}
    local saveFileVIP = "viprewards_cooldowns.txt"
    local cooldownsVIP = Data.loadCooldowns(saveFileVIP) or {}
    local cooldownTime = Rewards.Cooldown
    local Tasks = Rewards.Tasks
    local refFile = "refcodes.txt"
    local refCodes = Data.loadCooldowns(refFile) or {}


    local function EnvoyerPopup(ply, checkData)
        local giveawaytable = sendAllGiveaways(ply)
        
        net.Start("Rewards.AfficherPopup")
        net.WriteTable(giveawaytable)
        net.WriteTable(Tasks)
        net.WriteTable(checkData)
        net.WriteString(ply:SteamID())
        net.Send(ply)
    end

    local function CreerCheckData(ply)

    local refcodeplayer = refCodes[ply:SteamID()]
    return {
        steam = ply:GetPData("rewards_steam") or 'false',
        discord = ply:GetPData("rewards_discord") or 'false',
        daily = Utilities.isPlayerOnCooldown(ply, cooldowns, cooldownTime),
        vip = Utilities.isPlayerOnCooldown(ply, cooldownsVIP, cooldownTime),
        ref = ply:GetPData("rewards_ref") or 'false',
        refcode = refcodeplayer
    }
end

    local function AfficherPopup(ply)
        if Rewards.EnablePopUpSpawn then
            local checkData = CreerCheckData(ply)
            EnvoyerPopup(ply, checkData)
        end
    end

    local function RafraichirPopup(ply)
        local checkData = CreerCheckData(ply)
        EnvoyerPopup(ply, checkData)
    end

    -- display popup when spawning
    hook.Add("PlayerInitialSpawn", "AfficherPopupAuSpawn", AfficherPopup)

    -- display popup when !rewards
    hook.Add("PlayerSay", "cmdrewards", function(_p, _text, public)
        if (_text == "!rewards") then
            --_p:SetPData( "rewards_playtime1", 'false' )
            _p:ConCommand("rewards")
            local checkData = CreerCheckData(_p)
            EnvoyerPopup(_p, checkData)
            return ""
        end
    end)

    -- refresh page after clicking a button
    net.Receive("Rewards.RefreshPopUp", function(len, ply)
        RafraichirPopup(ply)
    end)
    
end

