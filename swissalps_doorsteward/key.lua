
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
    local sFormspec = 'size[9,10;]';
    local sFowner
    if isSuperUser or isOwner then
        sFowner = 'field[0,0.2;5,1;owner;Owner:' .. sOwner .. ']';
    else
        sFowner = 'label[0,0.2;Owner: ' .. sOwner .. ']';
    end; -- setup owner
    sFormspec = sFormspec .. sFowner;
    minetest.show_formspec(sPlayer, SssSdsK.formEdit.name, sFormspec);
end; -- SssSdsK.showForm

function SssSdsK.onFields(oPlayer, sForm, tFields)
	if SssSdsK.formEdit.name == sForm then
		print('Player ' .. oPlayer:get_player_name() .. ' submitted fields ' .. dump(tFields));
	end; -- if our form
end; -- SssSdsK.onFields

function SssSdsK.on_place(oItemStack, oPlacer, oPointedThing)
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
    SwissalpS.info.notifyPlayer(sPlayer, oNode.name);
    -- show form
    SssSdsK.showForm(tPos, sPlayer);
    return oItemStack; -- nothing consumed, nothing changed
end; -- SssSdsK.on_place

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

    on_place = SssSdsK.on_place,
    on_use = SssSdsK.on_place,
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
