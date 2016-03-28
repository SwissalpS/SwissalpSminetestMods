SwissalpS Door Steward Minetest Mod [swissalps_doorsteward]
Written by Luke Zimmermann aka SwissalpS
Luke@SwissalpS.ws

This mod provides automatic doors.
By default, doors open when a authorized player stands close to it.
Example: a default wooden door will open for anyone where as a
steel door will only open for it's owner.
Both will close once there is no authorized player nearby.

Tool(s):
========
The doors behaviour can be changed with a key.
/giveme swissalps_doorsteward:key
or craft:
	B = default:book
	D = doors:door_steel

	B
	D
	B

Punch a door with the key. A form pops up where you can...
... deactivate Door Steward for this door.
... leave door open.
... change which group members are authorized.

Chat commands:
==============
Add Player(s) to Group(s)
/-dsa <Player1[,Player2..,PlayerN]> <addToGroup1[,addToGroup2..,addToGroupN]>

Remove Player(s) from Group(s)
/-dsr <Player1[,Player2..,PlayerN]> <removeFromGroup1[,removeFromGroup2..,removeFromGroupN]>

List all Groups Player is a member of
/-dsl [<Player>]

TODO: authorization to modify groups.
At the moment, owner or server may change groups and ownership.
If a user is of an authorized group and also in the admin group of that group,
he may modify.
This behaviour may change, as I am still learning about how Minetest works.
Maybe there is already a popular mod that supplies player-groups.

Node(s):
========
none

Dependencies:
=============
?mod:doors
+mod:swissalps_info
+swissalps_db
+swissalps_utils

History:
========
I was annoyed about having to close doors.
Also I wanted my game to have a way of blocking off players from certain
areas before they had completed some task.
