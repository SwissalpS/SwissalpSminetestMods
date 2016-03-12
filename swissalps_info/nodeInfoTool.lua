
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

function SssSiNiT.onPlace(oItemStack, oPlacer, oPointedThing)
    if (nil == oPlacer or nil == oPointedThing) then
        return oItemStack; -- nothing consumed
    end;
    local sName = oPlacer:get_player_name();
    local tPos  = minetest.get_pointed_thing_position(oPointedThing, false); -- not above
    if ((nil == tPos) or (nil == tPos.x)) then
        SwissalpS.info.notifyPlayer(sName, 'Position not found.');
        return oItemStack;
    end;
    local sInfo = 'Position: ' .. minetest.pos_to_string(tPos, 2);
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
            --SwissalpS.info.notifyPlayer(sName, 'Meta-data: ' .. dump(tMeta:to_table()));
            local ttMeta = tMeta:to_table();
            for sKey, mValue in pairs(ttMeta.fields) do
                sInfo = sInfo .. "\n" .. 'meta.' .. sKey .. ' = ';
                if 'formspec' == sKey then
                    if nil == mValue then
                        sInfo = sInfo .. 'nil';
                    else
                        sInfo = sInfo .. '<exists>';
                    end; -- if got formspec or not
                elseif 'inventory' == sKey then
                    if nil == mValue then
                        sInfo = sInfo .. 'nil';
                    else
                        sInfo = sInfo .. #mValue .. ' exist(s)';
                    end; -- if got at least one inventory or not
                elseif 'infotext' == sKey
                        or 'text' == sKey
                        or 'owner' == sKey then
                    sInfo = sInfo .. tMeta:get_string(sKey);
                else
                    sInfo = sInfo .. dump(sValue);
                end; -- if which key
            end; -- loop all entries in meta
        end; -- if failed to fetch meta
    elseif 'object' == oPointedThing.type then
        local oObject = oPointedThing.ref;
        if nil == oObject then
            SwissalpS.info.notifyPlayer(sName, 'Object not found.');
            return oItemStack;
        end; -- if no object
        sInfo = sInfo .. "\n" .. 'object:get_luaentity().name: '
                .. oObject:get_luaentity().name
                .. '  object:get_hp(): ' .. oObject:get_hp();
        --sInfo = sInfo .. "\n" .. 'object:getpos(): ' .. minetest.pos_to_string(oObject:getpos(), 3);
        sInfo = sInfo .. "\n" .. 'object:getyaw(): ' .. oObject:getyaw()
                .. '  object:getvelocity(): ' .. dump(oObject:getvelocity())
                .. '  object:getacceleration(): ' .. dump(oObject:getacceleration());
        --sInfo = sInfo .. "\n" .. 'object:get_armor_groups(): ' .. dump(oObject:get_armor_groups()); -- not yet implemented Returns {group1=rating, group2=rating, ...})
        sInfo = sInfo .. "\n" .. 'object:get_inventory(): '
                .. dump(oObject:get_inventory())
                .. '  object:get_wielded_item(): '
                .. dump(oObject:get_wielded_item())
                .. '  object:get_wield_index(): '
                .. dump(oObject:get_wield_index())
                .. '  object:get_wield_list(): '
                .. dump(oObject:get_wield_list());
    else
        print('unknown pointed_thing.type detected');
        sInfo = sInfo .. "\n" .. 'Sorry, can not yet help with that.';
    end;
    SwissalpS.info.notifyPlayer(sName, sInfo);
    return oItemStack; -- nothing consumed, nothing changed
end; -- SssSiNiT.onPlace

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

    on_place = SssSiNiT.onPlace,
    on_use = SssSiNiT.onPlace,
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
