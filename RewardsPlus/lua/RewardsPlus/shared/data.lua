-- data.lua

-- Chemin du répertoire de sauvegarde des données
local saveDirectory = "rewards/"

if not file.Exists(saveDirectory, "DATA") then
    file.CreateDir(saveDirectory)
end

-- Chemin complet du fichier de sauvegarde des données
local function getSaveFilePath(saveFile)
    return saveDirectory .. saveFile
end

function Rewards.loadCooldowns(saveFile)
    if file.Exists(getSaveFilePath(saveFile), "DATA") then
        local data = file.Read(getSaveFilePath(saveFile), "DATA")
        return util.JSONToTable(data)
    else
        file.Write(getSaveFilePath(saveFile), util.TableToJSON({}))
        return {}  -- Retourne une table vide si le fichier n'existe pas
    end
end


function Rewards.saveCooldowns(saveFile, cooldowns)
    file.Write(getSaveFilePath(saveFile), util.TableToJSON(cooldowns))
end

