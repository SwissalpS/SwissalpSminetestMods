
SwissalpS = SwissalpS or {}
SwissalpS.doorsteward = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_doorsteward',
    sSwissalpSmodTitle = 'doorsteward'
}
SwissalpS.info.timerStart(SwissalpS.doorsteward)

function SwissalpS.doorsteward.toggle(tPos, oNodeDoorBottom)
    local tParams, sReplaceBottom, sReplaceTop
    local p2 = oNodeDoorBottom.param2
    if nil == p2 then
        SwissalpS.info.broadcast('nil param2 in SwissalpS.doorsteward.toggle')
    end
    local sNameDoorFull = oNodeDoorBottom.name
    local iLen = string.len(sNameDoorFull)
    local sNameDoor = string.sub(sNameDoorFull, 1, iLen - 4)
    local bOpen = ('2' == string.sub(sNameDoorFull, iLen))
    local bBottom = ('b' == string.sub(sNameDoorFull, iLen - 2, iLen - 2))
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
--local sBottom = 'false'
--if bBottom then sBottom = 'true' end
--local sOpen = 'false'
--if bOpen then sOpen = 'true' end
--SwissalpS.info.broadcast('sss '..ssss..' p2 '..p2..' len'..iLen..' sNameDoor '..sNameDoor..' sRepB '..sReplaceBottom..' sRepT '..sReplaceTop..' bopen '..sOpen..' bB '..sBottom)
	p2 = tParams[p2 + 1]
    if not bBottom then
        -- correct tPos
        tPos.y = tPos.y - 1
    end -- if bottom or top
    minetest.swap_node(tPos, {name = sReplaceBottom, param2 = p2})
    tPos.y = tPos.y + 1
    minetest.swap_node(tPos, {name = sReplaceTop, param2 = p2})
end -- SwissalpS.doorsteward.toggle

function SwissalpS.doorsteward.fABM(tPos, oNode, active_object_count, active_object_count_wider)

    -- determine if door is open or not
    local sNameDoor = oNode.name
    local iLen = string.len(sNameDoor)
    local bOpen = ('2' == string.sub(sNameDoor, iLen))

    local iCountPlayers = 0
    local tObjects = minetest.env:get_objects_inside_radius(tPos, 2)
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
            SwissalpS.doorsteward.toggle(tPos, oNode)
        end
    else
        -- door is closed
        if 0 < iCountPlayers then
            -- has players nearby -> open door ... if..
--SwissalpS.info.broadcast('door is closed and ' .. iCountPlayers .. ' players nearby')
            SwissalpS.doorsteward.toggle(tPos, oNode)
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
