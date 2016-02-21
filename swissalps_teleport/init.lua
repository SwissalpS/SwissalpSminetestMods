
SwissalpS = SwissalpS or {}
SwissalpS.teleport = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_teleport',
    sSwissalpSmodTitle = 'teleport'
}
SwissalpS.info.timerStart(SwissalpS.teleport)

-- setup player db
SwissalpS.teleport.db_prefix_slot = '_SssS_tp_slot_'
-- the player name to use to store values for all players
SwissalpS.teleport.db_global_player_name = '__SwissalpS_Global_Player_Name__'
SwissalpS.teleport.db_strategies = {fs = {name = "SwissalpS_teleport", form = "json", place = "world"}}
SwissalpS.teleport.dbPlayer = SwissalpS.db.playerDB(SwissalpS.teleport.db_strategies)

SwissalpS.teleport.default_homePos = {x = -470, y = 15.5, z = 625}

minetest.register_privilege('SwissalpS_teleport_Global', 'Can set global teleport locations.')

local sPathMod = minetest.get_modpath(minetest.get_current_modname())
dofile(sPathMod .. '/chatCommandFunctions.lua')
dofile(sPathMod .. '/registerChatCommands.lua')

SwissalpS.info.timerDiffLog(SwissalpS.teleport)
