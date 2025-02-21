local plymeta = FindMetaTable("Player")

if RewardsPlus.Config.MySQL.UseMySQL then
    require("mysqloo")
end

local function connectDatabase()
    if RewardsPlus.Config.MySQL.UseMySQL then
        database = mysqloo.connect(RewardsPlus.Config.MySQL.HOST, RewardsPlus.Config.MySQL.USERNAME, RewardsPlus.Config.MySQL.PASSWORD, RewardsPlus.Config.MySQL.DATABASE, RewardsPlus.Config.MySQL.PORT)
        
        function database:onConnectionFailed(err)
            print("[RewardsPlus] Failed to connect to database! Error: "..err)
        end
        
        database:setAutoReconnect(true)
        database:connect()

        local query = database:query(
        [[CREATE TABLE IF NOT EXISTS RewardsPlus_taskClaimed (
            `steamid` VARCHAR(64) NOT NULL PRIMARY KEY UNIQUE,
            `Reward_Steam` BOOLEAN DEFAULT FALSE,
            `Reward_Discord` BOOLEAN DEFAULT FALSE,
            `Reward_Ref` BOOLEAN DEFAULT FALSE,
            `Reward_Daily` DATETIME,
            `Reward_VIP` DATETIME,
            `Ref_Code` VARCHAR(64),
            `Pending_Reward` INT DEFAULT 0)]]
        )
    

        function query:onError(err)
            print("[RewardsPlus] Error: "..err)
        end
        
        query:start()
        
        local query2 = database:query(  
            [[CREATE TABLE IF NOT EXISTS RewardsPlus_giveaways (
                `name` VARCHAR(255) NOT NULL PRIMARY KEY,
                `rewardtype` VARCHAR(255) NOT NULL,
                `amount` TEXT NOT NULL,
                `winner` VARCHAR(255),
                `redeem` BOOLEAN DEFAULT FALSE,
                `players` TEXT,
                `hl` BOOLEAN DEFAULT FALSE,
                `requirement` VARCHAR(255))]]
        )

        function query2:onError(err)
            print("[RewardsPlus] Error: "..err)
        end

        query2:start()
    else
        local query = sql.Query(
        [[CREATE TABLE IF NOT EXISTS RewardsPlus_taskClaimed (
            `steamid` VARCHAR(64) NOT NULL PRIMARY KEY UNIQUE,
            `Reward_Steam` BOOLEAN DEFAULT FALSE,
            `Reward_Discord` BOOLEAN DEFAULT FALSE,
            `Reward_Ref` BOOLEAN DEFAULT FALSE,
            `Reward_Daily` DATETIME,
            `Reward_VIP` DATETIME,
            `Ref_Code` VARCHAR(64),
            `Pending_Reward` INT DEFAULT 0)]]
        )

        if query == false then
            print("[RewardsPlus] Error: "..sql.LastError())
        end
        
        local query2 = sql.Query(  
            [[CREATE TABLE IF NOT EXISTS RewardsPlus_giveaways (
                `name` VARCHAR(255) NOT NULL PRIMARY KEY,
                `rewardtype` VARCHAR(255) NOT NULL,
                `amount` TEXT NOT NULL,
                `winner` VARCHAR(255),
                `redeem` BOOLEAN DEFAULT FALSE,
                `players` TEXT,
                `hl` BOOLEAN DEFAULT FALSE,
                `requirement` VARCHAR(255))]]
        )
        
        if query2 == false then
            print("[RewardsPlus] Error: "..sql.LastError())
        end
    end
end

connectDatabase()

local function InitializePlayer(ply)
    local steamID = ply:SteamID()

    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format(
            "INSERT IGNORE INTO RewardsPlus_taskClaimed (steamid) VALUES ('%s')",
            database:escape(steamID)
        ))
        query:start()

        query.onError = function(_, err)
            print("MySQL: Failed to initialize player for steamID " .. steamID .. ": " .. err)
        end
    else
        local query = string.format(
            "INSERT OR IGNORE INTO RewardsPlus_taskClaimed (steamid) VALUES (%s)",
            sql.SQLStr(steamID)
        )
        local result = sql.Query(query)

        if result == false then
            print("SQLite: Failed to initialize player for steamID " .. steamID .. ": " .. sql.LastError())
        end
    end
