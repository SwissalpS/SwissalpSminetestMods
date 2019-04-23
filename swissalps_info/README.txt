SwissalpS Info Minetest Mod [swissalps_info]
Written by Luke Zimmermann aka SwissalpS
Luke@SwissalpS.ws

This mod provides chat commands and a Node-Info-Tool for inspection.
It also provides a wrapper to notify players.

Tool(s):
========
To get the Node-Info-Tool either:
/giveme swissalps_info:node_info_tool
or craft:
	B = default:book

	B
	B
	B


Punch at nodes and mobs with the Node-Info-Tool. A selection of information
will be presented through the chat interface.

Chat commands:
==============
List all available nodes. Narrow down providing mod-name.
/-ilab [<restrict to mod name>]

List all available mobs. (TODO: code this)
/-ilam [<restrict to mod name>]

List all available methods (TODO: code this, currently lists methods of core)
/-ilamethods [<restrict to mod name>]
that supplies player-groups.

Node(s):
========
none

Dependencies:
=============
none

API/exposed functions:
======================
SwissalpS.info.cc_listAvailableBlocks(sPlayer, sModName)
SwissalpS.info.cc_listAvailableMethods(sPlayer, o) -- not yet coded properly
SwissalpS.info.cc_listAvailableMobs(sPlayer, sMobName) -- not yet coded
SwissalpS.info.bCanShell -- not tested
SwissalpS.info.notifyPlayer(sPlayer, sMessage) -- wrapper to minetest.chat_send_player(
												sPlayer, 'SssSinfo - ' .. sMessage, false)
SwissalpS.info.broadcast(sMessage) -- wrapper to minetest.chat_send_all(
																'SssSinfo b- ' .. sMessage)
SwissalpS.info.timerDiff(oMod) -- for displaying load times
SwissalpS.info.timerDiffLog(oMod)
SwissalpS.info.timerStart(oMod)
SssSiNiT -- alias to SwissalpS.info.nodeInfoTool

History:
========
My very first mod. Hello World, as it was.
I liked the way some mods log the duration to load. So I made it my tutorial
to wrap that functionality for reuse in all my mods.
Yes, I am aware, there are a lot of node inspection tools out there. I wanted
to write my own to learn Minetest-Lua.
