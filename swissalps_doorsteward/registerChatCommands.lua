-- Minetest mod: swissalps_doorsteward
-- See LICENSE.txt and README.txt for licensing and other information.

minetest.register_chatcommand('-dsa', {
	params = '<Player1[,Player2..,PlayerN]> <addToGroup1[,addToGroup2..,addToGroupN]>',
	description = 'Add Player(s) to Group(s)',
	privs = {},
	func = SwissalpS.doorsteward.cc_addPlayersToGroups
})

minetest.register_chatcommand('-dsr', {
	params = '<Player1[,Player2..,PlayerN]> <removeFromGroup1[,removeFromGroup2..,removeFromGroupN]>',
	description = 'Remove Player(s) from Group(s)',
	privs = {},
	func = SwissalpS.doorsteward.cc_removePlayersFromGroups
})

minetest.register_chatcommand('-dsl', {
	params = '[<Player>]',
	description = 'List all Groups Player is a member of.',
	privs = {},
	func = SwissalpS.doorsteward.cc_listPlayerGroups
})
