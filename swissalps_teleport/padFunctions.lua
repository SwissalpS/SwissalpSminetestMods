
function SssStpP.afterPlaceNode(tPos, oPlayer)
    local tMeta = minetest.get_meta(tPos);
    local sPlayer = oPlayer:get_player_name();
	tMeta:set_string('owner', sPlayer);
	tMeta:set_float('enabled', 1);
end; -- SssStpP.afterPlaceNode

function SssStpP.cacheDel(sPlayer)
	SssStpP.cacheStore[sPlayer] = nil;
end; -- SssStpP.cacheDel

function SssStpP.cacheGet(sPlayer, sKey, mDefault)
	local db = SssStpP.cacheStore;
	local dbP = db[sPlayer];
	if nil == dbP or nil == dbP[sKey] then
		return mDefault;
	end; -- if no value stored for this player
	return dbP[sKey];
end; -- SssStpP.cacheGet

function SssStpP.cachePut(sPlayer, sKey, mValue)
	local db = SssStpP.cacheStore;
	if nil == db[sPlayer] then
		db[sPlayer] = {};
	end; -- if player not yet registered in cache
	db[sPlayer][sKey] = mValue;
end; -- SssStpP.cachePut

function SssStpP.fABM(tPos, oNodePad, iCountActiveObject, iCountActiveObjectWider)
	local tMeta = minetest.get_meta(tPos);
	if 1 > tMeta:get_float('enabled') then
		return;
	end; -- if not enabled at all
    local tObjects = minetest.get_objects_inside_radius(tPos, 1);
	local sName;
    for iKey, oPlayer in pairs(tObjects) do
        sPlayer = oPlayer:get_player_name();
        if nil ~= sPlayer then
			local tTarget = SssStpP.targetForPlayer(tPos, sPlayer);
			if nil == tTarget then
				SwissalpS.info.notifyPlayer(sPlayer, 'Sorry, either this variant of the SwissalpS-teleport-pad has not been completely coded or the world is over-populated. Tell the admin to search for free spots and optimize code to find them.');
				return;
			end; -- if no target found
			minetest.sound_play(SssStpP.soundLeave, {pos = tPos, gain = 1.0, max_hear_distance = 10});
			SwissalpS.info.notifyPlayer(sPlayer, 'Teleporting you to ' .. tTarget.title);
			oPlayer:moveto(tTarget.position, false);
			minetest.sound_play(SssStpP.soundArrive, {pos = tTarget.position, gain = 1.0, max_hear_distance = 10});
        end; -- if is a player
    end; -- loop all objects in radius
end -- SssStpP.fABM

function SssStpP.formDropDownValues(sPlayer)
	local sDropDownValues = 'SwissalpS Teleport Bookmarks';
	if SssStpP.bHasCompassGPS then
		sDropDownValues = sDropDownValues .. ',Compass GPS Bookmarks';
	end;
	if SssStpP.hasCustomPrivs(sPlayer) then
		sDropDownValues = sDropDownValues .. ',Custom Settings';
	end;
	return sDropDownValues;
end; -- SssStpP.formDropDownValues

function SssStpP.formListString(sPlayer)
	local sPrefix = SssStpS.db_prefix_slot;
	local iPrefixLength = string.len(sPrefix);
	local iCount = 0;
	local sOut = '';
	local sSlot;
	local tAllSlots = {};
	local tAllCache = {};
	-- get all the player's slots
	local tAll = SwissalpS.teleport.dbPlayer:getAll(sPlayer, {});
	for sKey, mValue in pairs(tAll) do
		if sPrefix == string.sub(sKey, 1, iPrefixLength) then
			iCount = iCount +1;
			sSlot = string.sub(sKey, iPrefixLength +1);
			tAllSlots[sSlot] = mValue;
		end
	end -- loop filter out slots
	for sSlot, tPos in pairs(tAllSlots) do
		table.insert(tAllCache, {position = tPos, title = sSlot});
		sOut = sOut .. sSlot .. ' '
				.. string.gsub(minetest.pos_to_string(tPos, 1), ',', ' ') .. ',';
	end -- for allSlots of player
	-- get all the global slots
	iCount = 0;
	tAllSlots = {};
	tAll = SwissalpS.teleport.dbPlayer:getAll(
			SssStpS.db_global_player_name, {});
	for sKey, mValue in pairs(tAll) do
		if sPrefix == string.sub(sKey, 1, iPrefixLength) then
			iCount = iCount +1;
			sSlot = string.sub(sKey, iPrefixLength +1);
			tAllSlots[sSlot] = mValue;
		end
	end -- loop filter out slots
	for sSlot, tPos in pairs(tAllSlots) do
		table.insert(tAllCache, {position = tPos, title = sSlot});
		sOut = sOut .. '*' .. sSlot .. ' '
				.. string.gsub(minetest.pos_to_string(tPos, 1), ',', ' ') .. ',';
	end; -- for allSlots of player
	SssStpP.cachePut(sPlayer, 'listSssStp', tAllCache);
	if 0 < #sOut then
		sOut = string.sub(sOut, 1, -2);
	end; -- if need to remove trailing comma
	return sOut;
end; -- SssStpS.formListString

function SssStpP.formIndexDropDown(sPlayer)
	local iIndex = SssStpP.cacheGet(sPlayer, 'iIndexDropDown', 1);
	local tValues = string.split(SssStpP.formDropDownValues(sPlayer), ',');
	if iIndex > #tValues or 0 >= iIndex then
		print('adjusting drop-down-index');
		iIndex = 1;
		SssStpP.cachePut(sPlayer, 'iIndexDropDown', iIndex);
	end; -- if invalid dropdown index
	return iIndex;
end; -- SssStpP.indexDropDown

