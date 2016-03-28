-- This is a library for Minetest mods
-- author: addi <addi at king-arhtur dot eu>
-- for documentation see : https://project.king-arthur.eu/projects/db/wiki
-- license: LGPL v3
-- SwissalpS could not get in touch with author, so here we
-- have bound it in to SwissalpS repo and modified to our liking

SwissalpS = SwissalpS or {};
SwissalpS.db = SwissalpS.db or {};

SwissalpS.db.playerDB = {};
SwissalpS.db.playerDB.__index = SwissalpS.db.playerDB;
setmetatable(SwissalpS.db.playerDB, {
	__call = function (oClass, ...)
		return oClass.new(...);
	end,
});

-- declare some error strings for simple reuse
SwissalpS.db.playerDB.errorStrings = {};
SwissalpS.db.playerDB.errorStrings.newNil =
	' WARNING: tStrategies is nil, so the database is only temporarily available,'
	.. ' and will be deleted at shut-down.';
SwissalpS.db.playerDB.errorStrings.newFS = ' database store on file system.';
SwissalpS.db.playerDB.errorStrings.notReadyMySQL =
	' MySQL support is not yet coded.';
SwissalpS.db.playerDB.errorStrings.notReadySQLite =
	' SQLite support is not yet coded.';
SwissalpS.db.playerDB.errorStrings.paramPlayer =
	' must be the player-name or a player object!';
SwissalpS.db.playerDB.errorStrings.paramKey = ' must be a string!';
SwissalpS.db.playerDB.errorStrings.paramValue =
	' must be a string, number, table or a boolean value. Userdata, functions '
	.. 'and nil are not allowed!';
SwissalpS.db.playerDB.errorStrings.paramDefault =
	SwissalpS.db.playerDB.errorStrings.paramValue;

function SwissalpS.db.playerDB.new(tStrategies)
	local sMethod = 'mod:SwissalpS.db.playerDB.new: ';
	-- init metatable
	local self = setmetatable({}, SwissalpS.db.playerDB);
	-- warn if memory only
	if nil == tStrategies then
		print(sMethod .. self.errorStrings.newNil);
	end;
	-- init by strategy
	self.tStrategies = tStrategies or {};
	if self.tStrategies.fs then
		print(sMethod .. self.errorStrings.newFS);
		local sPath = '';
		if 'world' == self.tStrategies.fs.place then
			sPath = minetest.get_worldpath();
		else
			sPath = self.tStrategies.fs.place;
		end;
		-- concatenate our path-to-file
		self.sPathFile = sPath .. DIR_DELIM .. self.tStrategies.fs.name
				.. '.' .. self.tStrategies.fs.format;
	end; -- if file strategy
	-- these are not yet implemented
	if self.tStrategies.mysql then
		print(sMethod .. self.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite);
	end;
	-- init storage and load
	self.storage = {};
	self:load();
	print(sMethod .. 'instance of playerDB created');
	-- return initialized playerDB object
	return self;
end; -- SwissalpS.db.playerDB.new

function SwissalpS.db.playerDB:save()
	local sMethod = 'mod:SwissalpS.db.playerDB:save: ';
	-- save by strategy
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
		print(sMethod .. self.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite);
	end;
	return self;
end; -- SwissalpS.db.playerDB:save

function SwissalpS.db.playerDB:load()
	local sMethod = 'mod:SwissalpS.db.playerDB:load: ';
	-- load by strategy
	if self.tStrategies.fs then
		print(sMethod .. 'loading playerDB from file' .. self.sPathFile);
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
				local serialize = minetest.deserialize(sData);
				self.storage = serialize or {};
			end;
			io.close(rInput);
		end;
	end; -- if fs
	-- these are not yet implemented
	if self.tStrategies.mysql then
		print(sMethod .. self.errorStrings.notReadyMySQL);
	end;
	if self.tStrategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite);
	end;
	return self;
end; -- SwissalpS.db.playerDB:load

function SwissalpS.db.playerDB.stringifyPlayer(mPlayer)
	-- check passed parameter in case some other mod is using this method
	assert('string' == type(mPlayer) or mPlayer:is_player(), 'mod:SwissalpS.db.playerDB.stringifyPlayer: param 1, mPlayer,'
		.. SwissalpS.db.playerDB.errorStrings.paramPlayer);
	if 'string' == type(mPlayer) then
		return mPlayer;
	end;
	return mPlayer:get_player_name();
