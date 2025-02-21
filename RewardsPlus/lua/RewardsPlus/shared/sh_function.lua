function Rewards.getTranslation(key)
    local lang = Rewards.Language[Rewards.Config.Lang] or {}
    return lang[key] or key
end