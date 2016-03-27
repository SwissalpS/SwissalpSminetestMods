-- This is a library for Minetest mods
-- author: addi <addi at king-arhtur dot eu>
-- for documentation see : https://project.king-arthur.eu/projects/db/wiki
-- license: LGPL v3
-- SwissalpS could not get in touch with author, so here we
-- have bound it in to SwissalpS repo and modified to our liking

SwissalpS.db.DB = {};
SwissalpS.db.DB.__index = SwissalpS.db.DB;
setmetatable(SwissalpS.db.DB, {
	__call = function (oClass, ...);
		return oClass.new(...);
	end,
});

function SwissalpS.db.DB.new(tStrategies)
	local sMethod = 'mod:SwissalpS.db.DB.new: ';
	local self = setmetatable({}, SwissalpS.db.DB);

	if nil == tStrategies then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.newNil);
	end;
	self.tStrategies = tStrategies or {};

	if self.tStrategies.fs then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.newFS);
		local sPath = '';
		if 'world' == self.tStrategies.fs.place then
			sPath = minetest.get_worldpath();
		else
			sPath = self.tStrategies.fs.place;
		end;
		self.sPathFile = sPath .. DIR_DELIM .. self.tStrategies.fs.name
				.. '.' .. self.tStrategies.fs.format;
	end; -- if fs

	-- these are not yet implemented
	if self.tStrategies.mysql then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadySQLite);
	end;

	self.storage = {};
	self:load();
	print(sMethod .. 'instance of DB created');

	return self;

end; -- SwissalpS.db.DB.new

function SwissalpS.db.DB:save()
	local sMethod = 'mod:SwissalpS.db.DB:save: ';
	if self.tStrategies.fs then
		local rOutput = io.open(self.sPathFile, 'w');
		if 'json' == self.tStrategies.fs.format then
			rOutput:write(minetest.write_json(self.storage, true));
		elseif 'minetest' == self.tStrategies.fs.format then
			rOutput:write(minetest.serialize(self.storage));
		end;
		io.close(rOutput);
	end;
	-- these are not yet implemented
	if self.tStrategies.mysql then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadySQLite);
	end;
	return self;
end; -- SwissalpS.db.DB:save

function SwissalpS.db.DB:load()
	local sMethod = 'mod:SwissalpS.db.DB:load: ';
	if self.tStrategies.fs then
		print(sMethod .. 'loading DB from file' .. self.sPathFile);
		local rInput = io.open(self.sPathFile, 'r');
		local sData = nil;
		if rInput then
			sData = rInput:read('*all');
		end;
		if sData and '' ~= sData then
			if 'json' == self.tStrategies.fs.format then
				local json = minetest.parse_json(sData);
				self.storage = json or {};
			elseif 'minetest' == self.tStrategies.fs.format then
				local deserialized = minetest.deserialize(sData);
				self.storage = deserialized or {};
			end;
			io.close(rInput);
		end; -- if got data
	end; -- if fs
	-- these are not yet implemented
	if self.tStrategies.mysql then
		print(sMethod .. playerDB.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. playerDB.errorStrings.notReadySQLite);
	end;
	return self;
end; -- SwissalpS.db.DB:load

function SwissalpS.db.DB:set(sKey, mValue)
	local sMethod = 'mod:SwissalpS.db.DB:set: ';
	assert('string' == type(sKey), sMethod .. 'param 1, sKey,' .. playerDB.errorStrings.paramKey);
	local sTV = type(mValue);
	assert('string' == sTV or 'number' == sTV or 'table' == sTV or 'boolean' == sTV,
		   sMethod .. 'param 2, mValue,' .. playerDB.errorStrings.paramValue);
	self.storage[sKey] = mValue;
	self:save();
	return self;
end; -- SwissalpS.db.DB:set

function SwissalpS.db.DB:get(sKey, mDefault)
	local sMethod = 'mod:SwissalpS.db.DB:get: ';
	assert('string' == type(sKey),
		   sMethod .. 'param 1, sKey,' .. playerDB.errorStrings.paramKey);
	local sTD = type(mDefault);
	assert('string' == sTD or 'number' == sTD or 'table' == sTD or 'boolean' == sTD,
		   sMethod .. 'param 2, mDefault,' .. playerDB.errorStrings.paramDefault);
	if self.storage[sKey] then
		return self.storage[sKey];
	end;
	--print(sMethod .. 'nothing found, returning default');
	return mDefault;
end; -- SwissalpS.db.DB:get

function SwissalpS.db.DB:getAll(tDefault)
	local sMethod = 'mod:SwissalpS.db.DB:getAll: ';
	local sTD = type(tDefault);
	assert('string' == sTD or 'number' == sTD or 'table' == sTD or 'boolean' == sTD,
		   sMethod .. 'param 1, tDefault,' .. playerDB.errorStrings.paramDefault);
	if self.storage then
		return self.storage;
	end;
	--print(sMethod .. 'nothing found, returning default')
	return tDefault;
end; -- DB:getAll
