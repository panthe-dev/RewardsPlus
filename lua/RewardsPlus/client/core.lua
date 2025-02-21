local plymeta = FindMetaTable("Player")

local RewardsPlus_Giveaways = {}
local RewardsPlus_Tasks = {}
local RewardsPlus_RewardValues = {}
local RewardsPlus_activeTab, RewardsPlus_coorScroll

net.Receive("Rewards.AfficherPopup", function(len, ply) RewardsPlus.OpenRewardMenu() end)

net.Receive("RewardsPlus.networkGiveaway", function()
    RewardsPlus_Giveaways = {}
end)

net.Receive("RewardsPlus.networkGiveawayFragment", function(len, ply)
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
        table.insert(RewardsPlus_Giveaways, giveaway)
    end

end)

net.Receive("RewardsPlus.networkTask", function(len, ply)
    RewardsPlus_Tasks = {}
    local numTasks = net.ReadUInt(8)
    
    for i = 1, numTasks do
        local task = {
            action = net.ReadString(), 
            description = net.ReadString(),
            image = net.ReadString(),
            name = net.ReadString()
        }
        table.insert(RewardsPlus_Tasks, task)
    end
end)

net.Receive("RewardsPlus.networkRewardValues", function(len, ply)
    RewardsPlus_RewardValues = {
        daily = net.ReadBool(),
        discord = net.ReadBool(),
        ref = net.ReadBool(),
        refcode = net.ReadString(),
        steam = net.ReadBool(),
        vip = net.ReadBool()
    }
end)

net.Receive("RewardsPlus.networkUI", function(len, ply)
    RewardsPlus_activeTab = net.ReadUInt(8) or 1
    RewardsPlus_coorScroll = net.ReadUInt(16) or 1
end)

function plymeta:RewardsPlus_loadGiveaway()
    local Giveaways = {}
    if self == LocalPlayer() then
        if RewardsPlus_Giveaways then Giveaways = RewardsPlus_Giveaways end
    elseif self.RewardsPlus_Giveaways then
        Giveaways = self.RewardsPlus_Giveaways
    end
    return Giveaways
end

function plymeta:RewardsPlus_loadTasks()
    local Tasks = {}
    if self == LocalPlayer() then
        if RewardsPlus_Tasks then Tasks = RewardsPlus_Tasks end
    elseif self.RewardsPlus_Tasks then
        Tasks = self.RewardsPlus_Tasks
    end
    return Tasks
end

function plymeta:RewardsPlus_loadRewardValues()
    local RewardValues = {}
    if self == LocalPlayer() then
        if RewardsPlus_RewardValues then RewardValues = RewardsPlus_RewardValues end
    elseif self.RewardsPlus_RewardValues then
        RewardValues = self.RewardsPlus_RewardValues
    end

    return RewardValues 
end

function plymeta:RewardsPlus_loadUI()
    local activeTab, coorScroll     
    if self == LocalPlayer() then
        if RewardsPlus_activeTab and RewardsPlus_coorScroll then activeTab, coorScroll = RewardsPlus_activeTab, RewardsPlus_coorScroll end
    elseif self.RewardsPlus_activeTab and self.RewardsPlus_coorScroll then
        activeTab, coorScroll = self.RewardsPlus_activeTab, self.RewardsPlus_coorScroll
    end
    return activeTab, coorScroll
end