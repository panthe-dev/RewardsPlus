function sendAnnounce(ply, message)
    for _, player in ipairs(player.GetAll()) do
        player:ChatPrint(message)
    end
end