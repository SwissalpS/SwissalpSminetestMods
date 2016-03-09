
SwissalpS = SwissalpS or {}
SwissalpS.doorsteward = {
    version = 0.1,
    sSwissalpSmodTag = 'mod_doorsteward',
    sSwissalpSmodTitle = 'doorsteward',
}
SwissalpS.info.timerStart(SwissalpS.doorsteward);

local sPathMod = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM;
dofile(sPathMod .. 'settings.lua');
dofile(sPathMod .. 'functions.lua');

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
