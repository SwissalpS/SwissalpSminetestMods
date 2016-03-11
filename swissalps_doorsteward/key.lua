
SwissalpS.doorsteward.key = {};
SssSdsK = SwissalpS.doorsteward.key;
SssSdsK.name = 'swissalps_doorsteward:key';
SssSdsK.description = 'SwissalpS doorsteward key. Left-click with it to get information about who owns the door you clicked on.';
SssSdsK.inventory_image = 'default_book.png'; --TODO:
SssSdsK.wield_image = '';
SssSdsK.wield_scale = {x=1, y=1, z=1};
SssSdsK.stack_max = 1; -- there is no need to have more than one
SssSdsK.liquids_pointable = false; -- we only need doors:*
-- the tool_capabilities are completely irrelevant here - no need to dig
SssSdsK.tool_capabilities = {
    full_punch_interval = 1.0,
    max_drop_level = 0,
    groupcaps = {
        fleshy = {times = {[2] = 0.80, [3] = 0.40}, maxwear = 0.05, maxlevel = 1},
        snappy = {times = {[2] = 0.80, [3] = 0.40}, maxwear = 0.05, maxlevel = 1},
        choppy = {times = {[3] = 0.90}, maxwear = 0.05, maxlevel = 0}
    },
};
SssSdsK.formEdit = {};
SssSdsK.formEdit.name = 'swissalps_doorsteward:edit';

-- assumes that tPos has been checked to be the bottom node of a valid door
-- also that player has change permissions
function SssSdsK.showForm(tPos, sPlayer)
    assert(nil ~= tPos and nil ~= tPos.x and nil ~= tPos.y and nil ~= tPos.z, 'invalid position passed');
    assert('string' == type(sPlayer) and '' ~= sPlayer, 'invalid player name passed');
    local isSuperUser = false;
    if minetest.check_player_privs(sPlayer, {server = true})
        or minetest.check_player_privs(sPlayer, {SwissalpS_doorsteward_Global = true})then
		isSuperUser = true;
	end; -- admins may change anything
	-- owner may always change his doors
	local tMeta = minetest.get_meta(tPos);
	local sOwner = tMeta:get_string('doors_owner') or '';
    local isOwner = sOwner == sPlayer;
    local hasOwner = 0 < #sOwner;
    local oNode = minetest.get_node(tPos);
	local sKeyGroups = SwissalpS.doorsteward.setting.sMetaKeyGroups;
	local sKeyLeaveOpen = SwissalpS.doorsteward.setting.sMetaKeyLeaveOpen;
	local sKeyActive = SwissalpS.doorsteward.setting.sMetaKeyActive;
    local sGroups = tMeta:get_string(sKeyGroups) or '';
	local sActive = tMeta:get_string(sKeyActive) or 'true';
	local sLeaveOpen = tMeta:get_string(sKeyLeaveOpen) or 'false';
    local sFormSpec = 'size[9,6]'
		.. 'label[0,0.2;SwissalpS doorsteward Key Edit: '
		.. minetest.pos_to_string(tPos) .. ' ' .. oNode.name .. ']';
    local sFowner;
    if isSuperUser or isOwner then
print('isSuperUser or isOwner');
        sFowner = 'field[1,1.4;5,1;doors_owner;Owner:;' .. sOwner .. ']';
    else
print('is not owner or admin');
        sFowner = 'label[0,1.4;Owner: ';
        if hasOwner then
            sFowner = sFowner .. sOwner .. ']';
        else
            sFowner = sFowner .. '-none-]';
        end; -- if hase owner at all
    end; -- setup owner
    local sFgroups = 'field[1,3.8;7,1;doors_groups;Door opens for members of these groups:;' .. sGroups .. ']';
    local sFbuttonOK = '';--'button_exit[4,5;4,1;buttonOK;OK]';
    local sFbuttonCancel = '';--'button_exit[1,5;3,1;buttonCancel;Cancel]';
    local sFbuttonClose = 'button_exit[4,5;4,1;buttonClose;Close]';
    local sFcheckboxLeaveOpen = 'checkbox[1,2.5;bLeaveOpen;Leave this door open;' .. sLeaveOpen .. ']';
    local sFcheckboxSteward = 'checkbox[1,1.8;bStewardActive;Use Steward on this door;' .. sActive .. ']';
    sFormSpec = sFormSpec .. sFowner .. sFgroups .. sFbuttonOK .. sFbuttonCancel;
    sFormSpec = sFormSpec .. sFcheckboxLeaveOpen .. sFcheckboxSteward;
	sFormSpec = sFormSpec .. sFbuttonClose;
	local sFormName = SssSdsK.formEdit.name .. '|' .. minetest.pos_to_string(tPos);
    minetest.show_formspec(sPlayer, sFormName, sFormSpec);
end; -- SssSdsK.showForm

