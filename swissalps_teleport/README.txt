SwissalpS Teleport Minetest Mod [swissalps_teleport]
Written by Luke Zimmermann aka SwissalpS
Luke@SwissalpS.ws

This mod provides chat commands to teleport to bookmarks.
Also a Teleport-Pad-Node that can...
... teleport players to a pre-defined destination (traditional).
... teleport players to a random place in their bookmarks (supports CompassGPS)
... teleport players to a random location from a pre-defined list of locations.
... teleport players to a random, unclaimed area. (main reason for writing this)

Node(s):
========
To get the Teleport-Pad either:
/giveme swissalps_teleport:pad
or craft I:
	G = default:glass
	M = default:mese
	W = default:wood

	W W W
	W M W
	W G W
or craft II:
	C = moreores:copper_ingot
	P = mesecons_powerplant:power_plant
	O = moreores:gold_block
	G = default:glass

	C P C
	C O C
	C G C

Place the pad and right-click it to configure.

Chat commands:
==============
teleport to slot
/-tp <slot name>

teleport to global slot
/-tpg <global slot name>

teleport to global home
/-tpgh
or
/-tpghome

set global teleport point (requires privilege: SwissalpS_teleport_Global)
/-tpgs <global slot name>
or
/-tpgset <global slot name>

set global home (requires privilege: SwissalpS_teleport_Global)
/-tpgsh
or
/-tpgsethome

teleport home
/-tph
or
/-tphome

list commands added by SwissalpS.teleport
/-tphelp

list slots
/-tpl

set teleport point
/-tps <slot name>
or
/-tpset <slot name>

set home
/-tpsh
or
/-tpsethome

All commands that set bookmarks, use the issuing player's location.

Tool(s):
========
none

Dependencies:
=============
+mod:swissalps_db
+mod:swissalps_info
If present, can make use of:
mod:areas
mod:compassgps

Notes:
======
- This mod can transport players very far in a very short time. You may need to
  tweak to avoid cheat-detectors from reporting false-positives.
- Names of slots have not been tested with spaces or special characters.

History:
========
My game needed a way to assign new claims for players who don't want to go
exploring on their own. I have a couple of doors they can choose from.
Behind each door is a pad that is uniquely set-up.
Example: one pad targets underground areas where another pad targets areas in
the sky and yet another looks for something around ground-level.
While learning how to achieve this, I did not have internet connection, but I
did have a couple of mods and the source-code.

Special thanks to:
Bad_Command [teleporter]
All those involved in [compassgps]
I learned a lot reading your code and mine may reflect some aspects.
Ogrebane for providing a basic sound-bite for me to resample and add effects.
