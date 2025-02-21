function RewardsPlus.openRewardMenu(ply)
    if not IsValid(ply) then return end
    net.Start("Rewards.AfficherPopup")
    net.Send(ply)
end

function RewardsPlus.openAdminMenu(ply)
    if not IsValid(ply) then return end
    net.Start("Rewards.AfficherAdminPopup")
    net.Send(ply)
end

function RewardsPlus.networkGiveaway(ply)
    RewardsPlus.sendAllGiveaways(ply, function(giveawaytable)
        net.Start("RewardsPlus.networkGiveaway")
        net.Send(ply)

        RewardsPlus.sendGiveawaysFragmented(ply, giveawaytable)
    end)
end

function RewardsPlus.sendGiveawaysFragmented(ply, giveawaysTable)
    local maxPerMessage = 10 -- Nombre de giveaways par message
    local totalGiveaways = #giveawaysTable
    local currentIndex = 1

    while currentIndex <= totalGiveaways do
        net.Start("RewardsPlus.networkGiveawayFragment")
        local endIndex = math.min(currentIndex + maxPerMessage - 1, totalGiveaways)
        net.WriteUInt(endIndex - currentIndex + 1, 8)
        for i = currentIndex, endIndex do
            local giveaway = giveawaysTable[i]
            net.WriteString(giveaway.name)
            net.WriteString(giveaway.rewardtype)
            net.WriteInt(giveaway.amount, 32)
            net.WriteBool(giveaway.hasJoined)
            net.WriteString(giveaway.winner)
            net.WriteBool(giveaway.redeem)
            net.WriteInt(tonumber(giveaway.players) or 0, 8)
            net.WriteString(giveaway.requirement)
        end
        net.Send(ply)
        currentIndex = endIndex + 1
    end
end

function RewardsPlus.networkTask(ply)
    net.Start("RewardsPlus.networkTask")
    local Tasks = RewardsPlus.Tasks
    net.WriteUInt(#Tasks, 8) 
        for _, task in ipairs(Tasks) do
            net.WriteString(task.action)
            net.WriteString(task.description)
            net.WriteString(task.image)
            net.WriteString(task.name)
        end
    net.Send(ply)
end

function RewardsPlus.networkRewardValues(ply)
    local function fetchAllData(ply, callback)
    
        local steamID = ply:SteamID()
        local steam, discord, ref, refcode, vip, daily

        RewardsPlus.getValue(steamID, "Reward_Steam", function(rewardSteam) steam = rewardSteam or false
        RewardsPlus.getValue(steamID, "Reward_Discord", function(rewardDiscord) discord = rewardDiscord or false
        RewardsPlus.getValue(steamID, "Reward_Ref", function(rewardRef) ref = rewardRef or false
        RewardsPlus.getValue(steamID, "Ref_Code", function(refCode) refcode = refCode or ""
        RewardsPlus.getValue(steamID, "Reward_VIP", function(rewardVIP, remainingSeconds) vip = rewardVIP or false
        RewardsPlus.getValue(steamID, "Reward_Daily", function(rewardDaily, remainingSeconds) daily = rewardDaily or false

        callback({
            steam = steam,
            discord = discord,
            daily = rewardDaily,
            vip = rewardVIP,
            ref = ref, 
            refcode = refcode
        })
        end)end)end)end)end)end)
    end

    fetchAllData(ply, function(tbl)
        net.Start("RewardsPlus.networkRewardValues")
            net.WriteBool(tbl.daily)
            net.WriteBool(tbl.discord)
            net.WriteBool(tbl.ref)
            net.WriteString(tbl.refcode)
            net.WriteBool(tbl.steam)
            net.WriteBool(tbl.vip)
        net.Send(ply)
    end)
end

function RewardsPlus.networkUI(ply, activeTab, coorScroll)
    net.Start("RewardsPlus.networkUI")
        net.WriteUInt(activeTab or 1, 8)
        net.WriteUInt(coorScroll or 1, 16)
    net.Send(ply)
end