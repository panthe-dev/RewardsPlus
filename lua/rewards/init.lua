
Rewards = Rewards or {}

include('rewards/config.lua')
include('shared/sh_function.lua')
include('languages/sh_language_en.lua')
include('languages/sh_language_fr.lua')
	
if SERVER then
	local function AddCSLuaFiles(dir)
		local files, folders = file.Find(dir .. '*', 'LUA')

		for _, luafile in ipairs(files) do
			AddCSLuaFile(dir .. luafile)
		end

		for _, luadir in ipairs(folders) do
			AddCSLuaFiles(dir .. luadir .. '/')
		end
	end

	AddCSLuaFile()
	AddCSLuaFiles('rewards/client/')
	AddCSLuaFile('rewards/init.lua')
	AddCSLuaFile('rewards/config.lua')
	AddCSLuaFile('rewards/shared/sh_function.lua')
	AddCSLuaFile('rewards/languages/sh_language_en.lua')
	AddCSLuaFile('rewards/languages/sh_language_fr.lua')
	
	include('config.lua')
	include('shared/data.lua')
	include('shared/utilities.lua')

	include('server/command.lua')
	include('server/actionSteam.lua')
	include('server/actionDiscord.lua')
	include('server/actionDaily.lua')
	include('server/actionVIP.lua')
	include('server/actionReferral.lua')
	include('server/admin.lua')
	include('server/function.lua')

end

if CLIENT then
	include('shared/sh_function.lua')
	include('languages/sh_language_en.lua')
	include('languages/sh_language_fr.lua')
	include('client/cl_call.lua')
	include('client/popup.lua')
	include('client/adminpopup.lua')
	include('client/refpopup.lua')
	include('client/function.lua')
end