function SssStpP.formIndexDropDownCustomType(sPlayer)
	local iIndex = SssStpP.cacheGet(sPlayer, 'iIndexDropDownCustomType', 1);
	if iIndex > #SssStpP.formAdvanced.tDropDownCustomTypeValues or 0 >= iIndex then
		print('adjusting drop-down-index for custom type');
		iIndex = 1;
		SssStpP.cachePut(sPlayer, 'iIndexDropDownCustomType', iIndex);
	end; -- if invalid dropdown index
	return iIndex;
end; -- SssStpP.formIndexDropDownCustomType

function SssStpP.getValidNodeAt(tPos)
	local tNode = minetest.get_node_or_nil(tPos);
	if nil == tNode then
		minetest.get_voxel_manip():read_from_map(tPos, tPos);
		tNode = minetest.get_node(tPos);
	end; -- if not yet generated area
	return tNode;
end; -- SssStpP.getValidNodeAt

function SssStpP.hasCustomPrivs(sPlayer)
	if minetest.check_player_privs(sPlayer, {server = true}) then
		return true;
	end; -- if server admin
	return minetest.check_player_privs(sPlayer, {SwissalpS_teleport_Random = true});
end; -- SssStpP.hasCustomPrivs

function SssStpP.mayDig(tPos, oPlayer)
    local tMeta = minetest.get_meta(tPos);
    local sPlayer = oPlayer:get_player_name();
	local isOwner = sPlayer == tMeta:get_string('owner');
	local isAdmin = minetest.check_player_privs(sPlayer, {server = true});
    if isOwner or isAdmin then
        return true;
    end; -- if may remove
    return false;
end; -- SssStpP.mayDig

function SssStpP.metaToPos(tMeta)
	if nil == tMeta then
		print('KO: nil passed as meta in SwissalpS.teleport.pad.metaToPos');
		return {x = 0, y = 0, z = 0};
	end; -- if nil passed for meta
	return {
		x = tMeta:get_float('x'),
		y = tMeta:get_float('y'),
		z = tMeta:get_float('z'),
	};
end; -- SssStpP.metaToPos

function SssStpP.onConstruct(tPos)
	local tMeta = minetest.get_meta(tPos);
	local tPosDefault = SssStpS.padDefaultPosition;
	local sPosDefault = minetest.pos_to_string(tPosDefault, 1);
	local sTitleDefault = SssStpS.padDefaultTitle;
	tMeta:set_string('infotext', '"Teleport to ' .. sTitleDefault .. ' '
					 .. sPosDefault .. '"');
	tMeta:set_string('title', sTitleDefault);
	tMeta:set_float('enabled', -1);
	SssStpP.posToMeta(tPosDefault, tMeta);
end; -- SssStpP.onConstruct

function SssStpP.onFields(oPlayer, sForm, tFields)
	if not tFields then
		return false;
	end; -- if no fields
	local iAdvanced = string.find(sForm, SssStpP.formAdvanced.name);
	local iStandard = string.find(sForm, SssStpP.formStandard.name);
	if not (1 == iAdvanced or 1 == iStandard) then
		-- not a form we know of
		return false;
	end; -- if not a form we expect
	local sPlayer = oPlayer:get_player_name();
	print('Player, ' .. sPlayer .. ', submitted form ' .. sForm);
	SwissalpS.info.notifyPlayer(sPlayer, sForm);
	local aParts = string.split(sForm, '|');
	local sPos = aParts[2];
	local tPos = minetest.string_to_pos(sPos);
	if 1 == iStandard then
		return SssStpP.onFieldsStandard(tPos, tFields, sPlayer);
	else
		return SssStpP.onFieldsAdvanced(tPos, tFields, sPlayer);
	end; -- if standard or advanced
end; -- SssStpP.onFields

