
function SwissalpS.teleport.cc_goHome(sName)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = SwissalpS.teleport.dbPlayer:get(
			sName,
			sPrefix .. '_home_',
			SssStpS.default_homePos);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sName, 'Moved you home');
end; -- SwissalpS.teleport.cc_goHome

function SwissalpS.teleport.cc_goHomeGlobal(sName)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = SwissalpS.teleport.dbPlayer:get(
			SssStpS.db_global_player_name,
			sPrefix .. '_home_',
			SssStpS.default_homePos);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sName, 'Moved you to global home');
end; -- SwissalpS.teleport.cc_goHomeGlobal

function SwissalpS.teleport.cc_goToSlot(sName, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local tPos = SwissalpS.teleport.dbPlayer:get(
			sName, sPrefix .. sSlot, 'nothing');
	if 'nothing' == tPos then
		SwissalpS.info.notifyPlayer(sName, 'no saved slot: ' .. sSlot);
		return;
	end;
	local oPlayer = minetest.get_player_by_name(sName);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sName, 'Moved you to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_goToSlot

function SwissalpS.teleport.cc_goToSlotGlobal(sName, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local tPos = SwissalpS.teleport.dbPlayer:get(
			SssStpS.db_global_player_name,
			sPrefix .. sSlot, 'nothing');
	if 'nothing' == tPos then
		SwissalpS.info.notifyPlayer(sName, 'no global slot: ' .. sSlot);
		return;
	end
	local oPlayer = minetest.get_player_by_name(sName);
	oPlayer:setpos(tPos);
	SwissalpS.info.notifyPlayer(sName, 'Moved you to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_goToSlotGlobal

function SwissalpS.teleport.cc_help(sName)
	local sHelp = '-tph/-tphome -tpsh/-tpsethome -tp <slot>'
			.. ' -tps/-tpset <slot> -tpl -tpgh/-tpghome'
			.. ' -tpgsh/-tpgsethome -tpg <slot> -tpgs/-tpgset <slot>';
	SwissalpS.info.notifyPlayer(sName, sHelp);
end; -- SwissalpS.teleport.cc_help

function SwissalpS.teleport.cc_listSlots(sName)
	local sPrefix = SssStpS.db_prefix_slot;
	local iPrefixLength = string.len(sPrefix);
	local iCount = 0;
	local sOut;
	local sSlot;
	local tAllSlots = {};
	-- get all the player's slots
	local tAll = SwissalpS.teleport.dbPlayer:getAll(sName, {});
	for sKey, mValue in pairs(tAll) do
		if sPrefix == string.sub(sKey, 1, iPrefixLength) then
			iCount = iCount +1;
			sSlot = string.sub(sKey, iPrefixLength +1);
			tAllSlots[sSlot] = mValue;
		end
	end -- loop filter out slots
	if 0 == iCount then
		sOut = 'no slots defined';
	else
		sOut = "Listing Player's Slots:";
	end -- if no slots
	SwissalpS.info.notifyPlayer(sName, sOut);
	for sSlot, tPos in pairs(tAllSlots) do
		SwissalpS.info.notifyPlayer(sName, 'slot: ' .. sSlot
				.. ' pos: '
				.. minetest.pos_to_string(tPos))
	end -- for allSlots of player
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
		end
	end -- loop filter out slots
	if 0 == iCount then
		sOut = 'no global slots';
	else
		sOut = 'Listing Global Slots:';
	end -- if got global slots
	SwissalpS.info.notifyPlayer(sName, sOut);
	for sSlot, tPos in pairs(tAllSlots) do
		SwissalpS.info.notifyPlayer(sName, 'slot: ' .. sSlot
				.. ' pos: '
				.. minetest.pos_to_string(tPos))
	end -- for allSlots of player
end -- SwissalpS.teleport.cc_listSlots

function SwissalpS.teleport.cc_saveSlot(sName, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(sName, sPrefix .. sSlot, tPos);
	SwissalpS.info.notifyPlayer(sName, 'set slot (' .. sSlot .. ') to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_saveSlot

function SwissalpS.teleport.cc_saveSlotGlobal(sName, sSlot)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(
			SssStpS.db_global_player_name,
			sPrefix .. sSlot,
			tPos);
	SwissalpS.info.notifyPlayer(sName, 'set global slot (' .. sSlot .. ') to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_saveSlotGlobal

function SwissalpS.teleport.cc_setHome(sName)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(sName, sPrefix .. '_home_', tPos);
	SwissalpS.info.notifyPlayer(sName, 'set your home to: '
			.. minetest.pos_to_string(tPos));
end; -- SwissalpS.teleport.cc_setHome

function SwissalpS.teleport.cc_setHomeGlobal(sName)
	local sPrefix = SssStpS.db_prefix_slot;
	local oPlayer = minetest.get_player_by_name(sName);
	local tPos = oPlayer:getpos();
	SwissalpS.teleport.dbPlayer:set(
			SssStpS.db_global_player_name,
			sPrefix .. '_home_',
			tPos);
	SwissalpS.info.notifyPlayer(sName, 'set global home to: '
			.. minetest.pos_to_string(oPos));
end; -- SwissalpS.teleport.cc_setHomeGlobal
