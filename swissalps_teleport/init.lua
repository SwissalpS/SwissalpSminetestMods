
SwissalpS = SwissalpS or {}
SwissalpS.teleport = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_teleport',
    sSwissalpSmodTitle = 'teleport',
}
SwissalpS.info.timerStart(SwissalpS.teleport)

SssStp = SwissalpS.teleport;
-- setup player db
SwissalpS.teleport.settings = {
    db_prefix_slot = '_SssS_tp_slot_',
    -- the player name to use to store values for all players
    db_global_player_name = '__SwissalpS_Global_Player_Name__',
    db_strategies = {fs = {
        name = 'SwissalpS_teleport',
        form = 'json', place = 'world'}},
    default_homePos = {x = -470, y = 15.5, z = 625},
};
SssStpS = SssStp.settings;
SwissalpS.teleport.dbPlayer = SwissalpS.db.playerDB(SssStpS.db_strategies);
SwissalpS.teleport.sPrivGlobal = 'SwissalpS_teleport_Global';
SwissalpS.teleport.sPrivGlobalDescription = 'May set global teleport locations.';

minetest.register_privilege(SssStp.sPrivGlobal, SssStp.sPrivGlobalDescription);

local sPathMod = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM;
dofile(sPathMod .. 'chatCommandFunctions.lua');
dofile(sPathMod .. 'registerChatCommands.lua');

SwissalpS.info.timerDiffLog(SwissalpS.teleport);
