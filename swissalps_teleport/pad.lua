
SwissalpS.teleport.pad = {};
SssStpP = SwissalpS.teleport.pad;
SssStpP.name = 'swissalps_teleport:pad';
SssStpP.description = 'SwissalpS Teleport Pad. Right-click it to configure.';
SssStpP.inventoryImage = 'swissalps_teleport_pad.png';
SssStpP.soundArrive = 'swissalps_teleport_padArrive';
SssStpP.soundLeave = 'swissalps_teleport_padLeave';
SssStpP.formAdvanced = {};
SssStpP.formAdvanced.name = 'swissalps_teleport:padAdvanced';
SssStpP.formStandard = {};
SssStpP.formStandard.name = 'swissalps_teleport:padStandard';
SssStpP.cacheStore = {};
SssStpP.bHasCompassGPS = nil ~= minetest.get_modpath('compassgps');

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

function SssStpP.posToMeta(tPos, tMeta)
	if nil == tPos
		or nil == tPos.x
		or nil == tPos.y
		or nil == tPos.z then
		print('KO: invalid position passed to SwissalpS.teleport.pad.posToMeta');
		return;
	end; -- if invalid position passed
	if nil == tMeta then
		print('KO: nil passed as meta in SwissalpS.teleport.pad.posToMeta');
		return;
	end; -- if nil passed for meta
	tMeta:set_float('x', tPos.x);
	tMeta:set_float('y', tPos.y);
	tMeta:set_float('z', tPos.z);
end; -- SssStpP.posToMeta

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

function SssStpP.formDropDownValues(sPlayer)
	local sDropDownValues = 'SwissalpS Teleport Bookmarks';
	if SssStpP.bHasCompassGPS then
		sDropDownValues = sDropDownValues .. ',Compass GPS Bookmarks';
	end;
	if bHasCustomPrivs then
		sDropDownValues = sDropDownValues .. ',Custom Settings';
	end;
end; -- SssStpP.formDropDownValues

function SssStpP.hasCustomPrivs(sPlayer)
	if minetest.check_player_privs(sPlayer, {server = true}) then
		return true;
	end; -- if server admin
	return minetest.check_player_privs(sPlayer, {SwissalpS_teleport_Random = true});
end; -- SssStpP.hasCustomPrivs

SssStpP.craft = {};
SssStpP.craft.recipe = {
    {'default:wood', 'default:wood', 'default:wood'},
    {'default:wood', 'default:mese', 'default:wood'},
    {'default:wood', 'default:glass', 'default:wood'},
};
SssStpP.craft.recipe2 = {
    {'moreores:copper_ingot', 'mesecons_powerplant:power_plant', 'moreores:copper_ingot'},
    {'moreores:copper_ingot', 'moreores:gold_block', 'moreores:copper_ingot'},
    {'moreores:copper_ingot', 'default:glass', 'moreores:copper_ingot'}
};

SssStpP.craft.def = {
    output = SssStpP.name,
    recipe = SssStpP.craft.recipe,
};

SssStpP.craft.def2 = {
    output = SssStpP.name,
    recipe = SssStpP.craft.recipe2,
};

function SssStpP.fABM(tPos, oNodePad, iCountActiveObject, iCountActiveObjectWider)
	local tMeta = minetest.get_meta(tPos);
	if 1 > tMeta:get_float('enabled') then
		return;
	end; -- if not enabled at all
    local tObjects = minetest.get_objects_inside_radius(tPos, 1);
	local tTarget = SssStpP.metaToPos(tMeta);
	local sName;
    for iKey, oPlayer in pairs(tObjects) do
        sName = oPlayer:get_player_name();
        if nil ~= sName then
			minetest.sound_play(SssStpP.soundLeave, {pos = tPos, gain = 1.0, max_hear_distance = 10});
			oPlayer:moveto(tTarget, false);
			minetest.sound_play(SssStpP.soundArrive, {pos = tTarget, gain = 1.0, max_hear_distance = 10});
        end; -- if is a player
    end; -- loop all objects in radius
