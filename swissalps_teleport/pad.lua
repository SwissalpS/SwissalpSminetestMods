
SwissalpS.teleport.pad = {};
SssStpP = SwissalpS.teleport.pad;
SssStpP.name = 'swissalps_teleport:pad';
SssStpP.description = 'SwissalpS Teleport Pad. Right-click it to configure.';
SssStpP.inventoryImage = 'swissalps_teleport_pad.png';
SssStpP.soundArrive = 'swissalps_teleport_padArrive.ogg';
SssStpP.soundLeave = 'swissalps_teleport_padLeave.ogg';
SssStpP.formAdvanced = {};
SssStpP.formAdvanced.name = 'swissalps_teleport:padAdvanced';
SssStpP.formStandard = {};
SssStpP.formStandard.name = 'swissalps_teleport:padStandard';

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
		SwissalpS.info.notifyPlayer(sPlayer, 'o: ' .. sTitle .. ' n: ' .. sTitleNew);
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
		SwissalpS.info.notifyPlayer(sPlayer, 'need to update infotext');
		--infotext="Teleporter is Disabled"
		--infotext="Teleporter Offline"
		--tMeta:set_float('enabled', -1);
		local sTitle = tMeta:get_string('title');
		local sPos = minetest.pos_to_string(SssStpP.metaToPos(tMeta), 1);
		tMeta:set_string('infotext', '"Teleport to ' .. sTitle .. ' '
						 .. sPos .. '"');
	end; -- if need to update other fields
	if nil ~= tFields.buttonAdvanced then
		SwissalpS.info.notifyPlayer(sPlayer, 'advanced button clicked');
		SssStpP.showFormAdvanced(tPos, sPlayer);
	end; -- if advanced clicked
	return true;
end; -- SssStpP.onFieldsStandard

function SssStpP.onFieldsAdvanced(tPos, tFields, sPlayer)
	local tMeta = minetest.get_meta(tPos);
	print('Player, ' .. sPlayer .. ', submitted fields ' .. dump(tFields));
	SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
end; -- SssStpP.onFieldsAdvanced

function SssStpP.onRightClick(tPos, oNodePad, oPlayer)
	-- check authority
	local sPlayer = oPlayer:get_player_name();
	local tMeta = minetest.get_meta(tPos);
	-- show standard form
	local tTarget = SssStpP.metaToPos(tMeta);
	local sFormSpec = 'size[6,6]'
			.. 'field[0.5,0.5;4,1;sTitle;Destination Title;' .. tMeta:get_string('title') .. ']'
			.. 'field[0.5,1.5;2,1;fX;X-coordinate;' .. tTarget.x .. ']'
			.. 'field[0.5,2.5;2,1;fY;Y-coordinate;' .. tTarget.y .. ']'
			.. 'field[0.5,3.5;2,1;fZ;Z-coordinate;' .. tTarget.z .. ']'
			.. 'button[0.5,4.5;2,1;buttonAdvanced;Advanced]'
			.. 'button_exit[3.5,4.5;2,1;buttonClose;Close]';
	local sFormName = SssStpP.formStandard.name .. '|' .. minetest.pos_to_string(tPos);
	minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.onRightClick

function SssStpP.showFormAdvanced(tPos, sPlayer)
	local sFormSpec = 'size[9,9]'
			.. 'label[0,0.2;SwissalpS teleport Pad Advanced: '
			.. minetest.pos_to_string(tPos, 1) .. ']'
			.. 'button_exit[3.5,4.5;3,1;buttonClose;Close]';
	local sFormName = SssStpP.formAdvanced.name .. '|' .. minetest.pos_to_string(tPos);
    minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.showFormAdvanced

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
