SwissalpS DB Minetest Mod [swissalps_db]
Written by Luke Zimmermann aka SwissalpS
Luke@SwissalpS.ws

This mod provides a persistent player database.
It is based on a mod I found in the forum.
https://forum.minetest.net/viewtopic.php?f=11&t=9276&hilit=playerdb
-- This is a library for Minetest mods
-- author: addi <addi at king-arhtur dot eu>
-- for documentation see : https://project.king-arthur.eu/projects/db/wiki
-- license: LGPL v3
-- SwissalpS could not get in touch with author, so here we
-- have bound it in to SwissalpS repo and modified to our liking

Dependencies:
+mod:swissalps_info -- can easily be made to run without.

Usage example:
mod:swissalps_teleport

History:
I wanted to save locations per player and have them persist between games.
So a search in the Minetest mod forum I found Addi's approach and liked it.
To learn and understand how it works, I went through the code line by line
changing things here and there as we went. But basically it is still what Addi
had provided.

There is one incompatible change: Addi has a field, fs.form, which I changed to
fs.format.
