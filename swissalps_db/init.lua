-- This is a library for Minetest mods
-- author: addi <addi at king-arhtur dot eu>
-- for documentation see : https://project.king-arthur.eu/projects/db/wiki
-- license: LGPL v3
-- SwissalpS could not get in touch with author, so here we
-- have bound it in to SwissalpS repo and modified to our liking

SwissalpS = SwissalpS or {};
SwissalpS.db = SwissalpS.db or {
    version = 0.3,
    sSwissalpSmodTag = 'mod_db',
    sSwissalpSmodTitle = 'db'
};
SwissalpS.info.timerStart(SwissalpS.db);

local sPathMod = minetest.get_modpath(minetest.get_current_modname());
dofile(sPathMod .. DIR_DELIM .. 'playerDB.lua');
dofile(sPathMod .. DIR_DELIM .. 'DB.lua');

SwissalpS.info.timerDiffLog(SwissalpS.db);
