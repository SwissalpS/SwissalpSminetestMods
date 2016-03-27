-- Minetest mod: swissalps_doorsteward
-- See LICENSE.txt and README.txt for licensing and other information.

SwissalpS = SwissalpS or {};
SwissalpS.doorsteward = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_doorsteward',
    sSwissalpSmodTitle = 'doorsteward',
};
SwissalpS.info.timerStart(SwissalpS.doorsteward);

SwissalpS.doorsteward.sPrivGlobal = 'SwissalpS_doorsteward_Global';
SwissalpS.doorsteward.sPrivGlobalDescription = 'May change any door.';
minetest.register_privilege(SwissalpS.doorsteward.sPrivGlobal,
							SwissalpS.doorsteward.sPrivGlobalDescription);

local sPathMod = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM;
dofile(sPathMod .. 'settings.lua');
dofile(sPathMod .. 'functions.lua');
dofile(sPathMod .. 'key.lua');
dofile(sPathMod .. 'chatCommandFunctions.lua');
dofile(sPathMod .. 'registerChatCommands.lua');

-- init db
SwissalpS.doorsteward.dbPlayer = SwissalpS.db.playerDB(SssSdsS.db_strategies);

SwissalpS.doorsteward.tABM = {
    nodenames = SwissalpS.doorsteward.doorBottoms(),
	interval = 1.0,
	chance = 1,
	action = SwissalpS.doorsteward.fABM,
};

minetest.register_abm(SwissalpS.doorsteward.tABM);

SwissalpS.info.timerDiffLog(SwissalpS.doorsteward);