end; -- SwissalpS.db.playerDB.stringifyPlayer

function SwissalpS.db.playerDB:set(mPlayer, sKey, mValue)
	local sMethod = 'mod:SwissalpS.db.playerDB:set ';
	--print(sMethod .. 'wurde aufgerufen');
	-- check passed parameters
	assert('string' == type(mPlayer) or mPlayer:is_player(),
		   sMethod .. 'param 1, mPlayer,' .. self.errorStrings.paramPlayer);
	assert('string' == type(sKey),
		   sMethod .. 'param 2, sKey,' .. self.errorStrings.paramKey);
	local sTV = type(mValue)
	assert('string' == sTV or 'number' == sTV or 'table' == sTV or 'boolean' == sTV,
		   sMethod .. 'param 3, mValue,' .. self.errorStrings.paramValue);
	-- stringify player
	local sPlayer = self.stringifyPlayer(mPlayer);
	-- make sure a slot exists for this player
	if not self.storage[sPlayer] then
		self.storage[sPlayer] = {};
	end;
	-- set the value in storage
	self.storage[sPlayer][sKey] = mValue;
	self:save();
	return self;
end; -- SwissalpS.db.playerDB:set

function SwissalpS.db.playerDB:del(mPlayer, sKey)
	local sMethod = 'mod:SwissalpS.db.playerDB:del ';
	--print(sMethod .. 'wurde aufgerufen');
	--print(dump(sKey));
	-- check passed parameters
	assert('string' == type(mPlayer) or mPlayer:is_player(),
		   sMethod .. 'param 1, mPlayer,' .. self.errorStrings.paramPlayer);
	assert('string' == type(sKey),
		   sMethod .. 'param 2, sKey,' .. self.errorStrings.paramKey);
	-- stringify player
	local sPlayer = self.stringifyPlayer(mPlayer);
	-- make sure player has a slot
	if not self.storage[sPlayer] then
		self.storage[sPlayer] = {};
	end;
	-- set to nil to delete
	self.storage[sPlayer][sKey] = nil;
	self:save();
	--print(sMethod .. 'sKey (' .. sKey .. ') has been deleted for ' .. sPlayer);
	return self;
end; -- SwissalpS.db.playerDB:del

function SwissalpS.db.playerDB:get(mPlayer, sKey, mDefault)
	local sMethod = 'mod:SwissalpS.db.playerDB:get ';
	--print(sMethod .. 'wurde aufgerufen');
	-- check passed parameters
	assert('string' == type(mPlayer) or mPlayer:is_player(),
		   sMethod .. 'param 1, mPlayer,' .. self.errorStrings.paramPlayer);
	assert('string' == type(sKey), sMethod .. 'param 2, sKey,' .. self.errorStrings.paramKey);
	local sTD = type(mDefault);
	assert('string' == sTD or 'number' == sTD or 'table' == sTD or 'boolean' == sTD,
		   sMethod .. 'param 3, mDefault,' .. self.errorStrings.paramDefault);
	-- stringify player
	local sPlayer = self.stringifyPlayer(mPlayer);
	-- if value exists for key, return value
	if self.storage[sPlayer] and self.storage[sPlayer][sKey] then
		return self.storage[sPlayer][sKey];
	end;
	--print(sMethod .. 'nothing found, returning mDefault');
	-- otherwise return supplied default value
	return mDefault;
end; -- SwissalpS.db.playerDB:get

function SwissalpS.db.playerDB:getAll(mPlayer, mDefault)
	local sMethod = 'mod:db:playerDB:getAll: ';
	--print(sMethod .. 'wurde aufgerufen');
	-- clean input
	assert(type(mPlayer) == 'string' or mPlayer:is_player(),
		   sMethod .. 'param 1, mPlayer,' .. self.errorStrings.paramPlayer);
	local sTD = type(mDefault);
	assert('string' == sTD or 'number' == sTD or 'table' == sTD or 'boolean' == sTD,
		   sMethod .. 'param 3, mDefault,' .. self.errorStrings.paramDefault);
	-- stringify player
	local sPlayer = self.stringifyPlayer(mPlayer);
	-- return storage if it exists
	if self.storage[sPlayer] then
		return self.storage[sPlayer];
	end;
	--print(sMethod .. 'nothing found, returning mDefault');
	-- otherwise return supplied default value
	return mDefault;
end; -- SwissalpS.db.playerDB:getAll