function SssStpP.onFieldsStandard(tPos, tFields, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	local tTarget = SssStpP.metaToPos(tMeta);
	if not sPlayer or '' == sPlayer then
		print('KO: invalid player passed');
		return false;
	end; -- if invalid player
	--print('via standard: Player, ' .. sPlayer .. ', submitted fields ' .. dump(tFields));
	--SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
	local sOwner = tMeta:get_string('owner');
	local isOwner = sPlayer == sOwner;
	local isAdmin = minetest.check_player_privs(sPlayer, {server = true});
	if not isOwner then
		SwissalpS.info.notifyPlayer(sPlayer, 'This pad belongs to ' .. sOwner);
		if not isAdmin then
			return false;
		end; -- if not admin
	end; -- if not owner
	local bNeedsUpdate = false;
	if nil ~= tFields.sTitle then
		local sTitle = tMeta:get_string('title');
		local sTitleNew = string.trim(tFields.sTitle);
		if sTitle ~= sTitleNew then
			bNeedsUpdate = true;
			tMeta:set_string('title', sTitleNew);
		end; -- if changed
	end; -- if title given
	if nil ~= tFields.fX then
		local fVal = tMeta:get_float('x');
		local fValNew = tonumber(tFields.fX);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('x', fValNew);
		end; -- if changed
	end; -- if X given
	if nil ~= tFields.fY then
		local fVal = tMeta:get_float('y');
		local fValNew = tonumber(tFields.fY);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('y', fValNew);
		end; -- if changed
	end; -- if Y given
	if nil ~= tFields.fZ then
		local fVal = tMeta:get_float('z');
		local fValNew = tonumber(tFields.fZ);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('z', fValNew);
		end; -- if changed
	end; -- if Z given
	if bNeedsUpdate then
		--SwissalpS.info.notifyPlayer(sPlayer, 'need to update infotext');
		--infotext="Teleporter is Disabled"
		--infotext="Teleporter Offline"
		--tMeta:set_float('enabled', -1);
		SssStpP.updateInfotext(tMeta);
	end; -- if need to update other fields
	if nil ~= tFields.buttonAdvanced then
		--SwissalpS.info.notifyPlayer(sPlayer, 'advanced button clicked');
		SssStpP.cacheDel(sPlayer);
		SssStpP.showFormAdvanced(tPos, sPlayer);
	end; -- if advanced clicked
	return true;
end; -- SssStpP.onFieldsStandard

function SssStpP.onFieldsAdvanced(tPos, tFields, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	local tTarget = SssStpP.metaToPos(tMeta);
	if not sPlayer or '' == sPlayer then
		print('KO: invalid player passed');
		return false;
	end; -- if invalid player
	--print('via advanced: Player, ' .. sPlayer .. ', submitted fields ' .. dump(tFields));
	--SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
	local bApplySelected = false;
	local bHasCompassGPS = SssStpP.bHasCompassGPS;
	local bHasCustomPrivs = SssStpP.hasCustomPrivs(sPlayer);
	local tDropDownValues = string.split(SssStpP.formDropDownValues(sPlayer), ',');
	local tDropDownCustomTypeValues = SssStpP.formAdvanced.tDropDownCustomTypeValues;
	local bAddToB = false;
	local bRemoveFromB = false;
	local bResend = true;
	local iIndexDropDown = SssStpP.formIndexDropDown(sPlayer);
	local iIndexDropDownCustomType = SssStpP.formIndexDropDownCustomType(sPlayer);
	local sList = '';
	local sListCustom;
	local sTitle;
	local tBookmark;
	if nil ~= tFields.fieldHeightMax then
		local fVal = SssStpP.cacheGet(sPlayer, 'fHeightMax', 0);
		local fValNew = tonumber(tFields.fieldHeightMax);
		if fVal ~= fValNew then
			SssStpP.cachePut(sPlayer, 'fHeightMax', fValNew);
		end; -- if changed
	end; -- if max height given
	if nil ~= tFields.fieldHeightMin then
		local fVal = SssStpP.cacheGet(sPlayer, 'fHeightMin', 0);
		local fValNew = tonumber(tFields.fieldHeightMin);
		if fVal ~= fValNew then
			SssStpP.cachePut(sPlayer, 'fHeightMin', fValNew);
		end; -- if changed
	end; -- if min height given
	if nil ~= tFields.fieldRadiusMax then
		local fVal = SssStpP.cacheGet(sPlayer, 'fRadiusMax', 0);
		local fValNew = tonumber(tFields.fieldRadiusMax);
		if fVal ~= fValNew then
			SssStpP.cachePut(sPlayer, 'fRadiusMax', fValNew);
		end; -- if changed
	end; -- if max radius given
	if nil ~= tFields.fieldRadiusMin then
		local fVal = SssStpP.cacheGet(sPlayer, 'fRadiusMin', 0);
		local fValNew = tonumber(tFields.fieldRadiusMin);
		if fVal ~= fValNew then
			SssStpP.cachePut(sPlayer, 'fRadiusMin', fValNew);
		end; -- if changed
	end; -- if min radius given
	if nil ~= tFields.bookmarkList then
		local tAction = minetest.explode_textlist_event(tFields.bookmarkList);
		SssStpP.cachePut(sPlayer, 'iIndexBookmark', tAction.index);
		if 'DCL' == tAction.type then
			bApplySelected = true;
			tFields.quit = 'true';
		end; -- if double clicked an entry
	end; -- if bookmark selection changed
	if nil ~= tFields.bookmarkListA then
		local tAction = minetest.explode_textlist_event(tFields.bookmarkListA);
		SssStpP.cachePut(sPlayer, 'iIndexBookmark', tAction.index);
		if 'DCL' == tAction.type then
			bAddToB = true;
		end; -- if double clicked an entry
	end; -- if bookmark selection changed in list A
	if nil ~= tFields.bookmarkListB then
		local tAction = minetest.explode_textlist_event(tFields.bookmarkListB);
		SssStpP.cachePut(sPlayer, 'iIndexBookmarkB', tAction.index);
		if 'DCL' == tAction.type then
			bRemoveFromB = true;
		end; -- if double clicked an entry
	end; -- if bookmark selection changed in list B
	if nil ~= tFields.buttonApply then
		bApplySelected = true;
	end; -- if apply clicked
	if nil ~= tFields.buttonAddToB then
		-- add selected in list A to list B
		-- since we also want to use double-click, just set a flag
		bAddToB = true;
	end; -- if add button clicked
	if nil ~= tFields.buttonRemoveFromB then
		-- remove selected in list B
		-- since we also want to use double-click, just set a flag
		bRemoveFromB = true;
	end; -- if remove button pressed
	if nil ~= tFields.checkboxC2useCGPS then
		SssStpP.cachePut(sPlayer, 'useCGPSbookmarks', tFields.checkboxC2useCGPS);
	end; -- if checkbox state changed
	if nil ~= tFields.checkboxBuildPlatformOrHole then
		SssStpP.cachePut(sPlayer, 'buildPlatformOrHole',
						 tFields.checkboxBuildPlatformOrHole);
	end; -- if checkbox value changed
	if nil ~= tFields.checkboxUseRelativeValues then
		SssStpP.cachePut(sPlayer, 'useRelativeValues',
						 tFields.checkboxUseRelativeValues);
	end; -- if checkbox value changed
	if nil ~= tFields.dropDownCustomType then
		if tDropDownCustomTypeValues[iIndexDropDownCustomType] ~= tFields.dropDownCustomType then
			-- switch occuring
			local iIndexDropDownNew;
			for i, sValue in ipairs(tDropDownCustomTypeValues) do
				if sValue == tFields.dropDownCustomType then
					iIndexDropDownNew = i;
					break;
				end; -- if match found
			end; -- loop looking for selected entry
			iIndexDropDownCustomType = iIndexDropDownNew;
			SssStpP.cachePut(sPlayer, 'iIndexDropDownCustomType', iIndexDropDownCustomType);
			--print('switched to index ' .. iIndexDropDownCustomType);
		end; -- if changed
	end; -- if switched custom type
	if nil ~= tFields.dropDownSwitch then
		if tDropDownValues[iIndexDropDown] ~= tFields.dropDownSwitch then
			-- switch occuring
			local iIndexDropDownNew;
			for i, sValue in ipairs(tDropDownValues) do
				if sValue == tFields.dropDownSwitch then
					iIndexDropDownNew = i;
					break;
				end; -- if match found
			end; -- loop looking for selected entry
			iIndexDropDown = iIndexDropDownNew;
			SssStpP.cachePut(sPlayer, 'iIndexDropDown', iIndexDropDown);
			SssStpP.cachePut(sPlayer, 'iIndexBookmark', 1);
			--print('switched to index ' .. iIndexDropDown);
		end; -- if changed
	end; -- if switched source

	if bAddToB then
		-- add selected in list A to list B
		local iIndex = SssStpP.cacheGet(sPlayer, 'iIndexBookmark', 1);
		if 'true' == SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false') then
			-- list A is compassGPS
			tBookmark = textlist_bkmrks[sPlayer][iIndex];
			tTarget = {x = tBookmark.x, y = tBookmark.y, z = tBookmark.z};
		else
			-- list A is SwissalpS Teleport
			local tAll = SssStpP.cacheGet(sPlayer, 'listSssStp', {});
			tBookmark = tAll[iIndex];
			if nil == tBookmark then
				SwissalpS.index.notifyPlayer(sPlayer, 'Sorry, something went wrong. Close dialog and try again.');
				tFields.quit = 'true';
			end;
			tTarget = tBookmark.position;
		end; -- if compassGPS or SwissalpS Teleport
		local sTarget = string.gsub(minetest.pos_to_string(tTarget), ',', '|');
		sListCustom = SssStpP.cacheGet(sPlayer, 'sListCustom', '');
		if 0 == #sListCustom then
			sListCustom = sTarget;
		else
			sListCustom = sListCustom .. ',' .. sTarget;
		end; -- if first or consecutive
		SssStpP.cachePut(sPlayer, 'sListCustom', sListCustom);
	end; -- if add to list B
	if bRemoveFromB then
		-- remove selected in list B
		local iIndex = SssStpP.cacheGet(sPlayer, 'iIndexBookmarkB', 1);
		sListCustom = SssStpP.cacheGet(sPlayer, 'sListCustom', '');
		local aListB = string.split(sListCustom, ',');
		table.remove(aListB, iIndex);
		sListCustom = table.implodeStrings(aListB, ',');
		SssStpP.cachePut(sPlayer, 'sListCustom', sListCustom);
		if iIndex > #aListB then
			iIndex = #aListB;
			SssStpP.cachePut(sPlayer, 'iIndexBookmarkB', iIndex);
		end; -- if removed last item
	end; -- if remove from list B
	if bApplySelected then
		local iIndex = SssStpP.cacheGet(sPlayer, 'iIndexBookmark', 1);
		local iTypeCustom = 0;
		local iTypeBase = 0;
		if 1 == iIndexDropDown then
			-- bookmark from SwissalpS Teleport
			iTypeBase = 1;
			local tAll = SssStpP.cacheGet(sPlayer, 'listSssStp', {});
			tBookmark = tAll[iIndex];
			if nil == tBookmark then
				SwissalpS.index.notifyPlayer(sPlayer, 'Sorry, something went wrong. Close dialog and try again.');
				tFields.quit = 'true';
			end;
			sTitle = tBookmark.title;
			tTarget = tBookmark.position;
		elseif bHasCompassGPS and 2 == iIndexDropDown then
			-- bookmark from CompassGPS
			iTypeBase = 2;
			tBookmark = textlist_bkmrks[sPlayer][iIndex];
			sTitle = tBookmark.bkmrkname;
			tTarget = {x = tBookmark.x, y = tBookmark.y, z = tBookmark.z};
		else
			-- custom settings
			iTypeBase = 3;
			iTypeCustom = iIndexDropDownCustomType;
			if 1 == iIndexDropDownCustomType then
				-- random from players bookmarks
				-- possibly compassgps bookmarks
				if 'true' == SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false') then
					sTitle = 'random place from your CompassGPS bookmarks.';
				else
					sTitle = 'random place from your SwissalpS Teleport bookmarks.';
				end; -- if use compassGPS or not
			elseif 2 == iIndexDropDownCustomType then
				-- random from list of bookmarks
				sTitle = 'random place from list';
			elseif 3 == iIndexDropDownCustomType then
				-- random new place
				sTitle = 'random new place';
				tMeta:set_string('buildPlatformOrHole',
								 SssStpP.cacheGet(sPlayer, 'buildPlatformOrHole', 'true'));
				tMeta:set_string('useRelativeValues',
								 SssStpP.cacheGet(sPlayer, 'useRelativeValues', 'false'));
				tMeta:set_float('fHeightMin', SssStpP.cacheGet(sPlayer, 'fHeightMin', 0));
				tMeta:set_float('fHeightMax', SssStpP.cacheGet(sPlayer, 'fHeightMax', 0));
				tMeta:set_float('fRadiusMax', SssStpP.cacheGet(sPlayer, 'fRadiusMax', 0));
				tMeta:set_float('fRadiusMin', SssStpP.cacheGet(sPlayer, 'fRadiusMin', 0));
			end; -- if switch custom type
		end; -- if index of internal or compass GPS
		SssStpP.posToMeta(tTarget, tMeta);
		tMeta:set_string('title', sTitle);
		tMeta:set_float('typeBase', iTypeBase);
		tMeta:set_float('typeCustom', iTypeCustom);
		tMeta:set_string('useCGPSbookmarks',
						 SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false'));
		tMeta:set_string('sListCustom',
						 SssStpP.cacheGet(sPlayer, 'sListCustom', ''));
		SssStpP.updateInfotext(tMeta);
	end; -- if apply selected bookmark
	if 'true' == tFields.quit then
		bResend = false;
		SssStpP.cacheDel(sPlayer);
	end; -- if quit
	if not bResend then
		return true;
	end; -- if not resend form
	SssStpP.showFormAdvanced(tPos, sPlayer);
end; -- SssStpP.onFieldsAdvanced

function SssStpP.onRightClick(tPos, oNodePad, oPlayer)
	-- check authority
	local sPlayer = oPlayer:get_player_name();
	local tMeta = minetest.get_meta(tPos);
	if 0 < (tMeta:get_float('typeCustom', 0) or 0) then
		SssStpP.showFormAdvanced(tPos, sPlayer);
	else
		SssStpP.showFormStandard(tPos, sPlayer);
	end; -- if standard or advanced type
end; -- SssStpP.onRightClick

function SssStpP.posToMeta(tPos, tMeta)
	if nil == tPos
		or nil == tPos.x
		or nil == tPos.y
		or nil == tPos.z then
		print('KO: invalid position passed to SwissalpS.teleport.pad.posToMeta');
		return false;
	end; -- if invalid position passed
	if nil == tMeta then
		print('KO: nil passed as meta in SwissalpS.teleport.pad.posToMeta');
		return false;
	end; -- if nil passed for meta
	tMeta:set_float('x', tPos.x);
	tMeta:set_float('y', tPos.y);
	tMeta:set_float('z', tPos.z);
	return true;
end; -- SssStpP.posToMeta

function SssStpP.randomNewPlaceForPlayer(tPos, sPlayer)
	-- read settings from pad
	local tMeta = minetest.get_meta(tPos);
	local fHeightMax = tMeta:get_float('fHeightMax');
	local fHeightMin = tMeta:get_float('fHeightMin');
	local fRadiusMax = tMeta:get_float('fRadiusMax');
	local fRadiusMin = tMeta:get_float('fRadiusMin');
	local bBuildPoH = tMeta:get_string('buildPlatformOrHole');
	if '' == bBuildPoH then bBuildPoH = 'true'; end;
	bBuildPoH = 'true' == bBuildPoH;
	local bRelative = tMeta:get_string('useRelativeValues');
	if '' == bRelative then bRelative = 'false'; end;
	bRelative = 'true' == bRelative;
	-- prepare some variables
	local bIsUseable = false;
	local fYMax;
	local fYMin;
	local iCountTries = 0;
	local iMax = SssStpP.iMaxCoordinate;
	local iMaxTries = 3000; -- when to give up
	local iRadiusAroundStaticSpawn = SssStpP.iMinRadiusFromSpawn;
	local iRadiusHole = 5;
	local iStep = 3;
	local iX;
	local iY;
	local iZ;
	local sHomeBlock = 'default:glass'; -- what to use to build home.
	local tNode;
	--TODO: get from settings
	local tPosStaticSpawn = {x = 0, y = 0, z = 0};
	local tTarget;
	if bRelative then
		fYMax = tPos.y + fHeightMax;
		fYMin = tPos.y + fHeightMin;
		print('randomNewPlaceForPlayer with relative radi - not yet coded');
		return nil;
		--TODO:
	else
		fYMax = fHeightMax;
		fYMin = fHeightMin;
		print('randomNewPlaceForPlayer with standard radi');
		repeat
			iCountTries = iCountTries +1;
			print('outermost repeat tries: ', iCountTries);
			repeat
				iCountTries = iCountTries +1;
				print('second layer repeat tries:', iCountTries);
				iX = math.random(-iMax, iMax);
				iY = math.random(fYMin, fYMax);
				iZ = math.random(-iMax, iMax);
				tTarget = vector.new(iX, iY, iZ);
				print('trying ' .. minetest.pos_to_string(tTarget, 1));
				tNode = SssStpP.getValidNodeAt(tTarget);
			until ((not minetest.is_protected(tTarget, sPlayer))
					and (iRadiusAroundStaticSpawn < vector.distance(tPosStaticSpawn, tTarget)))
					or (iMaxTries < iCountTries);
			if iMaxTries < iCountTries then
				print('tried ' .. iCountTries .. 'times and gave up.');
				return nil;
			end;
			-- check cube/sphere around position
			print('checking surroundings of candidate');
			SwissalpS.info.notifyPlayer(sPlayer, 'checking surroundings of candidate...');
			local bViolationFound = false;
			for iCx = -fRadiusMax, fRadiusMax, iStep do
				print('deltaX = ', iCx);
				for iCz = -fRadiusMax, fRadiusMax, iStep do
					for iCy = -fRadiusMax, fRadiusMax, iStep do
						local tCtarget = vector.new(
													tTarget.x + iCx,
													tTarget.y + iCy,
													tTarget.z + iCz);
						if minetest.is_protected(tCtarget, sPlayer) then
							bViolationFound = true;
							break;
						end;
						--local tCnode = SssStpP.getValidNodeAt(tCtarget);
						--local sCname = tCnode.name;
						--if string.find(sCname, 'water')
						--	or string.find(sCname 'lava')
						--	or string.find(sCname, 'ignore') -- should never happen, but jic
						--	or string.find(sCname, 'fire') then
						--	bViolationFound = true;
						--	break;
						--end; -- if invalid node type
					end; -- loop Y
					if bViolationFound then break; end;
				end; -- loop Z
				if bViolationFound then break; end;
			end; -- loop X
			if not bViolationFound then
				print('OK, found a spot at ' .. minetest.pos_to_string(tTarget, 1));
				SwissalpS.info.notifyPlayer(sPlayer, 'OK, found a spot. Building a cocoon for you.');
				if bBuildPoH then
					-- build Platform or make hole/dome
					-- first make a hole
					print('OK, making air');
					local iRadiusHoleMax = iRadiusHole + 4;
					local tCtarget = vector.new(tTarget);
					for iCx = -iRadiusHoleMax, iRadiusHoleMax do
						tCtarget.x = tTarget.x + iCx;
						for iCz = -iRadiusHoleMax, iRadiusHoleMax do
							tCtarget.z = tTarget.z + iCz;
							for iCy = 0, iRadiusHoleMax do
								tCtarget.y = tTarget.y + iCy;
								if vector.distance(tCtarget, tTarget) <= iRadiusHoleMax then
									local tCnode = SssStpP.getValidNodeAt(tCtarget);
									if 'air' ~= tCnode.name then
										minetest.set_node(tCtarget, {name = 'air'});
									end;
								end; -- if inside hole radius
							end; -- loop y
						end; -- loop z
					end; -- loop x
					-- make sure we can stand -> create a floor and ledge
					print('OK, making floor');
					tCtarget = vector.new(tTarget);
					for iCx = -iRadiusHoleMax, iRadiusHoleMax do
						tCtarget.x = tTarget.x + iCx;
						for iCz = -iRadiusHoleMax, iRadiusHoleMax do
							tCtarget.z = tTarget.z + iCz;
							if vector.distance(tCtarget, tTarget) <= iRadiusHoleMax then
								minetest.set_node(tCtarget, {name = sHomeBlock});
							end; -- if inside hole radius
						end; -- loop z
					end; -- loop x
					-- build a dome over target
					print('OK, making dome');
					iRadiusHoleMax = iRadiusHole + 3;
					local iDistance = 0;
					tCtarget = vector.new(tTarget);
					for iCx = -iRadiusHoleMax, iRadiusHoleMax do
						tCtarget.x = tTarget.x + iCx;
						for iCz = -iRadiusHoleMax, iRadiusHoleMax do
							tCtarget.z = tTarget.z + iCz;
							for iCy = 0, iRadiusHoleMax do
								tCtarget.y = tTarget.y + iCy;
								iDistance = vector.distance(tTarget, tCtarget);
								if (iDistance <= iRadiusHoleMax)
										and (iDistance >= iRadiusHole) then
									minetest.set_node(tCtarget, {name = sHomeBlock});
								end; -- if inside hole radius
							end; -- loop y
						end; -- loop z
					end; -- loop x
					bIsUseable = true;
				else
					-- do not build platform or make hole
					print('Sorry, without hole/platform is not yet coded');
					return nil;
				end; -- if build/dig or not
			end; -- if no violation found
		until bIsUseable or (iMaxTries < iCountTries);
		if iMaxTries < iCountTries then
			print('tried ' .. iCountTries .. 'times and gave up.');
			return nil;
		end; -- if maxed out
		-- raise target by one so player can arrive
		tTarget.y = tTarget.y +1;
		return tTarget;
	end; -- if relative to pad
	-- TODO:
	return vector.new(tPos);
end; -- SssStpP.randomNewPlaceForPlayer

function SssStpP.showFormAdvanced(tPos, sPlayer)
	if false == SssStpP.cacheGet(sPlayer, 'haveReadFromMeta', false) then
		local tMeta = minetest.get_meta(tPos);
		-- read pad settings to cache
		SssStpP.cachePut(sPlayer, 'haveReadFromMeta', true);
		local fType = tMeta:get_float('typeBase') or 0;
		if not SssStpP.bHasCompassGPS and 2 < fType then
			fType = fType -1;
		end; -- if no compassGPS
		SssStpP.cachePut(sPlayer, 'iIndexDropDown', fType);
		local fCustomType = tMeta:get_float('typeCustom') or 0;
		SssStpP.cachePut(sPlayer, 'iIndexDropDownCustomType', fCustomType);
		local sTmp = tMeta:get_string('useCGPSbookmarks');
		if '' == sTmp then sTmp = 'false'; end;
		SssStpP.cachePut(sPlayer, 'useCGPSbookmarks', sTmp);
		SssStpP.cachePut(sPlayer, 'sListCustom', tMeta:get_string('sListCustom'));
		sTmp = tMeta:get_string('buildPlatformOrHole');
		if '' == sTmp then sTmp = 'true'; end;
		SssStpP.cachePut(sPlayer, 'buildPlatformOrHole', sTmp);
		sTmp = tMeta:get_string('useRelativeValues');
		if '' == sTmp then sTmp = 'false'; end;
		SssStpP.cachePut(sPlayer, 'useRelativeValues', sTmp);
		SssStpP.cachePut(sPlayer, 'fHeightMin', tMeta:get_float('fHeightMin'));
		SssStpP.cachePut(sPlayer, 'fHeightMax', tMeta:get_float('fHeightMax'));
		SssStpP.cachePut(sPlayer, 'fRadiusMax', tMeta:get_float('fRadiusMax'));
		SssStpP.cachePut(sPlayer, 'fRadiusMin', tMeta:get_float('fRadiusMin'));
	end; -- if not yet initialized cache
	local bShowSpecial = false;
	local iIndex;
	local iIndexDropDown = SssStpP.formIndexDropDown(sPlayer);
	local iIndexDropDownCustomType = SssStpP.formIndexDropDownCustomType(sPlayer);
	local sDropDownValues = SssStpP.formDropDownValues(sPlayer);
	local sDropDownCustomTypeValues = SssStpP.formAdvanced.sDropDownCustomTypeValues;
	local sList;
	local sTransparent = 'false'; --'true'; --
	-- which list?
	if 1 == iIndexDropDown then
		sList = SssStpP.formListString(sPlayer);
	elseif SssStpP.bHasCompassGPS and 2 == iIndexDropDown then
		sList, iIndex = compassgps.bookmark_loop('L', sPlayer);
	else
		-- show special settings
		bShowSpecial = true;
		if 'true' == SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false') then
			sList, iIndex = compassgps.bookmark_loop('L', sPlayer);
			sList = string.gsub(sList, '%*admin%*%:' .. sPlayer .. '> ', 'a:');
			sList = string.gsub(sList, '%*shared%*%:[^>]+> ', 's:');
		else
			sList = SssStpP.formListString(sPlayer);
		end; -- which list to prepare
	end; -- which list?
	iIndex = SssStpP.cacheGet(sPlayer, 'iIndexBookmark', 1);
	local sButtonSwitchList = 'dropdown[0.5,1;8,1;dropDownSwitch;'
			.. sDropDownValues ..';' .. iIndexDropDown .. ']';
	local sFormSpec = 'size[9,9]'
			.. 'label[0,0.2;SwissalpS teleport Pad Advanced: '
			.. minetest.pos_to_string(tPos, 1) .. ']'
			.. sButtonSwitchList;
	if bShowSpecial then
		-- show custom type panel
		sFormSpec = sFormSpec
			.. 'dropdown[0.5,2;8,1;dropDownCustomType;'
			.. sDropDownCustomTypeValues ..';' .. iIndexDropDownCustomType .. ']';
		if 1 == iIndexDropDownCustomType then
			-- Random Bookmark
			-- checkbox from CGPS
			local sCheckbox = '';
			if SssStpP.bHasCompassGPS then
				sCheckbox = 'checkbox[1,4;checkboxC2useCGPS;'
					.. 'Use Bookmarks of Compass GPS mod;'
					.. SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false') .. ']';
			end; -- if has compass mod
			sFormSpec = sFormSpec
				.. 'label[1,3;Uses a random location from bookmarks on usage.]'
				.. sCheckbox;
		elseif 2 == iIndexDropDownCustomType then
			-- Random from list
			-- not yet coded
			if SssStpP.bHasCompassGPS then
				sCheckbox = 'checkbox[3.1,3.8;checkboxC2useCGPS;Use Compass GPS;'
					.. SssStpP.cacheGet(sPlayer, 'useCGPSbookmarks', 'false') .. ']';
			end; -- if has cgps
			sFormSpec = sFormSpec
				.. 'label[1,3;Uses a random location from list provided below right.]'
				.. sCheckbox
				.. 'button[3.1,5;3,1;buttonAddToB;>>]'
				.. 'button[4.1,6;2,1;buttonRemoveFromB;<<]'
				.. 'textlist[0,3.5;3,4.5;bookmarkListA;' .. sList .. ';'
				.. iIndex .. ';' .. sTransparent .. ']'
				.. 'textlist[6,3.5;3,4.5;bookmarkListB;'
				.. SssStpP.cacheGet(sPlayer, 'sListCustom', '') .. ';'
				.. iIndex .. ';' .. sTransparent .. ']';
		elseif 3 == iIndexDropDownCustomType then
			-- Random new location
			local sCheckboxBuildPlatformOrHole = 'checkbox[2.1,3.4;'
					.. 'checkboxBuildPlatformOrHole;'
					.. 'Build a platform or dig a hole;'
					.. SssStpP.cacheGet(sPlayer, 'buildPlatformOrHole', 'true')
					.. ']';
			local sCheckboxValuesRelativeToPad = 'checkbox[1,7.4;'
					.. 'checkboxUseRelativeValues;'
					.. 'Regard values as offset from teleport pad;'
					.. SssStpP.cacheGet(sPlayer, 'useRelativeValues', 'false')
					.. ']';
			local sFieldHeightMin = 'field[1,4.8;3,1;fieldHeightMin;min height;'
					.. SssStpP.cacheGet(sPlayer, 'fHeightMin', 0) .. ']';
			local sFieldHeightMax = 'field[5,4.8;3,1;fieldHeightMax;max height;'
					.. SssStpP.cacheGet(sPlayer, 'fHeightMax', 200) .. ']';
			local sFieldRadiusToNeighbourMin = 'field[1,6.5;3,1;fieldRaduisMin;min radius;'
					.. SssStpP.cacheGet(sPlayer, 'fRadiusMin', 700) .. ']';
			local sFieldRadiusToNeighbourMax = 'field[5,6.5;3,1;fieldRadiusMax;max radius;'
					.. SssStpP.cacheGet(sPlayer, 'fRadiusMax', 700) .. ']';
			local sLabelRadius = 'label[1,7;';
			if 'true' == SssStpP.cacheGet(sPlayer, 'useRelativeValues', 'false') then
				sLabelRadius = sLabelRadius .. 'Radius from pad.';
			else
				sLabelRadius = sLabelRadius .. 'Radius from protected areas.';
			end; -- if using relative values
			sLabelRadius = sLabelRadius .. ' Negative radi disable.]'
			local sLabelHeight = 'label[1,5.3;Sea-level = 0. Negative heights are underground.]';
			sFormSpec = sFormSpec
				.. 'label[1,3;Generatesa random target whenever used.]'
				.. sCheckboxBuildPlatformOrHole
				.. sCheckboxValuesRelativeToPad
				.. sFieldHeightMin .. sFieldHeightMax
				.. sLabelHeight
				.. sFieldRadiusToNeighbourMax .. sFieldRadiusToNeighbourMin
				.. sLabelRadius;
		end; -- if switch chosen type
	else
		-- show list of bookmarks
		sFormSpec = sFormSpec
			.. 'textlist[0,2.0;9,6;bookmarkList;' .. sList .. ';' .. iIndex
			.. ';' .. sTransparent .. ']';
	end; -- if show special or list
	sFormSpec = sFormSpec .. 'button_exit[6.0,8.25;3,1;buttonClose;Close]'
			.. 'button_exit[0.2,8.25;5,1;buttonApply;Apply To Pad]';
	local sFormName = SssStpP.formAdvanced.name .. '|' .. minetest.pos_to_string(tPos);
	minetest.show_formspec(sPlayer, sFormName, sFormSpec);
	--textlist[X,Y;W,H;name;listelem 1,listelem 2,...,listelem n;selected idx;transparent]
	--Scrollable itemlist showing arbitrary text elements Name fieldname sent to server on singleclick or doubleclick value is current selected element, with a prefix of CHG: for singleclick and "DBL:" for doubleclick. Use minetest.explode_table_event(string) Listelements can be prepended by #color in hexadecimal format RRGGBB
end; -- SssStpP.showFormAdvanced

function SssStpP.showFormStandard(tPos, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	-- show standard form
	local tTarget = SssStpP.metaToPos(tMeta);
	local sButtonAdvanced = '';
	local sFormSpec = 'size[6,6]'
			.. 'field[0.5,0.5;6,1;sTitle;Destination Title;' .. tMeta:get_string('title') .. ']'
			.. 'field[0.5,1.5;6,1;fX;X-coordinate;' .. tTarget.x .. ']'
			.. 'field[0.5,2.5;6,1;fY;Y-coordinate;' .. tTarget.y .. ']'
			.. 'field[0.5,3.5;6,1;fZ;Z-coordinate;' .. tTarget.z .. ']'
			.. 'button[0.5,4.5;2,1;buttonAdvanced;Advanced]'
			.. 'button_exit[3.5,4.5;2,1;buttonClose;Close]';
	local sFormName = SssStpP.formStandard.name .. '|' .. minetest.pos_to_string(tPos);
	minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.showFormStandard

function SssStpP.targetForPlayer(tPos, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	local aList;
	local iIndex;
	local iMax;
	local iTypeCustom = tMeta:get_float('typeCustom') or 0;
	local sTitle;
	local tBookmark;
	local tTarget;
	-- is a special randomized target
	if 1 == iTypeCustom then
		-- random from players bookmarks
		-- possibly compassgps bookmarks
		if SssStpP.bHasCompassGPS
				and 'true' == (tMeta:get_string('useCGPSbookmarks') or 'false') then
			-- get a random location from compassgps bookmarks
			aList = textlist_bkmrks[sPlayer];
			iMax = #aList;
			if 0 < iMax then
				iIndex = math.random(1, iMax);
				tBookmark = aList[iIndex];
				return {position = {x = tBookmark.x, y = tBookmark.y, z = tBookmark.z}, title = tBookmark.bkmrkname };
			end; -- if got any at all
		else
			-- get from SwissalpS Teleport bookmarks
			-- build table
			SssStpP.formListString(sPlayer);
			aList = SssStpP.cacheGet(sPlayer, 'listSssStp', {});
			iMax = #aList;
			if 0 < iMax then
				iIndex = math.random(1, iMax);
				tBookmark = aList[iIndex];
				return tBookmark;
			end; -- if got any at all
		end; -- if CGPS or SssStp
	elseif 2 == iTypeCustom then
		-- random from list of bookmarks
		sList = tMeta:get_string('sListCustom') or '';
		aList = string.split(sList, ',');
		iMax = #aList;
		if 0 < iMax then
			iIndex = math.random(1, iMax);
			sTarget = string.gsub(aList[iIndex], '|', ',');
			tTarget = minetest.string_to_pos(sTarget);
			sTitle = minetest.pos_to_string(tTarget, 1);
			return {position = tTarget, title = sTitle};
		end; -- if something in list at all
	elseif 3 == iTypeCustom then
		-- random new place
		SwissalpS.info.notifyPlayer(sPlayer, 'This may take several minutes, depending on how full the world is. Please do not interact or you may not arrive.');
		tTarget = SssStpP.randomNewPlaceForPlayer(tPos, sPlayer);
		if nil == tTarget then
			return nil;
		end; -- if no target returned
		sTitle = minetest.pos_to_string(tTarget, 1);
		return {position = tTarget, title = sTitle};
	end; -- if switch type
	-- fallback to standard
	tTarget = SssStpP.metaToPos(tMeta);
	sTitle = tMeta:get_string('title');
	if '' == sTitle then
		sTitle = minetest.pos_to_string(tTarget, 1);
	end; -- if empty title
	return {position = tTarget, title = sTitle};
end; -- SssStpP.targetForPlayer

function SssStpP.updateInfotext(tMeta)
	local sTitle = tMeta:get_string('title');
	local iCustom = tMeta:get_float('typeCustom') or 0;
	local sPos = '';
	if 1 > iCustom then
		sPos = minetest.pos_to_string(SssStpP.metaToPos(tMeta), 1);
	end; -- if show static position
	tMeta:set_string('infotext', '"Teleport to ' .. sTitle .. ' '
					 .. sPos .. '"');
end; -- SssStpP.updateInfotext
