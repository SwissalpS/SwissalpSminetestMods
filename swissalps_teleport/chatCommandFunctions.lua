-- Minetest mod: swissalps_teleport
-- See LICENSE.txt and README.txt for licensing and other information.

function SwissalpS.teleport.cc_goHome(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = SwissalpS.teleport.dbPlayer:get(
			sPlayer,
			sPrefix .. '_home_',
			SssStpS.default_homePos);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'Moved you home');
end; -- SwissalpS.teleport.cc_goHome

function SwissalpS.teleport.cc_goHomeGlobal(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = SwissalpS.teleport.dbPlayer:get(
			SssStpS.db_global_player_name,
			sPrefix .. '_home_',
			SssStpS.default_homePos);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'Moved you to global home.');
end; -- SwissalpS.teleport.cc_goHomeGlobal

function SwissalpS.teleport.cc_goToSlot(sPlayer, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local tPos = SwissalpS.teleport.dbPlayer:get(
			sPlayer, sPrefix .. sSlot, 'nothing');
	if 'nothing' == tPos then
		SwissalpS.info.notifyPlayer(sPlayer, 'no saved slot: ' .. sSlot);
		return;
	end;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'Moved you to: '
			.. minetest.pos_to_string(tPos, 1));
end; -- SwissalpS.teleport.cc_goToSlot

function SwissalpS.teleport.cc_goToSlotGlobal(sPlayer, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local tPos = SwissalpS.teleport.dbPlayer:get(
			SssStpS.db_global_player_name,
			sPrefix .. sSlot, 'nothing');
	if 'nothing' == tPos then
		SwissalpS.info.notifyPlayer(sPlayer, 'no global slot: ' .. sSlot);
		return;
	end
	local oPlayer = minetest.get_player_by_name(sPlayer);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'Moved you to: '
			.. minetest.pos_to_string(tPos, 1));
end; -- SwissalpS.teleport.cc_goToSlotGlobal

function SwissalpS.teleport.cc_help(sPlayer)
	local sHelp = '-tph|-tphome -tpsh|-tpsethome -tp <slot>'
			.. ' -tps|-tpset <slot> -tpl -tpgh|-tpghome'
			.. ' -tpgsh|-tpgsethome -tpg <slot> -tpgs|-tpgset <slot>';
	SwissalpS.info.notifyPlayer(sPlayer, sHelp);
end; -- SwissalpS.teleport.cc_help

function SwissalpS.teleport.cc_listSlots(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local iPrefixLength = string.len(sPrefix);
	local iCount = 0;
	local sOut;
	local sSlot;
	local tAllSlots = {};
	-- get all the player's slots
	local tAll = SwissalpS.teleport.dbPlayer:getAll(sPlayer, {});
	for sKey, mValue in pairs(tAll) do
		if sPrefix == string.sub(sKey, 1, iPrefixLength) then
			iCount = iCount +1;
			sSlot = string.sub(sKey, iPrefixLength +1);
			tAllSlots[sSlot] = mValue;
		end;
	end; -- loop filter out slots
	if 0 == iCount then
		sOut = 'no slots defined';
	else
		sOut = "Listing Player's Slots:";
	end; -- if no slots
	SwissalpS.info.notifyPlayer(sPlayer, sOut);
	for sSlot, tPos in pairs(tAllSlots) do
		SwissalpS.info.notifyPlayer(sPlayer, 'slot: ' .. sSlot
				.. ' pos: '
				.. minetest.pos_to_string(tPos, 2));
	end; -- for allSlots of player
	-- get all the global slots
	iCount = 0;
	tAllSlots = {};
	tAll = SwissalpS.teleport.dbPlayer:getAll(
			SssStpS.db_global_player_name, {});
	for sKey, mValue in pairs(tAll) do
		if sPrefix == string.sub(sKey, 1, iPrefixLength) then
			iCount = iCount +1;
			sSlot = string.sub(sKey, iPrefixLength +1);
			tAllSlots[sSlot] = mValue;
		end;
	end; -- loop filter out slots
	if 0 == iCount then
		sOut = 'no global slots';
	else
		sOut = 'Listing Global Slots:';
	end; -- if got global slots
	SwissalpS.info.notifyPlayer(sPlayer, sOut);
	for sSlot, tPos in pairs(tAllSlots) do
		SwissalpS.info.notifyPlayer(sPlayer, 'slot: ' .. sSlot
				.. ' pos: '
				.. minetest.pos_to_string(tPos, 2));
	end; -- for allSlots of player
end; -- SwissalpS.teleport.cc_listSlots

function SwissalpS.teleport.cc_saveSlot(sPlayer, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(sPlayer, sPrefix .. sSlot, tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'set slot (' .. sSlot .. ') to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_saveSlot

function SwissalpS.teleport.cc_saveSlotGlobal(sPlayer, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(
			SssStpS.db_global_player_name,
			sPrefix .. sSlot,
			tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'set global slot (' .. sSlot .. ') to: '
			.. minetest.pos_to_string(tPos, 1));
end; -- SwissalpS.teleport.cc_saveSlotGlobal

function SwissalpS.teleport.cc_setHome(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(sPlayer, sPrefix .. '_home_', tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'set your home to: '
			.. minetest.pos_to_string(tPos, 1));
end; -- SwissalpS.teleport.cc_setHome

function SwissalpS.teleport.cc_setHomeGlobal(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sPlayer);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(
			SssStpS.db_global_player_name,
			sPrefix .. '_home_',
			tPos);
	SwissalpS.info.notifyPlayer(sPlayer, 'set global home to: '
			.. minetest.pos_to_string(tPos, 1));
end; -- SwissalpS.teleport.cc_setHomeGlobal
