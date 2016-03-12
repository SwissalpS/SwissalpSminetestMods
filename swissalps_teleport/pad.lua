
SwissalpS.teleport.pad = {};
SssStpP = SwissalpS.teleport.pad;
SssStpP.name = 'swissalps_teleport:pad';
SssStpP.description = 'SwissalpS Teleport Pad. Right-click it to configure.';
SssStpP.inventoryImage = 'swissalps_teleport_pad.png';
SssStpP.soundArrive = 'swissalps_teleport_padArrive.ogg';
SssStpP.soundLeave = 'swissalps_teleport_padLeave.ogg';
SssStpP.formAdvanced = {};
SssStpP.formAdvanced.name = 'swissalps_teleport:padAdvanced';

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
		return;
	end; -- if nil passed for meta
	return {
		x = math.max(0, tMeta:get_float('x')),
		y = math.max(0, tMeta:get_float('y')),
		z = math.max(0, tMeta:get_float('z')),
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
	local sFormSpec = 'size[6,6]'
			.. 'field[0.5,0.5;7,1;sTitle;Destination Title;' .. sTitleDefault .. ']'
			.. 'field[0.5,1.5;4,1;fX;X-coordinate;' .. tPosDefault.x .. ']'
			.. 'field[0.5,2.5;4,1;fY;Y-coordinate;' .. tPosDefault.y .. ']'
			.. 'field[0.5,3.5;4,1;fZ;Z-coordinate;' .. tPosDefault.z .. ']'
			.. 'button[0.5,4.5;3,1;buttonAdvanced;Advanced]'
			.. 'button_exit[3.5,4.5;3,1;buttonClose;Close]';
	tMeta:set_string('formspec', sFormSpec);
	tMeta:set_string('infotext', '"Teleport to ' .. sTitleDefault .. '"');
	tMeta:set_string('text', sPosDefault .. ',' .. sTitleDefault);
	tMeta:set_string('title', sTitleDefault);
	tMeta:set_float('enabled', -1);
	SssStpP.posToMeta(tPosDefault, tMeta);
end; -- SssStpP.onConstruct

function SssStpP.onFields(tPos, sForm, tFields, oSender)
	local tMeta = minetest.get_meta(tPos);
	local tTarget = SssStpP.metaToPos(tMeta);
	local sPlayer = oSender:get_player_name();
	if not sPlayer or '' == sPlayer then
		print('KO: invalid player passed');
		return false;
	end; -- if invalid player
	local sOwner = tMeta:get_string('owner');
	local isOwner = sPlayer == sOwner;
	local isAdmin = minetest.check_player_privs(sPlayer, {server = true});
	if not isOwner then
		SwissalpS.info.notifyPlayer(sPlayer, 'This pad belongs to ' .. sOwner);
		if not isAdmin then
			return false;
		end; -- if not admin
	end; -- if not owner

	SwissalpS.info.notifyPlayer(sPlayer, 'checking fields...');
	local bNeedsUpdate = false;

	if nil ~= tFields.sTitle then
		local sTitle = tMeta:get_string('title');
		if sTitle ~= tFields.sTitle then
			bNeedsUpdate = true;
			tMeta:set_string('title', tFields.sTitle);
		end; -- if changed
	end; -- if title given
	if nil ~= tFields.fX then
		local fVal = tMeta:get_float('x');
		local fValNew = tonumber(tFields.fX);
		print(fValNew);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('x', fValNew);
		end; -- if changed
	end; -- if X given
	if nil ~= tFields.fY then
		local fVal = tMeta:get_float('y');
		local fValNew = tonumber(tFields.fY);
		print(fValNew);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('y', fValNew);
		end; -- if changed
	end; -- if Y given
	if nil ~= tFields.fZ then
		local fVal = tMeta:get_float('z');
		local fValNew = tonumber(tFields.fZ);
		print(fValNew);
		if fVal ~= fValNew then
			bNeedsUpdate = true;
			tMeta:set_float('z', fValNew);
		end; -- if changed
	end; -- if Z given
	if bNeedsUpdate then
	--			infotext="Teleporter is Disabled"
		--	meta:set_float("enabled", -1)
		--infotext="Teleporter Offline"
	end; -- if need to update other fields
	if nil ~= tFields.buttonAdvanced then
		SwissalpS.info.notifyPlayer(sPlayer, 'advanced button clicked');
		SssStpP.showForm(tPos, sPlayer);
	end; -- if advanced clicked
end; -- SssStpP.onFields

function SssStpP.onFieldsAdvanced(oPlayer, sForm, tFields)
	if not (tFields and 1 == string.find(sForm, SssStpP.formAdvanced.name)) then
		-- not the form we know of
		return false;
	end; -- if not the form we expect
	local sPlayer = oPlayer:get_player_name();
	print('Player ' .. sPlayer .. ' submitted fields ' .. dump(tFields));
	SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
	local aParts = string.split(sForm, '|');
	local sPos = aParts[2];
	local tPos = minetest.string_to_pos(sPos);
	local tMeta = minetest.get_meta(tPos);
end; -- SssStpP.onFieldsAdvanced

function SssStpP.showForm(tPos, sPlayer)
	local sFormSpec = 'size[9,9]'
			.. 'label[0,0.2;SwissalpS teleport Pad Advanced: '
			.. minetest.pos_to_string(tPos, 1) .. ']'
			.. 'button_exit[3.5,4.5;3,1;buttonClose;Close]';
	local sFormName = SssStpP.formAdvanced.name .. '|' .. minetest.pos_to_string(tPos);
    minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssStpP.showForm

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
    on_receive_fields = SssStpP.onFields,
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

minetest.register_on_player_receive_fields(SssStpP.onFieldsAdvanced);