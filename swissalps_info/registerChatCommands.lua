-- Minetest mod: swissalps_info
-- See LICENSE.txt and README.txt for licensing and other information.

minetest.register_chatcommand('-ilab', {
	params = '[restrict_to_mod]',
	description = 'List all available nodes',
	privs = {},
	func = SwissalpS.info.cc_listAvailableBlocks
})

minetest.register_chatcommand('-ilam', {
	params = '[restrict_to_mod]',
	description = 'List all available mobs',
	privs = {},
	func = SwissalpS.info.cc_listAvailableMobs
})

minetest.register_chatcommand('-ilamethods', {
	params = '[restrict_to_mod]',
	description = 'List all available methods',
	privs = {},
	func = SwissalpS.info.cc_listAvailableMethods
})
