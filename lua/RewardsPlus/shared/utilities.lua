local Utilities = {}

function Utilities.isPlayerOnCooldown(ply, cooldowns, cooldownTime)
    local lastRewardTime = cooldowns[ply:SteamID()]
    if lastRewardTime == nil then
        return false -- Aucun temps d'attente enregistré pour ce joueur
    end
    local currentTime = os.time()
    return (currentTime - lastRewardTime) < cooldownTime
end


return Utilities
