
SwissalpS = SwissalpS or {}
SwissalpS.doorsteward = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_doorsteward',
    sSwissalpSmodTitle = 'doorsteward',
}
SwissalpS.info.timerStart(SwissalpS.doorsteward);

local sPathMod = minetest.get_modpath(minetest.get_current_modname());
dofile(sPathMod .. DIR_DELIM .. 'settings.lua');

--!! do not use, can't get position from oNodeDoor
function SwissalpS.doorsteward:close(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as door-node');
    local bOut = nil
    local bOpen = self:isOpen(oNodeDoor);
    if not bOpen then return false; end
    return self:toggle(oNodeDoor:getpos(), oNodeDoor);
end -- SwissalpS.doorsteward.close

--!! do not use, can't get position from oNodeDoor
function SwissalpS.doorsteward:open(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as door-node');
    local bOpen = self:isOpen(oNodeDoor);
    if bOpen then return false; end
    local tAll = {}
	for sKey, value in pairs(oNodeDoor) do
		table.insert(tAll, sKey)
	end
	table.sort(tAll)
	for iIndex, sKey in pairs(tAll) do
		print('oNodeDoor.' .. sKey .. ' ' .. tostring(oNodeDoor[sKey]));
	end
    print(oNodeDoor);
    --assert(nil ~= oNodeDoor.object, 'NIL passed as door-node.object');
    return self:toggle(oNodeDoor:getpos(), oNodeDoor);
end -- SwissalpS.doorsteward.open

function SwissalpS.doorsteward:toggle(tPos, oNodeDoor)
    local tParams, sReplaceBottom, sReplaceTop
    local p2 = oNodeDoor.param2
    if nil == p2 then
        SwissalpS.info.broadcast('nil param2 in SwissalpS.doorsteward.toggle')
    end
    local sNameDoorFull = oNodeDoor.name
    local sNameDoor = string.sub(sNameDoorFull, 1, -5)
    local bOpen = ('2' == string.sub(sNameDoorFull, -1))
    local bBottom = ('b' == string.sub(sNameDoorFull, -3, -3))
    if bOpen then
        -- close it
        tParams = {3, 0, 1, 2}
        sReplaceBottom = sNameDoor .. '_b_1'
        sReplaceTop = sNameDoor .. '_t_1'
    else
        -- open it
        tParams = {1, 2, 3, 0}
        sReplaceBottom = sNameDoor .. '_b_2'
        sReplaceTop = sNameDoor .. '_t_2'
    end -- if open or closed
	p2 = tParams[p2 + 1]
    if not bBottom then
        -- correct tPos
        tPos.y = tPos.y - 1
    end -- if top node given, jic we find use for this giving top-nodes
    -- replace bottom node
    minetest.swap_node(tPos, {name = sReplaceBottom, param2 = p2})
    -- move up one node and replace top
    tPos.y = tPos.y + 1
    minetest.swap_node(tPos, {name = sReplaceTop, param2 = p2})
    return self
end -- SwissalpS.doorsteward:toggle

function SwissalpS.doorsteward:isBottomNode(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as oNodeDoor');
    local sNameDoorFull = oNodeDoor.name;
    assert(nil ~= sNameDoorFull
           and '' ~= sNameDoorFull,
           'invalid object passed or no name set');
    assert(7 <= #sNameDoorFull,
           'invalid name on given object');
    return ('b' == string.sub(sNameDoorFull, -3, -3));
end -- SwissalpS.doorsteward:isBottomNode

function SwissalpS.doorsteward:isOpen(oNodeDoor)
    assert(nil ~= oNodeDoor, 'NIL passed as oNodeDoor');
    local sNameDoorFull = oNodeDoor.name;
    assert(nil ~= sNameDoorFull
           and '' ~= sNameDoorFull,
           'invalid object passed or no name set');
    assert(7 <= #sNameDoorFull,
           'invalid name on given object');
    return ('2' == string.sub(sNameDoorFull, -1));
end -- SwissalpS.doorsteward:isOpen

function SwissalpS.doorsteward.fABM(tPos, oNodeDoor, iCountActiveObject, iCountActiveObjectWider)
    -- determine if door is open or not
    local sNameDoor = oNodeDoor.name;
    local bOpen = ('2' == string.sub(sNameDoor, -1));
    local iCountPlayers = 0;
    local tObjects = minetest.env:get_objects_inside_radius(tPos, 2);
    local sName
    local tNames = {}
    local tPlayers = {}
    for iKey, oPlayer in pairs(tObjects) do
        sName = oPlayer:get_player_name()
        if nil ~= sName then
            iCountPlayers = iCountPlayers +1
            table.insert(tNames, sName)
            table.insert(tPlayers, oPlayer)
        end
    end -- loop all objects in radius

    if bOpen then
        -- door is open
        if 0 == iCountPlayers then
            -- has NO players nearby -> close door
--SwissalpS.info.broadcast('door is open and 0 players nearby')
            return SwissalpS.doorsteward:close(minetest.get_node_or_nil(tPos));
            --return SwissalpS.doorsteward:toggle(tPos, oNodeDoor)
        end
    else
        -- door is closed
        if 0 < iCountPlayers then
            -- has players nearby -> open door ... if..
--SwissalpS.info.broadcast('door is closed and ' .. iCountPlayers .. ' players nearby')
            return SwissalpS.doorsteward:open(minetest.get_node_or_nil(tPos));
            --return SwissalpS.doorsteward:toggle(tPos, oNodeDoor)
        end
    end -- if open or closed
    --[[
    local oMeta = minetest.env:get_meta(tPos)if 0 >= oMeta:get_float('enabled') then
        print('hohohho')
        return false
    end
    --]]
end -- SwissalpS.doorsteward.fABM

SwissalpS.doorsteward.tABM = {
    nodenames = {'doors:door_wood_b_1', 'doors:door_wood_b_2'},
	interval = 1.0,
	chance = 1,
	action = SwissalpS.doorsteward.fABM
}

minetest.register_abm(SwissalpS.doorsteward.tABM)

SwissalpS.info.timerDiffLog(SwissalpS.doorsteward)
