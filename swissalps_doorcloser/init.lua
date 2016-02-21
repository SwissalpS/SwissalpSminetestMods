
SwissalpS = SwissalpS or {}
SwissalpS.doorcloser = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_doorcloser',
    sSwissalpSmodTitle = 'doorcloser'
}
SwissalpS.info.timerStart(SwissalpS.doorcloser)

function SwissalpS.doorcloser.fABM(tPos, oNode, active_object_count, active_object_count_wider)
    local oMeta = minetest.env:get_meta(tPos)
    SwissalpS.info.broadcast(oMeta:get_string('state'))
    --[[if 0 >= oMeta:get_float('enabled') then
        print('hohohho')
        return false
    end
    --]]
    local tObjects = minetest.env:get_objects_inside_radius(tPos, 1)
    local sName
    for iKey, oPlayer in pairs(tObjects) do
        sName = oPlayer:get_player_name()
        if nil ~= sName then
            SwissalpS.info.notifyPlayer(sName, 'doorcloser says hi')
        end
    end
end -- SwissalpS.doorcloser.fABM

SwissalpS.doorcloser.tABM = {
    nodenames = {'doors:door_wood', 'doors:door_wood_b_1', 'doors:door_wood_t_1'},
	interval = 1.0,
	chance = 1,
	action = SwissalpS.doorcloser.fABM
}

minetest.register_abm(SwissalpS.doorcloser.tABM)

SwissalpS.info.timerDiffLog(SwissalpS.doorcloser)
