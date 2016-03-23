-- This is a Libary for minetest mods
-- author: addi <addi at king-arhtur dot eu>
-- for doku see : https://project.king-arthur.eu/projects/db/wiki
-- license: LGPL v3
-- SwissalpS could not get in touch with author, so here we
-- have bound it in to SwissalpS repo and modified to our liking

SwissalpS = SwissalpS or {}
SwissalpS.db = SwissalpS.db or {}

SwissalpS.db.playerDB = {}
SwissalpS.db.playerDB.__index = SwissalpS.db.playerDB
setmetatable(SwissalpS.db.playerDB, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

-- declare some error strings for simple reuse
SwissalpS.db.playerDB.errorStrings = {}
SwissalpS.db.playerDB.errorStrings.newNil = " WARNING: strategies is nil, so the database is only temporarily available, and will be deleted at shutdown."
SwissalpS.db.playerDB.errorStrings.newFS = " database store on filesystem."
SwissalpS.db.playerDB.errorStrings.notReadyMySQL = " MySQL support is not yet coded."
SwissalpS.db.playerDB.errorStrings.notReadySQLite = " SQLite support is not yet coded."
SwissalpS.db.playerDB.errorStrings.paramPlayer = " must be the playername or a player object!"
SwissalpS.db.playerDB.errorStrings.paramKey = " must be a string!"
SwissalpS.db.playerDB.errorStrings.paramValue = " must be a string, number, table or a boolean value. Userdata, functions and nil are not alowed!"
SwissalpS.db.playerDB.errorStrings.paramDefault = SwissalpS.db.playerDB.errorStrings.paramValue

function SwissalpS.db.playerDB.new(strategies)
	local sMethod = "mod:SwissalpS.db.playerDB.new: "
	-- init metatable
	local self = setmetatable({}, SwissalpS.db.playerDB)

	-- warn if memory only
	if nil == strategies then
		print(sMethod .. self.errorStrings.newNil)
	end

	-- init by strategy
	self.strategies = strategies or {}
	if self.strategies.fs then
		print(sMethod .. self.errorStrings.newFS)
		local dir = ""
		if "world" == self.strategies.fs.place then
			dir = minetest.get_worldpath()
		else
			dir = self.strategies.fs.place
		end
		-- concat our path-to-file
		self.file = dir .. "/" .. self.strategies.fs.name .. "." .. self.strategies.fs.form
	end

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. self.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite)
	end

	-- init storage and load
	self.storage = {};
	self:load()
	print(sMethod .. "instance of playerDB created")

	-- return initialized playerDB object
	return self

end -- SwissalpS.db.playerDB.new

function SwissalpS.db.playerDB:save()
	local sMethod = "mod:SwissalpS.db.playerDB:save: "

	-- save by strategy
	if self.strategies.fs then
		local output = io.open(self.file, 'w')
		if "json" == self.strategies.fs.form then
			output:write(minetest.write_json(self.storage, true))
		elseif "minetest" == self.strategies.fs.form then
			output:write(minetest.serialize(self.storage))
		end
		io.close(output)
	end

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. self.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite)
	end

	return self

end -- SwissalpS.db.playerDB:save

function SwissalpS.db.playerDB:load()
	local sMethod = "mod:SwissalpS.db.playerDB:load: "

	-- load by strategy
	if self.strategies.fs then
		print(sMethod .. "loading playerDB from file" .. self.file)
		local input = io.open(self.file, "r")
		local data = nil
		if input then
			data = input:read('*all')
		end
		if data and data ~= "" then
			if "json" == self.strategies.fs.form then
				local json = minetest.parse_json(data)
				self.storage = json or {}
			elseif "minetest" == self.strategies.fs.form then
				local serialize = minetest.deserialize(data)
				self.storage = serialize or {}
			end
			io.close(input)
		end
	end -- if fs

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. self.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. self.errorStrings.notReadySQLite)
	end

	return self

end -- SwissalpS.db.playerDB:load