end -- SssStpP.fABM

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
	print('via standard: Player, ' .. sPlayer .. ', submitted fields ' .. dump(tFields));
	SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
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
		local sTitle = tMeta:get_string('title');
		local sPos = minetest.pos_to_string(SssStpP.metaToPos(tMeta), 1);
		tMeta:set_string('infotext', '"Teleport to ' .. sTitle .. ' '
						 .. sPos .. '"');
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
	print('via advanced: Player, ' .. sPlayer .. ', submitted fields ' .. dump(tFields));
	SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
	local bApplySelected = false;
	local bHasCompassGPS = SssStpP.hasCompassGPS;
	local bHasCustomPrivs = SssStpP.hasCustomPrivs(sPlayer);
	local bIsShowingCGPS = false;
	local sDropDownValues = SssStpP.formDropDownValues(sPlayer);
	'SwissalpS Teleport Bookmarks';
	if bHasCompassGPS then
		sDropDownValues = sDropDownValues .. ',Compass GPS Bookmarks';
	end;
	if bHasCustomPrivs then
		sDropDownValues = sDropDownValues .. ',Custom Settings';
	end;
	local tDropDownValues = string.split(sDropDownValues, ',');
	local sDropDownCustomTypeValues = 'Random Bookmark,Random From List,Random New Destination';
	local tDropDownCustomTypeValues = string.split(sDropDownCustomTypeValues, ',');
	local bAddToB = false;
	local bRemoveFromB = false;
	local bResend = true;
	local bShowSpecial = false;
	local iIndex;
	local iIndexDropDown = SssStpP.cacheGet(sPlayer, 'iIndexDropDown', 1);
	if iIndexDropDown > #tDropDownValues then
		print('adjusting drop-down-index');
		iIndexDropDown = 1;
		SssStpP.cachePut(sPlayer, 'iIndexDropDown', iIndexDropDown);
	end; -- if invalid dropdown index
	local iIndexDropDownCustomType = SssStpP.cacheGet(sPlayer, 'iIndexDropDownCustomType', 1);
	if iIndexDropDownCustomType > #tDropDownCustomTypeValues then
		print('adjusting drop-down-index for custom type');
		iIndexDropDownCustomType = 1;
		SssStpP.cachePut(sPlayer, 'iIndexDropDownCustomType', iIndexDropDownCustomType);
	end; -- if invalid dropdown index
	local sButtonSwitchList = '';
	local sTransparent = 'false'; --'true'; --
	local sList = 'one,two,three';
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
		SssStpP.cachePut(sPlayer, 'bC2useCGPS', tFields.checkboxC2useCGPS);
	end; -- if checkbox state changed
	if nil ~= tFields.checkboxC4buildPlatformOrHole then
		SssStpP.cachePut(sPlayer, 'bC4buildPlatformOrHole',
						 tFields.checkboxC4buildPlatformOrHole);
	end; -- if checkbox value changed
	if nil ~= tFields.checkboxC4relativeValues then
		SssStpP.cachePut(sPlayer, 'bC4relativeValues',
						 tFields.checkboxC4relativeValues);
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
	-- which list? which buttons to show?
	if 1 == iIndexDropDown then
		sList = SssStpP.list4formspec(sPlayer);
	elseif bHasCompassGPS and 2 == iIndexDropDown then
		sList, iIndex = compassgps.bookmark_loop('L', sPlayer);
		bIsShowingCGPS = true;
	else
		-- show special settings
		bShowSpecial = true;
		if 'true' == SssStpP.cacheGet(sPlayer, 'bC2useCGPS', 'false') then
			sList, iIndex = compassgps.bookmark_loop('L', sPlayer);
		else
			sList = SssStpP.list4formspec(sPlayer);
		end; -- which list to prepare
	end;
	iIndex = SssStpP.cacheGet(sPlayer, 'iIndexBookmark', 1);
	if bAddToB then
		-- add selected in list A to list B
		print('supposed to add selected bookmark to list B');
	end; -- if add to list B
	if bRemoveFromB then
		-- remove selected in list B
		print('supposed to remove selected bookmark from list B');
	end; -- if remove from list B
	if bApplySelected then
		local sTitle = '';
		local tTarget = {x = 0, y = 0, z = 0};
		if bIsShowingCGPS then
			--tTarget = textlist_bkmrks[sPlayer][iIndex];
			--sTitle = compassgps.bookmark_name_string(tTarget);
		else
			--

		end; -- if index of internal or compass GPS
		print('supposed to apply selected bookmark now');

	end; -- if apply selected bookmark
	if 'true' == tFields.quit then
		bResend = false;
	end; -- if quit
	if not bResend then
		return;
	end; -- if not resend form
	SssStpP.showFormAdvanced(tPos, sPlayer);
