minetest CSM which implements waypoints on top of the /teleport server side command.

Based on https://github.com/fluxionary/minetest-cs_waypoints
and new developement by Och_Noe (LinuxForks) at
https://git.bananach.space/cs_waypoints.git/

requirements
------------

tested with minetest 0.4.17 and 5.0.

in 5.0, the server *must* have send_chat_message enabled, which is not the default.

additionally, this mod will *only* work if your account has the "teleport" privilege.
it will *not* let ordinary users teleport, unless that is a default privilege.

installation
------------

make sure the mod is installed at `~/.minetest/clientmods/cs_waypoints`

make sure `~/.minetest/clientmods/mods.conf` exists and contains:

```
load_mod_cs_waypoints = true
```

usage
-----

* .wp_set NAME: set a waypoint at your current location
* .wp_unset NAME: remove a waypoint
* .wp_list: list all waypoints
* .tw NAME: teleport to a waypoint
* .tw PLAYERNAME WAYPOINT_NAME: teleport another player to a waypoint
* .tr: teleport to a random location
* .tr ELEVATION: teleport to a random location at a given elevation (y value)

* .tw_push NAME: teleport to a waypoint and save current location
* .wp_push PLAYER/POSITION: teleport to a player or position and save current location

* .tw_pop; return to the last saved location
* .wp_pop: return to the last saved location

* .wp_stack: shows the locations in the stack

* .wp_stack_clear: clears the stack

* .wp_search DELTA: searches for saved waypoints near te current location with the given delta for all coordinates
* .wp_search: searches for saved waypoints near te current location with DELTA=10
    
* .wp_shift AXIS DISTANCE: moves you on the given axis the given distance

* .wp_grep NAME:  search for NAME in the waypoint names