function SwissalpS.db.playerDB.stringifyPlayer(player)
	-- check passed parameter in case some other mod is using this method
	assert("string" == type(player) or player:is_player(), "mod:SwissalpS.db.playerDB.stringifyPlayer: param 1, player," .. SwissalpS.db.playerDB.errorStrings.paramPlayer)

	if "string" == type(player) then
		return player
	end

	return player:get_player_name()

end -- SwissalpS.db.playerDB.stringifyPlayer

function SwissalpS.db.playerDB:set(player, key, value)
	local sMethod = "mod:SwissalpS.db.playerDB:set "
	--print(sMethod .. "wurde aufgerufen")
	-- check passed parameters
	assert("string" == type(player) or player:is_player(), sMethod .. "param 1, player," .. self.errorStrings.paramPlayer)
	assert("string" == type(key), sMethod .. "param 2, key," .. self.errorStrings.paramKey)
	local tV = type(value)
	assert("string" == tV or "number" == tV or "table" == tV or "boolean" == tV, sMethod .. "param 3, value," .. self.errorStrings.paramValue)

	-- stringify player
	player = self.stringifyPlayer(player)

	-- make sure a slot exists for this player
	if not self.storage[player] then
		self.storage[player] = {}
	end

	-- set the value in storage
	self.storage[player][key] = value
	self:save()

	return self

end -- SwissalpS.db.playerDB:set

function SwissalpS.db.playerDB:del(player, key)
	local sMethod = "mod:SwissalpS.db.playerDB:del "
	--print(sMethod .. "wurde aufgerufen")
	--print(dump(key))
	-- check passed parameters
	assert("string" == type(player) or player:is_player(), sMethod .. "param 1, player," .. self.errorStrings.paramPlayer)
	assert("string" == type(key), sMethod .. "param 2, key," .. self.errorStrings.paramKey)

	-- stringify player
	player = self.stringifyPlayer(player)

	-- make sure player has a slot
	if not self.storage[player] then
		self.storage[player] = {}
	end

	-- set to nil to delete
	self.storage[player][key] = nil
	self:save()

	--print(sMethod .. "key (" .. key .. ") has been deleted for " .. player)

	return self

end -- SwissalpS.db.playerDB:del

function SwissalpS.db.playerDB:get(player, key, default)
	local sMethod = "mod:SwissalpS.db.playerDB:get "
	--print(sMethod .. "wurde aufgerufen")
	-- check passed parameters
	assert("string" == type(player) or player:is_player(), sMethod .. "param 1, player," .. self.errorStrings.paramPlayer)
	assert("string" == type(key), sMethod .. "param 2, key," .. self.errorStrings.paramKey)
	local tD = type(default)
	assert("string" == tD or "number" == tD or "table" == tD or "boolean" == tD, sMethod .. "param 3, default," .. self.errorStrings.paramDefault)

	-- stringify player
	player = self.stringifyPlayer(player)

	-- if value exists for key, return value
	if self.storage[player] and self.storage[player][key] then
		return self.storage[player][key]
	end

	--print(sMethod .. "nothing found, returning default")

	-- otherwise return supplied default value
	return default

end -- SwissalpS.db.playerDB:get

function SwissalpS.db.playerDB:getAll(player, default)
	local sMethod = "mod:db:playerDB:getAll: "
	--print(sMethod .. "wurde aufgerufen")
	-- clean input
	assert(type(player) == "string" or player:is_player(), sMethod .. "param 1, player," .. self.errorStrings.paramPlayer)
	local tD = type(default)
	assert("string" == tD or "number" == tD or "table" == tD or "boolean" == tD, sMethod .. "param 3, default," .. self.errorStrings.paramDefault)

	-- stringify player
	player = self.stringifyPlayer(player)

	-- return storage if it exists
	if self.storage[player] then
		return self.storage[player]
	end

	--print(sMethod .. "nothing found, returning default")

	-- otherwise return supplied default value
	return default

end -- SwissalpS.db.playerDB:getAll
