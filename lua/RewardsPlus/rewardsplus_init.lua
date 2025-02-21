
RewardsPlus = RewardsPlus or {}

include('RewardsPlus/config.lua')
include('shared/utilities.lua')
include('shared/sql.lua')
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
	AddCSLuaFiles('RewardsPlus/client/')
	AddCSLuaFile('RewardsPlus/rewardsplus_init.lua')
	AddCSLuaFile('RewardsPlus/config.lua')
	AddCSLuaFile('RewardsPlus/shared/sql.lua')
	AddCSLuaFile('RewardsPlus/shared/utilities.lua')
	AddCSLuaFile('RewardsPlus/languages/sh_language_en.lua')
	AddCSLuaFile('RewardsPlus/languages/sh_language_fr.lua')
	
	include('config.lua')
	include('shared/utilities.lua')
	include('shared/sql.lua')

	include('server/command.lua')
	include('server/concommand.lua')
	include('server/actions/actionSteam.lua')
	include('server/actions/actionDiscord.lua')
	include('server/actions/actionDaily.lua')
	include('server/actions/actionVIP.lua')
	include('server/actions/actionReferral.lua')
	include('server/admin.lua')
	include('server/function.lua')
	include('server/rewardtype.lua')
	include('server/core.lua')

end

if CLIENT then
	include('shared/sql.lua')
	include('shared/utilities.lua')
	include('languages/sh_language_en.lua')
	include('languages/sh_language_fr.lua')
	include('client/cl_call.lua')
	include('client/ui/popup.lua')
	include('client/ui/adminpopup.lua')
	include('client/ui/refpopup.lua')
	include('client/ui/hlpopup.lua')
	include('client/function.lua')
	include('client/ui/roulette.lua')
	include('client/core.lua')

end