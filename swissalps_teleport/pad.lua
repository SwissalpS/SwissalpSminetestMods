
SwissalpS.teleport.pad = {};
SssStpP = SwissalpS.teleport.pad;
SssStpP.name = 'swissalps_teleport:pad';
SssStpP.description = 'SwissalpS Teleport Pad. Right-click it to configure.';

SssStpP.bHasCompassGPS = nil ~= minetest.get_modpath('compassgps');
SssStpP.cacheStore = {};
SssStpP.inventoryImage = 'swissalps_teleport_pad.png';
SssStpP.iMaxCoordinate = 30912; -- official −30912 to 30927; -- e.g. xmin = -65536; xmax = 65536;
SssStpP.iMinRadiusFromSpawn = 1000;
SssStpP.iRadiusHole = 5; -- will add 3 for thick walls and one more for ledge
SssStpP.formAdvanced = {};
SssStpP.formAdvanced.name = 'swissalps_teleport:padAdvanced';
SssStpP.formAdvanced.sDropDownCustomTypeValues = 'Random Bookmark,Random From List,Random New Destination';
SssStpP.formAdvanced.tDropDownCustomTypeValues = string.split(SssStpP.formAdvanced.sDropDownCustomTypeValues, ',');
SssStpP.formStandard = {};
SssStpP.formStandard.name = 'swissalps_teleport:padStandard';
SssStpP.soundArrive = 'swissalps_teleport_padArrive';
SssStpP.soundLeave = 'swissalps_teleport_padLeave';

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


local sPathMod = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM;
dofile(sPathMod .. 'padFunctions.lua');

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
