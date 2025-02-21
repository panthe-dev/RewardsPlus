RewardsPlus.types = RewardsPlus.types or {}

RewardsPlus.types["DarkRP"] = {
    OnClaim = function(ply, amt)
        ply:addMoney(amt)
        ply:ChatPrint(RewardsPlus.getTranslation("RewardText")..amt.. " "..RewardsPlus.Config.Currency)
    end
}

RewardsPlus.types["aShop"] = {
    OnClaim = function(ply, amt)
        ply:ashop_addCoinsSafe(amt, false)
        ply:ChatPrint(RewardsPlus.getTranslation("RewardText") .. amt .. " points aShop !")
    end
}

RewardsPlus.types["giftcard"] = {
    OnClaim = function(ply, amt)
        ply:ChatPrint(RewardsPlus.getTranslation("err25") .. amt)
    end
}

RewardsPlus.types["PS1"] = {
    OnClaim = function(ply, amt)
        ply:PS_GivePoints(amt)
        ply:ChatPrint(RewardsPlus.getTranslation("RewardText") .. amt .. " points Pointshop 1 !")
    end
}

RewardsPlus.types["PS2"] = {
    OnClaim = function(ply, amt)
        ply:PS2_AddStandardPoints(amt)
        ply:ChatPrint(RewardsPlus.getTranslation("RewardText") .. amt .. " standard points Pointshop 2 !")
    end
}

RewardsPlus.types["PS2 Premium"] = {
    OnClaim = function(ply, amt)
        ply:PS2_AddPremiumPoints(amt)
        ply:ChatPrint(RewardsPlus.getTranslation("RewardText") .. amt .. " premium points Pointshop 2 !")
    end
}
