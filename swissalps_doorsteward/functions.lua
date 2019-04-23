-- Minetest mod: swissalps_doorsteward
-- See LICENSE.txt and README.txt for licensing and other information.

function SwissalpS.doorsteward.groupsOfPos(tPos)
	local tMeta = minetest.get_meta(tPos);
	local sKey = SwissalpS.doorsteward.setting.sMetaKeyGroups;
	local sGroups = tMeta:get_string(sKey) or '';
	return string.split(sGroups, ',');
end; -- SwissalpS.doorsteward.groupsOfPos

function SwissalpS.doorsteward.groupsOfPlayer(sPlayer)
	local sGroupsPlayer = SwissalpS.doorsteward.dbPlayer:get(sPlayer, 'groups', '');
	return string.split(sGroupsPlayer, ',');
end; -- SwissalpS.doorsteward.groupsOfPlayer

function SwissalpS.doorsteward.mayChange(tPos, sPlayer)
	if sPlayer and minetest.check_player_privs(sPlayer, {server = true}) then
		return true;
	end; -- admin may change anything
	if sPlayer and minetest.check_player_privs(sPlayer,
							{[SwissalpS.doorsteward.sPrivGlobal] = true}) then
		return true;
	end; -- global door steward admin may change any door
	-- owner may always change his doors
	local tMeta = minetest.get_meta(tPos);
	local sOwner = tMeta:get_string('owner') or '';
	if sPlayer == sOwner then
		return true;
	end; -- if owner
	local aGroups = SwissalpS.doorsteward.groupsOfPos(tPos);
	local aGroupsPlayer = SwissalpS.doorsteward.groupsOfPlayer(sPlayer);
	for iIndex, sGroup in pairs(aGroups) do
		for iIndexPlayer, sGroupPlayer in pairs(aGroupsPlayer) do
			if sGroupPlayer == sGroup .. '_admin' then
				return true;
			end; -- if found a match
		end; -- loop groups of player
	end; -- loop groups of node
	-- fall-back to protection rule
	return not minetest.is_protected(tPos, sPlayer);
end; -- SwissalpS.doorsteward.mayChange

function SwissalpS.doorsteward.mayOpen(tPos, sPlayer)
	if sPlayer and minetest.check_player_privs(sPlayer, {server = true}) then
		return true;
	end; -- admin may open anything
	-- first check for door steward groups
	local aGroups = SwissalpS.doorsteward.groupsOfPos(tPos);
	local aGroupsPlayer = SwissalpS.doorsteward.groupsOfPlayer(sPlayer);
	for iIndex, sGroup in pairs(aGroups) do
		for iIndexPlayer, sGroupPlayer in pairs(aGroupsPlayer) do
			if sGroupPlayer == sGroup then
				return true;
			end; -- if found a match
		end; -- loop groups of player
	end; -- loop groups of node
	-- fall-back to normal door behaviour
	local tMeta = minetest.get_meta(tPos);
	local sOwner = tMeta:get_string('owner') or '';
	if '' == sOwner then
		return true;
	end; -- if no owner, anybody may open and close
	return sOwner == sPlayer;
end; -- SwissalpS.doorsteward.mayOpen

