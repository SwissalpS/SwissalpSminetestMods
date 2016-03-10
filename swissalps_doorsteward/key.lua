
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

function SssSdsK.on_place(oItemStack, oPlacer, oPointedThing)
    if (nil == oPlacer or nil == oPointedThing) then
        return oItemStack; -- nothing consumed
    end;
    local sName = oPlacer:get_player_name();
    local tPos  = minetest.get_pointed_thing_position(oPointedThing, false); -- not above

    if ((nil == tPos) or (nil == tPos.x)) then
        SwissalpS.info.notifyPlayer(sName, 'Position not found.');
        return oItemStack;
    end;

    local oNode = minetest.get_node(tPos);
    local tMeta = minetest.get_meta(tPos);
    print(oNode.name, dump(tMeta));
    SwissalpS.info.notifyPlayer(sName, oNode.name);

    -- find nearest door to tPos
    -- check authority
    -- show form

    return oItemStack; -- nothing consumed, nothing changed
end;

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
