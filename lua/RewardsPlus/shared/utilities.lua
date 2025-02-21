function RewardsPlus.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function RewardsPlus.getTranslation(key)
    local lang = RewardsPlus.Language[RewardsPlus.Config.Lang] or {}
    return lang[key] or key
end