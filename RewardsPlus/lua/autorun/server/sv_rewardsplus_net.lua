util.AddNetworkString("Rewards.AfficherPopup")
util.AddNetworkString("Rewards.RefreshPopUp")
util.AddNetworkString("Rewards.AdminPopup")
util.AddNetworkString("Rewards.AfficherAdminPopup")
util.AddNetworkString("Rewards.RefreshAdminPopUp")

util.AddNetworkString("Rewards.actionDiscord")
util.AddNetworkString("Rewards.actionSteam")
util.AddNetworkString("Rewards.actionDaily")
util.AddNetworkString("Rewards.actionVIP")
util.AddNetworkString("Rewards.actionRef")
util.AddNetworkString("Rewards.actionNonDef")

util.AddNetworkString("Rewards.checkDaily")
util.AddNetworkString("Rewards.resDaily")

util.AddNetworkString("Rewards.checkDiscord")
util.AddNetworkString("Rewards.resDiscord")

util.AddNetworkString("Rewards.openDiscord")
util.AddNetworkString('Rewards.openSteam')
util.AddNetworkString('Rewards.openShop')
util.AddNetworkString('Rewards.openRef')
util.AddNetworkString('Rewards.openHl')
util.AddNetworkString('Rewards.submitRefCode')

util.AddNetworkString("Rewards.RequestPlayerRewards")
util.AddNetworkString("Rewards.SendPlayerRewards")
util.AddNetworkString("Rewards.SendAllGiveaways")
util.AddNetworkString("Rewards.redGiveaway")


local filePath = "rewards/giveaways.json"

if not file.Exists(filePath, "DATA") then
    local fileContent = util.TableToJSON({})
    file.Write(filePath, fileContent)
    print("New giveaways file created.")
end