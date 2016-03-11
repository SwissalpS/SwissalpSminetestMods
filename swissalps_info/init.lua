--local path = minetest.get_modpath(minetest.get_current_modname())

SwissalpS = SwissalpS or {}
SwissalpS.info = {
	version = 0.1,
	sSwissalpSmodTag = 'mod_info',
	sSwissalpSmodTitle = 'info'
}
SwissalpS.info.tStartTimes = {}
SwissalpS.info.tStartTimes[SwissalpS.info.sSwissalpSmodTag] = os.clock()

--TODO: figure a way to determine if NTFS OS
DIR_DELIM = DIR_DELIM or '/';

SwissalpS.info.bCanShell = os.execute()

-- depricated, use SwissalpS.info.notifyPlayer instead
SwissalpS.info.player_notify = function(sName, sMessage)
	minetest.chat_send_player(sName, "SssSinfo - " .. sMessage, false)
end -- SwissalpS.info.player_notify

function SwissalpS.info.broadcast(sMessage)
	sMessage = sMessage or 'nil'
	minetest.chat_send_all('SssSinfo b- ' .. sMessage)
end -- SwissalpS.info.broadcast

function SwissalpS.info.notifyPlayer(sName, sMessage)
	sMessage = sMessage or 'nil'
	minetest.chat_send_player(sName, 'SssSinfo - ' .. sMessage, false)
end -- SwissalpS.info.notifyPlayer

function SwissalpS.info.timerDiff(oMod)
	local sName = oMod.sSwissalpSmodTag
	if nil == sName
		or '' == sName then
		return -1
	end
	local fStartTime = SwissalpS.info.tStartTimes[sName]
	if nil == fStartTime then
		return -2
	end

	return os.clock() - fStartTime

end -- SwissalpS.info.timerDiff

function SwissalpS.info.timerDiffLog(oMod)
	if not minetest.setting_getbool('log_mod') then
		return false
	end
	local fDiff = SwissalpS.info.timerDiff(oMod)
	local sModTitle = oMod.sSwissalpSmodTitle or 'unknown mod'
	minetest.log('action', '[MOD] SwissalpS.' .. sModTitle .. ' loaded in ' .. fDiff .. 's.')
end -- SwissalpS.info.timerDiffLog

function SwissalpS.info.timerStart(oMod)
	local sName = oMod.sSwissalpSmodTag
	if nil == sName
		or '' == sName then
		return -1
	end

	SwissalpS.info.tStartTimes[sName] = os.clock()

	return true

end -- SwissalpS.info.timerStart

local sPathMod = minetest.get_modpath(minetest.get_current_modname());
dofile(sPathMod .. DIR_DELIM .. 'chatCommandFunctions.lua');
dofile(sPathMod .. DIR_DELIM .. 'registerChatCommands.lua');
dofile(sPathMod .. DIR_DELIM .. 'nodeInfoTool.lua');
SwissalpS.info.timerDiffLog(SwissalpS.info);
