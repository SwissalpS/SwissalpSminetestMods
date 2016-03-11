
SwissalpS.doorsteward.setting = {};
local function setting(sType, sName, mDefault)
	local sNameFull = 'SwissalpS.doorsteward.' .. sName;
	local mValue = nil;
	if 'boolean' == sType or 'bool' == sType then
		mValue = minetest.setting_getbool(sNameFull);
	elseif 'string' == sType or 'str' == sType then
		mValue = minetest.setting_get(sNameFull);
	elseif 'position' == sType or 'pos' == sType then
		mValue = minetest.setting_get_pos(sNameFull);
	elseif 'number' == sType or 'num' == sType then
		mValue = tonumber(minetest.setting_get(sNameFull));
	else
		error('Invalid setting type.');
	end
	if nil == mValue then
		mValue = mDefault;
	end
	SwissalpS.doorsteward.setting[sName] = mValue;
end -- local setting

--------------
-- Settings --
--------------

--setting('string', 'filename', world_path .. DIR_DELIM .. 'foo.bar');
--setting('boolean',  'gotWood', false);
--setting('position', 'maxSize', {x = 22, y = 44, z = 44});
--setting('number',   'healthGain', 4);

-- setup player db
setting('string', 'db_prefix_slot', '');
-- the player name to use to store values for all players
setting('string', 'db_global_player_name', '__SwissalpS_Global_Player_Name__');
-- filename for player db
setting('string', 'db_strategies_fs_name', 'SwissalpS_doorsteward');
-- file format for player db
setting('string', 'db_strategies_fs_form', 'json');
-- path to player db
setting('string', 'db_strategies_fs_place', 'world');
SssSdsS = SwissalpS.doorsteward.setting;
SssSdsS.sMetaKeyGroups = 'swissalps_doorsteward_groups';
SssSdsS.sMetaKeyLeaveOpen = 'swissalps_doorsteward_leaveOpen';
SssSdsS.sMetaKeyActive = 'swissalps_doorsteward_active';
SssSdsS.db_strategies = {fs = {
        name = SssSdsS.db_strategies_fs_name,
        form = SssSdsS.db_strategies_fs_form,
		place = SssSdsS.db_strategies_fs_place,
}};