function SssSdsK.onFields(oPlayer, sForm, tFields)
	if not (tFields and 1 == string.find(sForm, SssSdsK.formEdit.name)) then
		-- not a form we know of
		return;
	end; -- if not a form we know of
	local sPlayer = oPlayer:get_player_name();
	print('Player ' .. sPlayer .. ' submitted fields ' .. dump(tFields));
	SwissalpS.info.notifyPlayer(sPlayer, dump(tFields));
	local aParts = string.split(sForm, '|');
	local sPos = aParts[2];
	local tPos = minetest.string_to_pos(sPos);
	print(dump(tPos));
	local tMeta = minetest.get_meta(tPos);
	local sKeyGroups = SwissalpS.doorsteward.setting.sMetaKeyGroups;

	if nil ~= tFields.doors_owner then
		local sOwnerNew = string.trim(tFields.doors_owner);
		local sOwnerOld = tMeta:get_string('doors_owner') or '';
		if sOwnerOld ~= sOwnerNew and '' ~= sOwnerNew then
			tMeta:set_string('doors_owner', sOwnerNew);
		end;
	end; -- if owner set
	if nil ~= tFields.doors_groups then
		local sGroupsNewRaw = string.trim(tFields.doors_groups);
		local sGroupsOld = tMeta:get_string(sKeyGroups) or '';
		local sGroupsNew = sGroupsNewRaw;
		--TODO: compare better
		if sGroupsOld ~= sGroupsNew then
			tMeta:set_string(sKeyGroups, sGroupsNew);
		end; -- if changed
	end; -- if groups set
end; -- SssSdsK.onFields

function SssSdsK.onPlace(oItemStack, oPlacer, oPointedThing)
    if (nil == oPlacer or nil == oPointedThing) then
        return oItemStack; -- nothing consumed
    end;
    local sPlayer = oPlacer:get_player_name();
    local tPos = minetest.get_pointed_thing_position(oPointedThing, false); -- not above

    if ((nil == tPos) or (nil == tPos.x)) then
        SwissalpS.info.notifyPlayer(sPlayer, 'Position not found.');
        return oItemStack;
    end;

    local oNode = minetest.get_node(tPos);
    if nil == oNode then
        SwissalpS.info.notifyPlayer(sPlayer, 'Could not get node.');
        return oItemStack;
    end;
    -- check for door
    if not SwissalpS.doorsteward:isDoor(oNode) then
        SwissalpS.info.notifyPlayer(sPlayer, 'Not a door I can help with.');
        return oItemStack;
    end;
    -- check that is bottom
    if not SwissalpS.doorsteward:isBottomNode(oNode) then
        tPos.y = tPos.y -1;
        -- double check
        oNode = minetest.get_node(tPos);
        if nil == oNode then
            SwissalpS.info.notifyPlayer(sPlayer, 'Could not get node.');
            return oItemStack;
        end; -- if nothing useable
        -- check for door
        if not SwissalpS.doorsteward:isDoor(oNode) then
            SwissalpS.info.notifyPlayer(sPlayer, 'Not a door I can help with.');
            return oItemStack;
        end; -- if not door
        -- check that is bottom
        if not SwissalpS.doorsteward:isBottomNode(oNode) then
            SwissalpS.info.notifyPlayer(sPlayer, 'KO: gave up trying to find door.');
            return oItemStack;
        end; -- if not bottom node AGAIN
    end; -- if not bottom node

    -- check authority
    if not SwissalpS.doorsteward.mayChange(tPos, sPlayer) then
        SwissalpS.info.notifyPlayer(sPlayer, 'You may not change this door, But here is a list of who can: TODO:');
        return oItemStack;
    end; -- if may not change
    -- show form
    SssSdsK.showForm(tPos, sPlayer);
    return oItemStack; -- nothing consumed, nothing changed
end; -- SssSdsK.onPlace

SssSdsK.def = {
    description = SssSdsK.description,
    groups = {},
    inventory_image = SssSdsK.inventory_image,
    wield_image = SssSdsK.wield_image,
    wield_scale = SssSdsK.wield_scale,
    stack_max = SssSdsK.stack_max,
    liquids_pointable = SssSdsK.liquids_pointable,
    tool_capabilities = SssSdsK.tool_capabilities,
    node_placement_prediction = nil,

    on_place = SssSdsK.onPlace,
    on_use = SssSdsK.onPlace,
};

SssSdsK.craft = {};
SssSdsK.craft.recipe = {
    { 'default:book' },
    { 'doors:door_steel' },
    { 'default:book'}
};

SssSdsK.craft.def = {
    output = SssSdsK.name,
    recipe = SssSdsK.craft.recipe,
};

minetest.register_tool(SssSdsK.name, SssSdsK.def);

minetest.register_craft(SssSdsK.craft.def);

minetest.register_on_player_receive_fields(SssSdsK.onFields);
