net.Receive("Rewards.openSteam", function()
	gui.OpenURL('http://steamcommunity.com/gid/' .. net.ReadString())
end)

net.Receive("Rewards.openDiscord", function()
	gui.OpenURL('https://discord.gg/' .. net.ReadString())
end)

net.Receive("Rewards.openShop", function()
    gui.OpenURL(net.ReadString())
end)



local function verifyPlayer(steamid, callback)
    gmInte.http.get("/users?steamID64="..steamid, 
        function(code, data)
            if data and data.lastVerification then

                callback(true)
            else
                callback(false)
            end 
        end,
        function(error)
            print("Erreur lors de la requête:", error)
            callback(false)
        end
    )
end

net.Receive("Rewards.checkDiscord", function(len, ply)
    local steamid = net.ReadString()

    verifyPlayer(steamid, function(verified)
    	net.Start("Rewards.resDiscord")
    	net.WriteBool(verified)
    	net.SendToServer()
    end)
end)

net.Receive("Rewards.checkDaily", function(len, ply)
    local steamid = net.ReadString()

    steamworks.RequestPlayerInfo( steamid, function( steamName )
        net.Start("Rewards.resDaily")
        net.WriteString(steamName)
        net.SendToServer()
    end )

end)