end

hook.Add("PlayerInitialSpawn", "RewardsPlus_InitializeDB", InitializePlayer)


function RewardsPlus.updateReward(steamID, columnName, value)
    local escapedColumn = RewardsPlus.Config.MySQL.UseMySQL and database:escape(columnName) or sql.SQLStr(columnName)
    local sqlValue = value and 1 or 0
    if columnName == "Ref_Code" or columnName == "Pending_Reward" or columnName == "Reward_VIP" or columnName == "Reward_Daily" then sqlValue = value end

    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("UPDATE RewardsPlus_taskClaimed SET `"..columnName.."` = '"..database:escape(sqlValue).."' WHERE steamid = '"..database:escape(steamID).."'")
        query:start()

        query.onSuccess = function()
            print("MySQL: Successfully updated " .. columnName .. " for steamID " .. steamID)
        end

        query.onError = function(_, err)
            print("MySQL: Failed to update " .. columnName .. " for steamID " .. steamID .. ": " .. err)
        end
    else
        local result = sql.Query("UPDATE RewardsPlus_taskClaimed SET "..sql.SQLStr(columnName).." = "..sql.SQLStr(sqlValue).." WHERE steamid = "..sql.SQLStr(steamID)..";")

        if result == false then
            print("SQLite: Failed to update " .. columnName .. " for steamID " .. steamID .. ": " .. sql.LastError())
        else
            print("SQLite: Successfully updated " .. columnName .. " for steamID " .. steamID)
        end
    end
end

function RewardsPlus.getValue(steamID, columnName, callback)

    if RewardsPlus.Config.MySQL.UseMySQL then

        local query = database:query("SELECT `"..database:escape(columnName).."` FROM RewardsPlus_taskClaimed WHERE steamid = '"..database:escape(steamID).."'")
        
        function query:onSuccess(data)
            if data and data[1] and data[1][columnName] then
                if columnName == "Ref_Code" or columnName == "Reward_VIP" or columnName == "Reward_Daily" then
                    callback(data[1][columnName])
                elseif columnName == "Pending_Reward" then
                    callback(tonumber(data[1][columnName]))
                else
                    callback(tobool(data[1][columnName]))
                end
            else
                callback(nil)
            end
        end
        
        function query:onError(err)
            print("MySQL: Failed to retrieve " .. columnName .. " for steamID " .. steamID .. ": " .. err)
            callback(nil)
        end

        query:start()
    else
        
        local result = sql.QueryValue("SELECT "..sql.SQLStr(columnName, true).." FROM RewardsPlus_taskClaimed WHERE steamid = "..sql.SQLStr(steamID)..";")

        if not result then
            print("SQLite: Failed to retrieve " .. columnName .. " for steamID " .. steamID .. ": " .. sql.LastError())
            callback(nil)
        else
            if columnName == "Ref_Code" or columnName == "Reward_VIP" or columnName == "Reward_Daily" then
                callback(result)
            elseif columnName == "Pending_Reward" then
                callback(tonumber(result))
            else
                callback(tobool(result))
            end
        end
    end
end

