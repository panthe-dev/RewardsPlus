Rewards.types = Rewards.types or {}

Rewards.types["DarkRP"] = {
    OnClaim = function(ply, amt)
        ply:addMoney(amt)
        ply:ChatPrint(Rewards.getTranslation("RewardText")..amt.. " "..Rewards.Config.Currency)
    end
}

Rewards.types["aShop"] = {
    OnClaim = function(ply, amt)
        ply:ashop_addCoinsSafe(amt, false)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. amt .. " points aShop !")
    end
}

Rewards.types["giftcard"] = {
    OnClaim = function(ply, amt)
        ply:ChatPrint(Rewards.getTranslation("err25") .. amt)
    end
}

Rewards.types["PS1"] = {
    OnClaim = function(ply, amt)
        ply:PS_GivePoints(amt)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. amt .. " points Pointshop 1 !")
    end
}

Rewards.types["PS2"] = {
    OnClaim = function(ply, amt)
        ply:PS2_AddStandardPoints(amt)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. amt .. " standard points Pointshop 2 !")
    end
}

Rewards.types["PS2 Premium"] = {
    OnClaim = function(ply, amt)
        ply:PS2_AddPremiumPoints(amt)
        ply:ChatPrint(Rewards.getTranslation("RewardText") .. amt .. " premium points Pointshop 2 !")
    end
}
