-- Minetest mod: swissalps_teleport
-- See LICENSE.txt and README.txt for licensing and other information.

if not minetest.global_exists('SwissalpS') then
	SwissalpS = {};
end;
SwissalpS.teleport = {
    version = 0.3,
    sSwissalpSmodTag = 'mod_teleport',
    sSwissalpSmodTitle = 'teleport',
};
SwissalpS.info.timerStart(SwissalpS.teleport);

SssStp = SwissalpS.teleport;
-- set-up player db
SwissalpS.teleport.settings = {
    db_prefix_slot = '_SssS_tp_slot_',
    -- the player name to use to store values for all players
    db_global_player_name = '__SwissalpS_Global_Player_Name__',
    db_strategies = {fs = {
        name = 'SwissalpS_teleport',
        format = 'json', place = 'world'}},
    -- the position a new teleporter points to
    padDefaultPosition = {x = 0, y = 0, z = 0},
    -- the default destination title
    padDefaultTitle = 'Spawning Area',
    default_homePos = {x = -470, y = 15.5, z = 625},
};
SssStpS = SssStp.settings;
SwissalpS.teleport.dbPlayer = SwissalpS.db.playerDB(SssStpS.db_strategies);
SwissalpS.teleport.sPrivGlobal = 'SwissalpS_teleport_Global';
SwissalpS.teleport.sPrivGlobalDescription = 'May set global teleport locations.';
SwissalpS.teleport.sPrivPadRandom = 'SwissalpS_teleport_Random';
SwissalpS.teleport.sPrivPadRandomDescription = 'May set teleporter-pads to point somewhere random.';

minetest.register_privilege(SssStp.sPrivGlobal, SssStp.sPrivGlobalDescription);
minetest.register_privilege(SssStp.sPrivPadRandom, SssStp.sPrivPadRandomDescription);

local sPathMod = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM;
dofile(sPathMod .. 'chatCommandFunctions.lua');
dofile(sPathMod .. 'registerChatCommands.lua');
dofile(sPathMod .. 'pad.lua');

SwissalpS.info.timerDiffLog(SwissalpS.teleport);
