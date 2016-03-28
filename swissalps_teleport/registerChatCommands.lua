-- Minetest mod: swissalps_teleport
-- See LICENSE.txt and README.txt for licensing and other information.

minetest.register_chatcommand('-tp', {
	params = 'slot',
	description = 'teleport to slot',
	privs = {},
	func = SwissalpS.teleport.cc_goToSlot,
});

minetest.register_chatcommand('-tpg', {
	params = 'slot',
	description = 'teleport to global slot',
	privs = {},
	func = SwissalpS.teleport.cc_goToSlotGlobal,
});

minetest.register_chatcommand('-tpgh', {
	params = '',
	description = 'teleport to global home',
	privs = {},
	func = SwissalpS.teleport.cc_goHomeGlobal,
});

minetest.register_chatcommand('-tpghome', {
	params = '',
	description = 'teleport to global home',
	privs = {},
	func = SwissalpS.teleport.cc_goHomeGlobal,
});

minetest.register_chatcommand('-tpgs', {
	params = 'slot',
	description = 'set global teleport point',
	privs = {[SssStp.sPrivGlobal] = true},
	func = SwissalpS.teleport.cc_saveSlot,
});

minetest.register_chatcommand('-tpgset', {
	params = 'slot',
	description = 'set global teleport point',
	privs = {[SssStp.sPrivGlobal] = true},
	func = SwissalpS.teleport.cc_saveSlot,
});

minetest.register_chatcommand('-tpgsethome', {
	params = '',
	description = 'set global home',
	privs = {[SssStp.sPrivGlobal] = true},
	func = SwissalpS.teleport.cc_setHomeGlobal,
});

minetest.register_chatcommand('-tpgsh', {
	params = '',
	description = 'set global home',
	privs = {[SssStp.sPrivGlobal] = true},
	func = SwissalpS.teleport.cc_setHomeGlobal,
});

minetest.register_chatcommand('-tph', {
	params = '',
	description = 'teleport home',
	privs = {},
	func = SwissalpS.teleport.cc_goHome,
});

minetest.register_chatcommand('-tphelp', {
	parapms = '',
	description = 'list commands added by SwissalpS.teleport',
	privs = {},
	func = SwissalpS.teleport.cc_help
});

minetest.register_chatcommand('-tphome', {
	params = '',
	description = 'teleport home',
	privs = {},
	func = SwissalpS.teleport.cc_goHome,
});

minetest.register_chatcommand('-tpl', {
	params = '',
	description = 'list slots',
	privs = {},
	func = SwissalpS.teleport.cc_listSlots,
});

minetest.register_chatcommand('-tps', {
	params = 'slot',
	description = 'set teleport point',
	privs = {},
	func = SwissalpS.teleport.cc_saveSlot,
});

minetest.register_chatcommand('-tpset', {
	params = 'slot',
	description = 'set teleport point',
	privs = {},
	func = SwissalpS.teleport.cc_saveSlot,
});

minetest.register_chatcommand('-tpsethome', {
	params = '',
	description = 'set home',
	privs = {},
	func = SwissalpS.teleport.cc_setHome,
});

minetest.register_chatcommand('-tpsh', {
	params = '',
	description = 'set home',
	privs = {},
	func = SwissalpS.teleport.cc_setHome,
});
