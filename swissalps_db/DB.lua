SwissalpS.db.DB = {}
SwissalpS.db.DB.__index = SwissalpS.db.DB
setmetatable(SwissalpS.db.DB, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function SwissalpS.db.DB.new(strategies)
	local sMethod = "mod:SwissalpS.db.DB.new: "
	local self = setmetatable({}, SwissalpS.db.DB)

	if nil == strategies then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.newNil)
	end
	self.strategies = strategies or {}

	if self.strategies.fs then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.newFS)
		local dir = ""
		if "world" == self.strategies.fs.place then
			dir = minetest.get_worldpath()
		else
			dir = self.strategies.fs.place
		end

		self.file = dir .. "/" .. self.strategies.fs.name .. "." .. self.strategies.fs.form

	end -- if fs

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadySQLite)
	end
	
	self.storage = {}
	self:load()
	print(sMethod .. "instance of DB created")

	return self

end -- SwissalpS.db.DB.new

function SwissalpS.db.DB:save()
	local sMethod = "mod:SwissalpS.db.DB:save: "
	if self.strategies.fs then
		local output = io.open(self.file,'w')	
		if "json" == self.strategies.fs.form then
			output:write(minetest.write_json(self.storage,true))
		elseif "minetest" == self.strategies.fs.form then
			output:write(minetest.serialize(self.storage))
		end
		io.close(output)
	end

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. SwissalpS.db.playerDB.errorStrings.notReadySQLite)
	end

	return self

end -- SwissalpS.db.DB:save

function SwissalpS.db.DB:load()
	local sMethod = "mod:SwissalpS.db.DB:load: "
	if self.strategies.fs then
		print(sMethod .. "loading DB from file" .. self.file)
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
				local deserialized = minetest.deserialize(data)
				self.storage = deserialized or {}
			end
			io.close(input)
		end
	end -- if fs

	-- these are not yet implemented
	if self.strategies.mysql then
		print(sMethod .. playerDB.errorStrings.notReadyMySQL)
	end
	if self.strategies.sqlite then
		print(sMethod .. playerDB.errorStrings.notReadySQLite)
	end

	return self

end -- SwissalpS.db.DB:load

function SwissalpS.db.DB:set(key, value)
	local sMethod = "mod:SwissalpS.db.DB:set: "
	assert("string" == type(key), sMethod .. "param 1, key," .. playerDB.errorStrings.paramKey)
	local tV = type(value)
	assert("string" == tV or "number" == tV or "table" == tV or "boolean" == tV, sMethod .. "param 2, value," .. playerDB.errorStrings.paramValue)

	self.storage[key] = value
	self:save()

	return self

end -- SwissalpS.db.DB:set

function SwissalpS.db.DB:get(key, default)
	local sMethod = "mod:SwissalpS.db.DB:get: "
	assert("string" == type(key), sMethod .. "param 1, key," .. playerDB.errorStrings.paramKey)
	local tD = type(default)
	assert("string" == tD or "number" == tD or "table" == tD or "boolean" == tD, sMethod .. "param 2, default," .. playerDB.errorStrings.paramDefault)

	if self.storage[key] then
		return self.storage[key]	
	end
	
	--print(sMethod .. "nothing found, returning default")
	
	return default

end -- SwissalpS.db.DB:get

function SwissalpS.db.DB:getAll(default)
	local sMethod = "mod:SwissalpS.db.DB:getAll: "
	local tD = type(default)
	assert("string" == tD or "number" == tD or "table" == tD or "boolean" == tD, sMethod .. "param 1, default," .. playerDB.errorStrings.paramDefault)


	if self.storage then
		return self.storage	
	end
	
	--print(sMethod .. "nothing found, returning default")
	
	return default

end -- DB:getAll