end; -- SssStpP.onFieldsAdvanced

function SssStpP.onRightClick(tPos, oNodePad, oPlayer)
	-- check authority
	local sPlayer = oPlayer:get_player_name();
	SssStpP.showFormStandard(tPos, sPlayer);
end; -- SssStpP.onRightClick

function SssStpP.showFormAdvanced(tPos, sPlayer)
	if false == SssStpP.cacheGet(sPlayer, 'bHaveReadFromMeta', false) then
		-- read pad settings to cache
	end; -- if not yet initialized cache
	if SssStpP.hasCustomPrivs(sPlayer) then
		--
	end; -- if has random priv
	sButtonSwitchList = 'dropdown[0.5,1;8,1;dropDownSwitch;'
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
		if 0 == iIndexDropDownCustomType then
			-- Standard needs no extra fields
			sFormSpec = sFormSpec
				.. 'label[1,3;No additional settings for Standard Type]';
		elseif 1 == iIndexDropDownCustomType then
			-- Random Bookmark
			-- checkbox from CGPS
			local sCheckbox = '';
			if bHasCompassGPS then
				sCheckbox = 'checkbox[1,4;checkboxC2useCGPS;'
					.. 'Use Bookmarks of Compass GPS mod;'
					.. SssStpP.cacheGet(sPlayer, 'bC2useCGPS', 'false') .. ']';
			end; -- if has compass mod
			sFormSpec = sFormSpec
				.. 'label[1,3;Uses a random location from bookmarks on usage.]'
				.. sCheckbox;
		elseif 2 == iIndexDropDownCustomType then
			-- Random from list
			-- not yet coded
			if bHasCompassGPS then
				sCheckbox = 'checkbox[3.1,3.8;checkboxC2useCGPS;Use Compass GPS;'
					.. SssStpP.cacheGet(sPlayer, 'bC2useCGPS', 'false') .. ']';
			end; -- if has cgps
			sFormSpec = sFormSpec
				.. 'label[1,3;Uses a random location from list provided below right.]'
				.. sCheckbox
				.. 'button[3.1,5;3,1;buttonAddToB;>>]'
				.. 'button[4.1,6;2,1;buttonRemoveFromB;<<]'
				.. 'textlist[0,3.5;3,4.5;bookmarkListA;' .. sList .. ';'
				.. iIndex .. ';' .. sTransparent .. ']'
				.. 'textlist[6,3.5;3,4.5;bookmarkListB;'
				.. SssStpP.cacheGet(sPlayer, 'sListB', '') .. ';'
				.. iIndex .. ';' .. sTransparent .. ']';
		elseif 3 == iIndexDropDownCustomType then
			-- Random new location
			local sCheckboxBuildPlatformOrHole = 'checkbox[2.1,3.4;'
					.. 'checkboxC4buildPlatformOrHole;'
					.. 'Build a platform or dig a hole;'
					.. SssStpP.cacheGet(sPlayer, 'bC4buildPlatformOrHole', 'true')
					.. ']';
			local sCheckboxValuesRelativeToPad = 'checkbox[1,7.4;'
					.. 'checkboxC4relativeValues;'
					.. 'Regard values as offset from teleport pad;'
					.. SssStpP.cacheGet(sPlayer, 'bC4relativeValues', 'false')
					.. ']';
			local sFieldHeightMin = 'field[1,4.8;3,1;fieldHeightMin;min height;'
					.. SssStpP.cacheGet(sPlayer, 'iHeightMin', 0) .. ']';
			local sFieldHeightMax = 'field[5,4.8;3,1;fieldHeightMax;max height;'
					.. SssStpP.cacheGet(sPlayer, 'iHeightMax', 200) .. ']';
			local sFieldRadiusToNeighbourMax = 'field[1,6.5;3,1;fieldRadiusMax;max radius;'
					.. SssStpP.cacheGet(sPlayer, 'iRadiusMax', 700) .. ']';
			local sFieldRadiusToNeighbourMin = 'field[5,6.5;3,1;fieldRaduisMin;min radius;'
					.. SssStpP.cacheGet(sPlayer, 'iRadiusMin', 700) .. ']';
			local sLabelRadius = 'label[1,7;';
			if 'true' == SssStpP.cacheGet(sPlayer, 'bC4relativeValues', 'false') then
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
	local bHasCompassGPS = nil ~= minetest.get_modpath('compassgps');
	local bIsShowingCGPS = SssStpP.cacheGet(sPlayer, 'isShowingCGPS', false);
	local iIndex;
	local sButtonCompassGPS = '';
	local sButtonSssSteleport = '';
	local sTransparent = 'false'; -- 'true';
	local sList = '';
	if bHasCompassGPS then
		if bIsShowingCGPS then
			sList, iIndex = compassgps.bookmark_loop('L', sPlayer);
		else
			-- not showing GPS list
		end;
	end;
	print(sListC);
	local sFormSpec = 'size[9,9]'
			.. 'label[0,0.2;SwissalpS teleport Pad Advanced: '
			.. minetest.pos_to_string(tPos, 1) .. ']'
			.. 'textlist[0,3.0;9,6;bookmarkListC;' .. sList .. ';' .. iIndex .. ';' .. sTransparent .. ']'
			--.. 'textlist[0,3.0;9,6;bookmarkListP;' .. sListP .. ';' .. iIndex .. ';' .. sTransparent .. ']'
			--.. 'textlist[0,3.0;9,6;bookmarkListG;' .. sListG .. ';' .. iIndex .. ';' .. sTransparent .. ']'
			.. 'button_exit[3.5,4.5;3,1;buttonClose;Close]';
	local sFormName = SssStpP.formAdvanced.name .. '|' .. minetest.pos_to_string(tPos);
    minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.showFormAdvanced

