Rewards.Config = Rewards.Config or {}

Rewards.Config.Lang = 'en' -- ('en' = English, 'fr' = French)

Rewards.Config.SteamAPIKey = 'A73551CF57FB1C50F06282C0433F4CA8' -- You can get this at https://steamcommunity.com/dev/apikey.
Rewards.Config.SteamGroupID = '33780955' -- You can get the ID of your group steam by editing it

Rewards.Config.DiscordID = 'pYhgPaphUP' -- The last letters of your invitation link

Rewards.Config.Shop = 'https://www.google.fr/' -- link of your shop

Rewards.Config.SteamRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
Rewards.Config.SteamReward = 3000 -- reward amount

Rewards.Config.DiscordRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
Rewards.Config.DiscordReward = 10000 -- reward amount

Rewards.Config.DailyRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
Rewards.Config.DailyReward = 3000 -- reward amount

Rewards.Config.VIPRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
Rewards.Config.VIPReward = 3000 -- reward amount

Rewards.Config.RefRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
Rewards.Config.RefReward = 3000 -- reward amount

Rewards.Config.Currency = "$" -- "$" "€" "£" "Coins" "Points"

Rewards.EnablePopUpSpawn = true -- enable/disable displaying pop up during initial spawn

Rewards.ServerTag = "[EXAMPLE]" -- change EXAMPLE by the server tag you want

Rewards.VIPgroup = {
    ["vip"] = true,
    ["superadmin"] = true
}

Rewards.Config.AdminGroup = {
    ["superadmin"] = true,
    ["admin"] = true
}

Rewards.Cooldown = 86400 -- 24 hours

-- You can comment tasks or change the order but don't change anything else !!

if Rewards.getTranslation then
    Rewards.Tasks = {
        {name="Steam Group", description=Rewards.getTranslation("descriptionSteam"), action="Rewards.actionSteam", image="steamlogo.png"},
        {name="Discord", description=Rewards.getTranslation("descriptionDiscord"), action="Rewards.actionDiscord", image="discordlogo.png"},
        {name="Daily Reward", description=Rewards.getTranslation("descriptionDaily"), action="Rewards.actionDaily", image="giftlogo.png"},
        {name="VIP Reward", description=Rewards.getTranslation("descriptionVIP"), action="Rewards.actionVIP", image="giftviplogo.png"},
        {name="Referral Code", description=Rewards.getTranslation("descriptionRef"), action="Rewards.actionRef", image="reflogo.png"},
    }
end