--!! do not use, can't get position from oNodeDoor
function SwissalpS.doorsteward:close(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as door-node');
    local bOut = nil;
    local bOpen = self:isOpen(oNodeDoor);
    if not bOpen then return false; end;
    return self:toggle(oNodeDoor:getpos(), oNodeDoor);
end; -- SwissalpS.doorsteward.close

function SwissalpS.doorsteward.registeredDoors()
	local aOut = {};
	for sName, _ in pairs(doors.registered_doors) do
		table.insert(aOut, sName);
	end; -- loop all doors
	return aOut;
end; -- SwissalpS.doorsteward.registeredDoors

--!! old -> use SwissalpS.doorsteward.registeredDoors()
function SwissalpS.doorsteward.doorBottoms()
	local aOut = {};
	local bIsTrapdoor = false;
	for sKey, mValue in pairs(minetest.registered_nodes) do
		if 1 == string.find(sKey, 'doors:trapdoor') then
			bIsTrapdoor = true;
		else
			bIsTrapdoor = false;
		end; -- if is trapdoor
		if not bIsTrapdoor then
			if 'doors:' == string.sub(sKey, 1, 6) then
				if string.find(sKey, '_b_') then
--print('inserting into doorBottoms: ', sKey);
					table.insert(aOut, sKey);
					table.insert(aOut, sKey);
				end; -- if is a bottom
			end; -- if found a door
		end; -- if is not trapdoor
	end; -- loop all node types
	return aOut;
end; -- SwissalpS.doorsteward.doorBottoms

--!! do not use, can't get position from oNodeDoor
function SwissalpS.doorsteward:open(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as door-node');
    local bOpen = self:isOpen(oNodeDoor);
    if bOpen then return false; end;
    local tAll = {}
	for sKey, value in pairs(oNodeDoor) do
		table.insert(tAll, sKey);
	end;
	table.sort(tAll);
	for iIndex, sKey in pairs(tAll) do
		print('oNodeDoor.' .. sKey .. ' ' .. tostring(oNodeDoor[sKey]));
	end;
    print(oNodeDoor);
    --assert(nil ~= oNodeDoor.object, 'NIL passed as door-node.object');
    return self:toggle(oNodeDoor:getpos(), oNodeDoor);
end; -- SwissalpS.doorsteward.open

--!! old
function SwissalpS.doorsteward:toggle(tPos, oNodeDoor)
    local tParams, sReplaceBottom, sReplaceTop;
    local p2 = oNodeDoor.param2;
    if nil == p2 then
        SwissalpS.info.broadcast('nil param2 in SwissalpS.doorsteward.toggle');
    end;
    local sNameDoorFull = oNodeDoor.name;
    local sNameDoor = string.sub(sNameDoorFull, 1, -5);
    local bOpen = ('2' == string.sub(sNameDoorFull, -1));
    local bBottom = ('b' == string.sub(sNameDoorFull, -3, -3));
    if bOpen then
        -- close it
        tParams = {3, 0, 1, 2};
        sReplaceBottom = sNameDoor .. '_b_1';
        sReplaceTop = sNameDoor .. '_t_1';
    else
        -- open it
        tParams = {1, 2, 3, 0};
        sReplaceBottom = sNameDoor .. '_b_2';
        sReplaceTop = sNameDoor .. '_t_2';
    end -- if open or closed
	p2 = tParams[p2 + 1];
    if not bBottom then
        -- correct tPos
        tPos.y = tPos.y - 1;
    end -- if top node given, jic we find use for this giving top-nodes
    -- replace bottom node
    minetest.swap_node(tPos, {name = sReplaceBottom, param2 = p2});
    -- move up one node and replace top
    tPos.y = tPos.y + 1;
    minetest.swap_node(tPos, {name = sReplaceTop, param2 = p2});

	-- play sound
	local sSound = "_open";
	if bOpen then
		sSound = "_close";
	end
	minetest.sound_play("door" .. sSound, {pos = tPos, gain = 0.3,
										   max_hear_distance = 10});
    return self;
end; -- SwissalpS.doorsteward:toggle

--!! old
function SwissalpS.doorsteward:isBottomNode(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as oNodeDoor');
    local sNameDoorFull = oNodeDoor.name;
    assert(nil ~= sNameDoorFull
           and '' ~= sNameDoorFull,
           'invalid object passed or no name set');
    assert(7 <= #sNameDoorFull,
           'invalid name on given object');
    return ('b' == string.sub(sNameDoorFull, -3, -3));
end; -- SwissalpS.doorsteward:isBottomNode

--!! old
function SwissalpS.doorsteward:isDoor(oNode)
	assert(nil ~= oNode and nil ~= oNode.name, 'Invalid node passed');
	local sName = oNode.name;
	if 1 == string.find(sName, 'doors:trapdoor') then
		-- basically a door, but not one we work with yet
		return false;
	end; -- if trapdoor given
	if 'doors:' == string.sub(sName, 1, 6) then
		return true;
	end; -- if door found
	return false;
end; -- SwissalpS.doorsteward:isDoor

--!! old
function SwissalpS.doorsteward:isOpen(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as oNodeDoor');
    local sNameDoorFull = oNodeDoor.name;
    assert(nil ~= sNameDoorFull
           and '' ~= sNameDoorFull,
           'invalid object passed or no name set');
    assert(7 <= #sNameDoorFull,
           'invalid name on given object');
	-- TODO: check if is_right
    return ('2' == string.sub(sNameDoorFull, -1));
end; -- SwissalpS.doorsteward:isOpen

function SwissalpS.doorsteward.fABM(tPos, oNodeDoor, iCountActiveObject, iCountActiveObjectWider)
	local sKeyActive = SwissalpS.doorsteward.setting.sMetaKeyActive;
	-- determine whether door is active or not
	local tMeta = minetest.get_meta(tPos);
	local sActive = tMeta:get_string(sKeyActive) or 'true';
	local bActive = not ('false' == sActive);
	if not bActive then
		return;
	end; -- if not active door
	local sKeyLeaveOpen = SwissalpS.doorsteward.setting.sMetaKeyLeaveOpen;
	local sLeaveOpen = tMeta:get_string(sKeyLeaveOpen) or 'false';
	local bLeaveOpen = 'true' == sLeaveOpen;
    -- determine if door is open or not
    local oDoor = doors.get(tPos);
    --if nil == oDoor then
    --	print('this should not have happened');
    --	return;
    --end;
    local bOpen = oDoor:state();
	-- collect nearby players
    local iCountPlayers = 0;
    local tObjects = minetest.get_objects_inside_radius(tPos, 2);
    local sName;
    local tNames = {}; -- maybe we can use a list of names too
    local tPlayers = {};
    for iKey, oPlayer in pairs(tObjects) do
        sName = oPlayer:get_player_name();
        if nil ~= sName then
            iCountPlayers = iCountPlayers +1;
            table.insert(tNames, sName);
            table.insert(tPlayers, oPlayer);
        end;
    end; -- loop all objects in radius
	-- determine whether to toggle state
    if bOpen then
        -- door is open
        if 0 == iCountPlayers then
            -- has NO players nearby -> close door
			if bLeaveOpen then
				return;
			end; -- if leave open
--SwissalpS.info.broadcast('door is open and 0 players nearby');
			-- TODO: check which player last was near door?
            --return SwissalpS.doorsteward:close(minetest.get_node_or_nil(tPos));
            --return SwissalpS.doorsteward:toggle(tPos, oNodeDoor);
            return oDoor:close();
        end; -- if no players
    else
        -- door is closed
        if 0 < iCountPlayers then
--SwissalpS.info.broadcast('door is closed and ' .. iCountPlayers .. ' players nearby')
            -- has players nearby -> open door ... if..
			-- any of their names match the owner or privs match
			for iIndex, sPlayer in pairs(tNames) do
				if SwissalpS.doorsteward.mayOpen(tPos, sPlayer) then
					--return SwissalpS.doorsteward:open(minetest.get_node_or_nil(tPos));
					--return SwissalpS.doorsteward:toggle(tPos, oNodeDoor);
					return oDoor:open();
				end;
			end; -- loop all nearby players to see if one is allowed to open
        end; -- if got players
    end; -- if open or closed
end; -- SwissalpS.doorsteward.fABM
