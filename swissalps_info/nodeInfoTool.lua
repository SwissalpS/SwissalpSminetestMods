
SwissalpS.info.nodeInfoTool = {};
SssSiNiT = SwissalpS.info.nodeInfoTool;
SssSiNiT.name = 'swissalps_info:node_info_tool';
SssSiNiT.description = 'SwissalpS node info tool. Left-click with it to get information about the node you clicked on.';
SssSiNiT.inventory_image = 'swissalps_info_nodeInfoTool.png';
SssSiNiT.wield_image = '';
SssSiNiT.wield_scale = {x = 1, y = 1, z = 1};
SssSiNiT.stack_max = 1; -- there is no need to have more than one
SssSiNiT.liquids_pointable = true;
-- the tool_capabilities are completely irrelevant here - no need to dig
SssSiNiT.tool_capabilities = {
    full_punch_interval = 1.0,
    max_drop_level = 0,
    groupcaps = {
        fleshy = {times = {[2] = 0.80, [3] = 0.40}, maxwear = 0.05, maxlevel = 1},
        snappy = {times = {[2] = 0.80, [3] = 0.40}, maxwear = 0.05, maxlevel = 1},
        choppy = {times = {[3] = 0.90}, maxwear = 0.05, maxlevel = 0}
    },
};

function SssSiNiT.on_place(oItemStack, oPlacer, oPointedThing)
    if (nil == oPlacer or nil == oPointedThing) then
        return oItemStack; -- nothing consumed
    end;
    local sName = oPlacer:get_player_name();
    local tPos  = minetest.get_pointed_thing_position(oPointedThing, false); -- not above
    if ((nil == tPos) or (nil == tPos.x)) then
        SwissalpS.info.notifyPlayer(sName, 'Position not found.');
        return oItemStack;
    end;
    local sInfo = 'position: ' .. minetest.pos_to_string(tPos);
    if 'node' == oPointedThing.type then
        local oNode = minetest.get_node(tPos);
        if (nil == oNode) or (nil == oNode.name) or ('' == oNode.name) then
            SwissalpS.info.notifyPlayer(sName, 'Node not found.');
        else
            for sKey, sValue in pairs(oNode) do
                sInfo = sInfo .. "\n" .. 'node.' .. sKey .. ' = ' .. dump(sValue);
            end; -- loop all entries in node
        end; -- if failed to fetch node at pos
        local tMeta = minetest.get_meta(tPos);
        if nil == tMeta then
            SwissalpS.info.notifyPlayer(sName, 'Meta-data not found.');
        else
            SwissalpS.info.notifyPlayer(sName, 'Meta-data: ' .. dump(tMeta));
            --for sKey, sValue in pairs(tMeta) do
            --    sInfo = sInfo .. "\n" .. 'meta.' .. sKey .. ' = ' .. dump(sValue);
            --end; -- loop all entries in meta
        end; -- if failed to fetch meta
    elseif 'object' == oPointedThing.type then
        local oObject = oPointedThing.ref;
        print(dump(oObject), oObject.name);
        --[[
             getpos() — returns {x=num, y=num, z=num}.
    get_armor_groups() - Returns {group1=rating, group2=rating, ...})

note.png
Note: Documented in lua_api.txt but not yet implemented as of version 0.4.4


    get_hp() — returns number of hitpoints (2 * number of hearts).
    get_inventory() — returns the InvRef of the object.
    get_wielded_item() — returns the wielded item (ItemStack). This is essentially just a pseudonym for object:get_inventory():get_stack(object:get_wield_list(), object:get_wield_index()) so please note the caveats for inventory manipulation (changes will need to be "committed" by calling object:set_wielded_item(modifiedStack) after modifying the stack unless they are done in the context of a callback that implicitly modifies the stack; see minetest.register_node#on_use).
    get_wield_index() — returns the index of the wielded item
    get_wield_list() — returns the name of the inventory list the wielded item is in
    --]]
        sInfo = sInfo .. '';
    else
        print('unknown pointed_thing.type detected');
        sInfo = sInfo .. "\n" .. 'Sorry, can not yet help with that.';
    end;
    SwissalpS.info.notifyPlayer(sName, sInfo);
    return oItemStack; -- nothing consumed, nothing changed
end;

SssSiNiT.def = {
    description = SssSiNiT.description,
    groups = {},
    inventory_image = SssSiNiT.inventory_image,
    wield_image = SssSiNiT.wield_image,
    wield_scale = SssSiNiT.wield_scale,
    stack_max = SssSiNiT.stack_max,
    liquids_pointable = SssSiNiT.liquids_pointable,
    tool_capabilities = SssSiNiT.tool_capabilities,
    node_placement_prediction = nil,

    on_place = SssSiNiT.on_place,
    on_use = SssSiNiT.on_place,
};

SssSiNiT.craft = {};
SssSiNiT.craft.recipe = {
    { 'default:book' },
    { 'default:book' },
    { 'default:book'}
};

SssSiNiT.craft.def = {
    output = SssSiNiT.name,
    recipe = SssSiNiT.craft.recipe,
};

minetest.register_tool(SssSiNiT.name, SssSiNiT.def);

minetest.register_craft(SssSiNiT.craft.def);
