RewardsPlus.Config = RewardsPlus.Config or {}

RewardsPlus.Config.Lang = 'en' -- ('en' = English, 'fr' = French)

RewardsPlus.Config.SteamAPIKey = 'A73551CF57FB1C50F06282C0433F4CA8' -- You can get this at https://steamcommunity.com/dev/apikey.
RewardsPlus.Config.SteamGroupID = '33780955' -- You can get the ID of your group steam by editing it

RewardsPlus.Config.DiscordID = 'pYhgPaphUP' -- The last letters of your invitation link

RewardsPlus.Config.Shop = 'https://www.google.fr/' -- link of your shop

RewardsPlus.Config.SteamRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
RewardsPlus.Config.SteamReward = 3000 -- reward amount

RewardsPlus.Config.DiscordRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
RewardsPlus.Config.DiscordReward = 10000 -- reward amount

RewardsPlus.Config.DailyRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
RewardsPlus.Config.DailyReward = 3000 -- reward amount

RewardsPlus.Config.VIPRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
RewardsPlus.Config.VIPReward = 3000 -- reward amount

RewardsPlus.Config.RefRewardType = "DarkRP" -- "AShop" "SH Pointshop" "DarkRP"
RewardsPlus.Config.RefReward = 3000 -- reward amount

RewardsPlus.Config.Currency = "$" -- "$" "€" "£" "Coins" "Points"

RewardsPlus.EnablePopUpSpawn = true -- enable/disable displaying pop up during initial spawn

RewardsPlus.ServerTag = "[EXAMPLE]" -- change EXAMPLE by the server tag you want

RewardsPlus.VIPgroup = {
    ["vip"] = true,
    ["superadmin"] = true
}

RewardsPlus.Config.AdminGroup = {
    ["superadmin"] = true,
    ["admin"] = true
}

RewardsPlus.Cooldown = 86400 -- 24 hours

RewardsPlus.Config.MySQL = RewardsPlus.Config.MySQL or {}

RewardsPlus.Config.MySQL.UseMySQL = true -- true = use mySQL

 -- If you want to use MySQL
RewardsPlus.Config.MySQL.HOST = "localhost"
RewardsPlus.Config.MySQL.USERNAME = "root"
RewardsPlus.Config.MySQL.PASSWORD = ""
RewardsPlus.Config.MySQL.DATABASE = "darkrp"
RewardsPlus.Config.MySQL.PORT = 3306

-- You can comment tasks or change the order but don't change anything else !!

if RewardsPlus.getTranslation then
    RewardsPlus.Tasks = {
        {name="Steam Group", description=RewardsPlus.getTranslation("descriptionSteam"), action="Rewards.actionSteam", image="steamlogo.png"},
        {name="Discord", description=RewardsPlus.getTranslation("descriptionDiscord"), action="Rewards.actionDiscord", image="discordlogo.png"},
        {name="Daily Reward", description=RewardsPlus.getTranslation("descriptionDaily"), action="Rewards.actionDaily", image="giftlogo.png"},
        {name="VIP Reward", description=RewardsPlus.getTranslation("descriptionVIP"), action="Rewards.actionVIP", image="giftviplogo.png"},
        {name="Referral Code", description=RewardsPlus.getTranslation("descriptionRef"), action="Rewards.actionRef", image="reflogo.png"},
    }
end

