-- Minetest mod: swissalps_info
-- See LICENSE.txt and README.txt for licensing and other information.

function SwissalpS.info.cc_listAvailableBlocks(sPlayer, sModName)
	if '' ~= sModName then
		sModName = sModName .. ':';
		iModNameLength = string.len(sModName);
		for sKey, mValue in pairs(minetest.registered_nodes) do
			if sModName == string.sub(sKey, 1, iModNameLength) then
				SwissalpS.info.notifyPlayer(sPlayer, sKey);
			end; -- if module item
		end; -- loop
		return;
	end;
	for sKey, mValue in pairs(minetest.registered_nodes) do
		SwissalpS.info.notifyPlayer(sPlayer, sKey);
	end;
end; --SwissalpS.info.cc_listAvailableBlocks

function SwissalpS.info.cc_listAvailableMethods(sPlayer, o)
	local tAll = {};
	for sKey, value in pairs(minetest) do
		table.insert(tAll, sKey);
	end;
	table.sort(tAll);
	for iIndex, sKey in pairs(tAll) do
		SwissalpS.info.notifyPlayer(sPlayer, 'minetest.' .. sKey);
	end;
end; --SwissalpS.info.cc_listAvailableMethods

function SwissalpS.info.cc_listAvailableMobs(sPlayer, sMobName)
	SwissalpS.info.notifyPlayer(sPlayer, 'Sorry, not yet coded.');
	return;
--[[

	local tAll = {}
	for sKey,value in pairs(minetest) do
		table.insert(tAll, sKey)
	end
	table.sort(tAll)
	for iIndex, sKey in pairs(tAll) do
		SwissalpS.info.notifyPlayer(sPlayer, sKey)
	end



	if '' ~= sMobName then
		sMobName = sMobName .. ':'
		iMobNameLength = string.len(sMobName)
		for sKey, mValue in pairs(minetest.registered_nodes) do
			if sModName == string.sub(sKey, 1, iModNameLength) then
				SwissalpS.info.notifyPlayer(sPlayer, sKey)
			end -- if module item
		end -- loop
		return
	end
	for sKey, mValue in pairs(minetest.registered_nodes) do
		SwissalpS.info.notifyPlayer(sPlayer, sKey)
	end
--]]
end; --SwissalpS.info.cc_listAvailableMobs
