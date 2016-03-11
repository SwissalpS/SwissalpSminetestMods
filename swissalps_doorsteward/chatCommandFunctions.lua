function SwissalpS.doorsteward.cc_addPlayersToGroups(sName, sPlayers, sGroups)
	local aPlayersRaw = string.split(sPlayers, ',');
	local aPlayers = {};
	local aGroupsRaw = string.split(sGroups, ',');
	local aGroups = {};
	-- cleanup players
	for _, sPlayerRaw in pairs(aPlayersRaw) do
		local sPlayer = string.trim(sPlayerRaw);
		--TODO: check validity
		table.insert(aPlayers, sPlayer);
	end; -- loop all player names
	-- cleanup groups
	for _, sGroupRaw in pairs(aGroups) do
		local sGroup = string.trim(sGroupRaw);
		--TODO: check validity
		table.insert(aGroups, sGroup);
	end; -- loop all given group names
	-- add missing groups to each player
	for _, sPlayer in pairs(aPlayers) do
		local aPlayerGroups = SwissalpS.doorsteward.groupsOfPlayer(sPlayer);
		for _, sGroup in pairs(aGroups) do
			if false == table.containsString(aPlayerGroups, sGroup) then
				table.insert(aPlayerGroups, sGroup);
			end; -- if not yet in players groups
		end; -- loop all groups to be added
		table.sort(aPlayerGroups);
		local sPlayerGroupsNew = table.implodeStrings(aPlayerGroups, ',');
		-- set players groups
		SwissalpS.doorsteward.dbPlayer:set(sPlayer, 'groups', sPlayerGroupsNew);
	end; -- loop all given players
	SwissalpS.info.notifyPlayer(sName, 'Added ' .. #aPlayers .. ' Players to '
								.. #aGroups .. ' Groups');
end --SwissalpS.doorsteward.cc_addPlayersToGroups

function SwissalpS.doorsteward.cc_removePlayersFromGroups(sName, sPlayers, tGroups)
	local aPlayersRaw = string.split(sPlayers, ',');
	local aPlayers = {};
	local aGroupsRaw = string.split(sGroups, ',');
	local aGroups = {};
	-- cleanup players
	for _, sPlayerRaw in pairs(aPlayersRaw) do
		local sPlayer = string.trim(sPlayerRaw);
		--TODO: check validity
		table.insert(aPlayers, sPlayer);
	end; -- loop all player names
	-- cleanup groups
	for _, sGroupRaw in pairs(aGroups) do
		local sGroup = string.trim(sGroupRaw);
		--TODO: check validity
		table.insert(aGroups, sGroup);
	end; -- loop all given group names
	-- remove matching groups from each player
	for _, sPlayer in pairs(aPlayers) do
		local aPlayerGroups = SwissalpS.doorsteward.groupsOfPlayer(sPlayer);
		local aPlayerGroupsNew = {};
		-- loop player's groups and add those again if not in given list
		for _, sGroup in pairs(aPlayerGroups) do
			if false == table.containsString(aGroups, sGroup) then
				table.insert(aPlayerGroupsNew, sGroup);
			end; -- if not in given groups
		end; -- loop all groups already member of
		table.sort(aPlayerGroupsNew);
		local sPlayerGroupsNew = table.implodeStrings(aPlayerGroupsNew, ',');
		-- set players groups
		SwissalpS.doorsteward.dbPlayer:set(sPlayer, 'groups', sPlayerGroupsNew);
	end; -- loop all given players
	SwissalpS.info.notifyPlayer(sName, 'Removed ' .. #aPlayers .. ' Players from '
								.. #aGroups .. ' Groups');
end --SwissalpS.doorsteward.cc_removePlayersFromGroupss

function SwissalpS.doorsteward.cc_listPlayerGroups(sName, sPlayer)
	if nil == sPlayer or '' == sPlayer then
		sPlayer = sName;
	end; -- if no player given, fallback to caller
	local aGroups = SwissalpS.doorsteward.groupsOfPlayer(sPlayer);
	local sGroups = table.implodeStrings(aGroups, ', ');
	SwissalpS.info.notifyPlayer(sName, 'Player ' .. sPlayer .. ' is a member of following SwissalpS_doorsteward Groups:' .. "\n" .. sGroups);
end --SwissalpS.doorsteward.cc_listPlayerGroups
