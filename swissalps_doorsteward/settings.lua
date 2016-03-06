
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