function SssStpP.showFormStandard(tPos, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	-- show standard form
	local tTarget = SssStpP.metaToPos(tMeta);
	local sButtonAdvanced = '';
	local sFormSpec = 'size[6,6]'
			.. 'field[0.5,0.5;4,1;sTitle;Destination Title;' .. tMeta:get_string('title') .. ']'
			.. 'field[0.5,1.5;2,1;fX;X-coordinate;' .. tTarget.x .. ']'
			.. 'field[0.5,2.5;2,1;fY;Y-coordinate;' .. tTarget.y .. ']'
			.. 'field[0.5,3.5;2,1;fZ;Z-coordinate;' .. tTarget.z .. ']'
			.. 'button[0.5,4.5;2,1;buttonAdvanced;Advanced]'
			.. 'button_exit[3.5,4.5;2,1;buttonClose;Close]';
	local sFormName = SssStpP.formStandard.name .. '|' .. minetest.pos_to_string(tPos);
	minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.showFormStandard

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
function SssStpP.afterPlaceNode(tPos, oPlayer)
    local tMeta = minetest.get_meta(tPos);
    local sPlayer = oPlayer:get_player_name();
	tMeta:set_string('owner', sPlayer);
	tMeta:set_float('enabled', 1);
end; -- SssStpP.afterPlaceNode

SssStpP.defNode = {
	tile_images = {SssStpP.inventoryImage},
	drawtype = 'signlike',
	paramtype = 'light',
	paramtype2 = 'wallmounted',
	walkable = false,
	description = SssStpP.description,
	inventory_image = SssStpP.inventoryImage,
	metadata_name = 'sign',
	--sounds = default.node_sound_defaults(),
	groups = {choppy = 2, dig_immediate = 2},
	selection_box = {type = 'wallmounted'},
    on_construct = SssStpP.onConstruct,
	after_place_node = SssStpP.afterPlaceNode,
	on_rightclick = SssStpP.onRightClick,
    on_receive_fields = SssStpP.onFieldsStandard,
	can_dig = SssStpP.mayDig,
};

SssStpP.defABM = {
    nodenames = {SssStpP.name},
	interval = 1.0,
	chance = 1,
	action = SssStpP.fABM,
};

minetest.register_craft(SssStpP.craft.def);
minetest.register_craft(SssStpP.craft.def2);

minetest.register_node(SssStpP.name, SssStpP.defNode);

minetest.register_abm(SssStpP.defABM);

minetest.register_on_player_receive_fields(SssStpP.onFields);