function RewardsPlus.checkValue(columnName, value, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT 1 FROM RewardsPlus_taskClaimed WHERE `"..database:escape(columnName).."` = '"..database:escape(value).."' LIMIT 1")
        query:start()

        query.onData = function(_, data)
            callback(true)
        end

        query.onError = function(_, err)
            print("MySQL: Failed to check value in " .. columnName .. ": " .. err)
            callback(false)
        end

        query.onSuccess = function()
            callback(false)
        end
    else
        local result = sql.Query("SELECT steamid FROM RewardsPlus_taskClaimed WHERE "..sql.SQLStr(columnName, true).." = "..sql.SQLStr(value)..";")

        if not result then
            print("SQLite: Failed to check value in " .. columnName .. ": " .. sql.LastError())
            callback(false)
        else
            callback(result[1].steamid)
        end
    end
end

function RewardsPlus.isOnCooldown(steamID, columnName, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        -- Requête pour obtenir la valeur de la colonne spécifiée pour un SteamID donné
        local query = database:query(string.format(
            "SELECT `%s` FROM RewardsPlus_taskClaimed WHERE `steamid` = '%s' LIMIT 1",
            database:escape(columnName),
            database:escape(steamID)
        ))
        query:start()

        query.onData = function(_, data)
            local storedTime = data[columnName]
            if not storedTime or storedTime == "NULL" then
                callback(false, 0)
                return
            end

            -- Convertir l'heure stockée en temps Unix
            local storedTimeUnix = os.time({
                year = tonumber(storedTime:sub(1, 4)),
                month = tonumber(storedTime:sub(6, 7)),
                day = tonumber(storedTime:sub(9, 10)),
                hour = tonumber(storedTime:sub(12, 13)),
                min = tonumber(storedTime:sub(15, 16)),
                sec = tonumber(storedTime:sub(18, 19))
            })

            local currentTime = os.time()
            local elapsedSeconds = currentTime - storedTimeUnix
            local cooldown = RewardsPlus.Cooldown

            if elapsedSeconds >= cooldown then
                callback(false, 0)
            else
                local remainingSeconds = cooldown - elapsedSeconds
                callback(true, tonumber(remainingSeconds))
            end
        end

        query.onError = function(_, err)
            print("MySQL: Failed to check cooldown for " .. columnName .. ": " .. err)
            callback(false, 0)
        end

        query.onSuccess = function()
            -- If no data was returned, callback with false
            callback(false, 0)
        end
    else
        -- Utilisation de SQLite
        RewardsPlus.getValue(steamID, columnName, function(storedTime)
            if not storedTime or storedTime == "NULL" then
                callback(false, 0)
                return
            end

            local currentTime = os.time()
            local storedTimeUnix = os.time({
                year = tonumber(storedTime:sub(1, 4)),
                month = tonumber(storedTime:sub(6, 7)),
                day = tonumber(storedTime:sub(9, 10)),
                hour = tonumber(storedTime:sub(12, 13)),
                min = tonumber(storedTime:sub(15, 16)),
                sec = tonumber(storedTime:sub(18, 19))
            })

            local elapsedSeconds = currentTime - storedTimeUnix
            local cooldown = RewardsPlus.Cooldown

            if elapsedSeconds >= cooldown then
                callback(false, 0)
            else
                local remainingSeconds = cooldown - elapsedSeconds
                callback(true, tonumber(remainingSeconds))
            end
        end)
    end
end


-- Fonction pour ajouter un nouveau giveaway dans la table SQL
function RewardsPlus.addGiveaway(name, rewardType, amount, winner, redeem, players, hl, requirement)
    local playersStr = players and RewardsPlus.tableToString(players) or ""

    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format(
            "INSERT INTO RewardsPlus_giveaways (name, rewardtype, amount, winner, redeem, players, hl, requirement) VALUES ('%s', '%s', '%s', '%s', %d, '%s', %d, '%s')",
            database:escape(name),
            database:escape(rewardType),
            database:escape(amount),
            database:escape(winner or ""),
            redeem and 1 or 0,
            database:escape(playersStr),
            hl and 1 or 0,
            database:escape(requirement or "")
        ))

        query:start()

        query.onSuccess = function()
            print("MySQL: Successfully added giveaway " .. name)
        end

        query.onError = function(_, err)
            print("MySQL: Failed to add giveaway " .. name .. ": " .. err)
        end
    else
        local query = string.format(
            "INSERT INTO RewardsPlus_giveaways (name, rewardtype, amount, winner, redeem, players, hl, requirement) VALUES (%s, %s, %s, %s, %d, %s, %d, %s)",
            sql.SQLStr(name),
            sql.SQLStr(rewardType),
            sql.SQLStr(amount),
            sql.SQLStr(winner or ""),
            redeem and 1 or 0,
            sql.SQLStr(playersStr),
            hl and 1 or 0,
            sql.SQLStr(requirement or "")
        )

        local result = sql.Query(query)

        if result == false then
            print("SQLite: Failed to add giveaway " .. name .. ": " .. sql.LastError())
        else
            print("SQLite: Successfully added giveaway " .. name)
        end
    end
end

function RewardsPlus.giveawayExists(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT * FROM RewardsPlus_giveaways WHERE name = '"..database:escape(title).."'")
        query.onData = function(_, data)
            callback(data)
        end
        query:start()
    else
        local query = string.format(
            "SELECT * FROM RewardsPlus_giveaways WHERE name = %s",
            sql.SQLStr(title)
        )
        local result = sql.Query(query)
        callback(result and result[1])
    end
end

function RewardsPlus.getGiveaway(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT * FROM RewardsPlus_giveaways WHERE name = '"..database:escape(title).."'")
        query.onData = function(_, data)
            callback(data)
        end
        query:start()
    else
        local query = string.format(
            "SELECT * FROM RewardsPlus_giveaways WHERE name = %s",
            sql.SQLStr(title)
        )
        local result = sql.Query(query)
        callback(result and result[1])
    end
end

function RewardsPlus.getAllGiveaways(callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT * FROM RewardsPlus_giveaways")
        
        function query:onSuccess(data)
            callback(data)
        end

        function query:onError(err)
            print("MySQL: Failed to retrieve giveaways: " .. err)
            callback(nil)
        end

        query:start()
    else
        local query = "SELECT * FROM RewardsPlus_giveaways"
        local result = sql.Query(query)
        callback(result)
    end
end



function RewardsPlus.addPlayerToGiveaway(title, steamID, callback)
    RewardsPlus.getGiveaway(title, function(giveaway)
        if not giveaway then
            callback(false)
            return
        end

        local players = giveaway.players and RewardsPlus.stringToTable(giveaway.players) or {}
        table.insert(players, steamID)
        local playersString = table.concat(players, ",")

        if RewardsPlus.Config.MySQL.UseMySQL then
            local query = database:query(string.format(
                "UPDATE RewardsPlus_giveaways SET players = '%s' WHERE name = '%s'",
                database:escape(playersString),
                database:escape(title)
            ))
            query.onSuccess = function()
                callback(true)
            end
            query:start()
        else
            local query = string.format(
                "UPDATE RewardsPlus_giveaways SET players = %s WHERE name = %s",
                sql.SQLStr(playersString),
                sql.SQLStr(title)
            )
            local result = sql.Query(query)
            callback(result ~= false)
        end
    end)
end

function RewardsPlus.deleteGiveaway(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format(
            "DELETE FROM RewardsPlus_giveaways WHERE name = '%s'",
            database:escape(title)
        ))
        query.onSuccess = function()
            callback(true)
        end
        query:start()
    else
        local query = string.format(
            "DELETE FROM RewardsPlus_giveaways WHERE name = %s",
            sql.SQLStr(title)
        )
        local result = sql.Query(query)
        callback(result ~= false)
    end
end

function RewardsPlus.getGiveawayPlayers(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT players FROM RewardsPlus_giveaways WHERE name = '"..database:escape(title).."'")
        
        function query:onSuccess(data)
            if data and data[1] and data[1].players then
                local players = RewardsPlus.stringToTable(data[1].players) or {}
                callback(players)
            else
                callback({})
            end
        end

        function query:onError(err)
            print("MySQL: Failed to retrieve players for giveaway '" .. title .. "': " .. err)
            callback({})
        end

        query:start()
    else
        local query = string.format("SELECT players FROM RewardsPlus_giveaways WHERE name = %s", sql.SQLStr(title))
        local result = sql.QueryRow(query)
        local players = result and RewardsPlus.stringToTable(result.players) or {}
        callback(players)
    end
end


function RewardsPlus.updateGiveawayWinner(title, winnerSteamID, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format(
            "UPDATE RewardsPlus_giveaways SET winner = '%s' WHERE name = '%s'",
            database:escape(winnerSteamID),
            database:escape(title)
        ))
        query.onSuccess = function()
            callback(true)
        end
        query:start()
    else
        local query = string.format(
            "UPDATE RewardsPlus_giveaways SET winner = %s WHERE name = %s",
            sql.SQLStr(winnerSteamID),
            sql.SQLStr(title)
        )
        local result = sql.Query(query)
        callback(result ~= false)
    end
end

function RewardsPlus.updateGiveawayHL(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        -- Réinitialiser le champ `hl` pour tous les giveaways
        local resetQuery = "UPDATE RewardsPlus_giveaways SET hl = FALSE"
        database:query(resetQuery):start()

        -- Mettre à jour le champ `hl` pour le giveaway spécifié
        local updateQuery = database:query(string.format(
            "UPDATE RewardsPlus_giveaways SET hl = TRUE WHERE name = '%s'",
            database:escape(title)
        ))
        updateQuery.onSuccess = function()
            callback(true)
        end
        updateQuery:start()
    else
        -- Réinitialiser le champ `hl` pour tous les giveaways
        sql.Query("UPDATE RewardsPlus_giveaways SET hl = 0")

        -- Mettre à jour le champ `hl` pour le giveaway spécifié
        local query = string.format(
            "UPDATE RewardsPlus_giveaways SET hl = 1 WHERE name = %s",
            sql.SQLStr(title)
        )
        local result = sql.Query(query)
        callback(result ~= false)
    end
end

function RewardsPlus.getHighlightedGiveaway(callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT name FROM RewardsPlus_giveaways WHERE hl = 1")
        query.onData = function(_, data)
            callback(data.name)
        end
        query:start()
    else
        local query = "SELECT name FROM RewardsPlus_giveaways WHERE hl = 1"
        local result = sql.Query(query)
        if result and result[1] then
            callback(result[1].name)
        else
            callback(nil)
        end
    end
end

function RewardsPlus.checkGiveawayWinner(title, steamID, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format("SELECT winner FROM RewardsPlus_giveaways WHERE name = '%s'", database:escape(title)))
        query.onData = function(_, data)
            callback(data and data.winner == steamID)
        end
        query:start()
    else
        local query = string.format("SELECT winner FROM RewardsPlus_giveaways WHERE name = %s", sql.SQLStr(title))
        local result = sql.QueryRow(query)
        callback(result and result.winner == steamID)
    end
end

function RewardsPlus.isGiveawayRedeemed(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format("SELECT redeem FROM RewardsPlus_giveaways WHERE name = '%s'", database:escape(title)))
        query.onData = function(_, data)
            callback(data and data.redeem == 1)
        end
        query:start()
    else
        local query = string.format("SELECT redeem FROM RewardsPlus_giveaways WHERE name = %s", sql.SQLStr(title))
        local result = sql.QueryRow(query)
        callback(result and result.redeem == "1")
    end
end

function RewardsPlus.markGiveawayAsRedeemed(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query(string.format("UPDATE RewardsPlus_giveaways SET redeem = TRUE WHERE name = '%s'", database:escape(title)))
        query.onSuccess = function()
            callback(true)
        end
        query:start()
    else
        local query = string.format("UPDATE RewardsPlus_giveaways SET redeem = 1 WHERE name = %s", sql.SQLStr(title))
        local result = sql.Query(query)
        callback(result ~= false)
    end
end

-- Fonction pour récupérer les détails d'un giveaway
function RewardsPlus.getGiveawayDetails(title, callback)
    if RewardsPlus.Config.MySQL.UseMySQL then
        local query = database:query("SELECT * FROM RewardsPlus_giveaways WHERE name = '"..database:escape(title).."' LIMIT 1")
        query:start()

        query.onData = function(_, data)
            callback({
                name = data.name,
                rewardtype = data.rewardtype,
                amount = data.amount,
                hasJoined = data.hasJoined,
                winner = data.winner,
                redeem = data.redeem,
                players = RewardsPlus.stringToTable(data.players),
                hl = data.hl,
                requirement = data.requirement
            })
        end

        query.onError = function(_, err)
            print("MySQL: Failed to retrieve giveaway details for " .. title .. ": " .. err)
            callback(nil)
        end

        query.onSuccess = function()
            -- If no data was returned, callback with nil
            callback(nil)
        end
    else
        -- Utilisation de SQLite
        local query = string.format("SELECT * FROM RewardsPlus_giveaways WHERE name = %s", sql.SQLStr(title))
        local result = sql.Query(query)

        if result then
            local giveaway = result[1]
            if giveaway then
                callback({
                    name = giveaway.name,
                    rewardtype = giveaway.rewardtype,
                    amount = giveaway.amount,
                    hasJoined = giveaway.hasJoined,
                    winner = giveaway.winner,
                    redeem = giveaway.redeem,
                    players = RewardsPlus.stringToTable(giveaway.players),
                    hl = giveaway.hl,
                    requirement = giveaway.requirement
                })
            else
                callback(nil)
            end
        else
            print("SQLite: Failed to retrieve giveaway details for " .. title .. ": " .. sql.LastError())
            callback(nil)
        end
    end
end






















