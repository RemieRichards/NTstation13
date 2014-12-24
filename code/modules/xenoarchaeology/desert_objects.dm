/*
 TODO:
 > Fix Hardcoded Mineral rock walls
 > Port desert walls to Mineral rock walls
*/



////////////////////
/// Desert Tiles ///
////////////////////

/turf/simulated/wall/xenoarch_desert
	name = "Desert wall"
	desc = "deserted of all life..."
	icon_state = "desert_rock"
	mineral = ""
	walltype = ""

/turf/simulated/wall/xenoarch_desert/relativewall()
	return

/turf/simulated/wall/xenoarch_desert/New() //TODO: FIX THIS COPY PASTE
	..()

	var/turf/T
	if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)))
		T = get_step(src, NORTH)
		if (T)
			T.overlays += image('icons/turf/walls.dmi', "desert_rock_side_s")
	if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)))
		T = get_step(src, SOUTH)
		if (T)
			T.overlays += image('icons/turf/walls.dmi', "desert_rock_side_n", layer=6)
	if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)))
		T = get_step(src, EAST)
		if (T)
			T.overlays += image('icons/turf/walls.dmi', "desert_rock_side_w", layer=6)
	if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)))
		T = get_step(src, WEST)
		if (T)
			T.overlays += image('icons/turf/walls.dmi', "desert_rock_side_e", layer=6)

	icon_state = "desert_rock"

/turf/simulated/floor/plating/xenoarch_desert
	name = "Desert"
	desc = "deserted of all life..."
	icon_state = "desert0"

/turf/simulated/floor/plating/xenoarch_desert/New()
	..()
	if(prob(20))
		icon_state = "desert[rand(0,12)]"

	xenoarch_digspots += src

/turf/simulated/floor/plating/xenoarch_desert/Del()
	xenoarch_digspots -= src
	..()

/turf/simulated/floor/plating/xenoarch_desert/update_icon()
	return

/turf/simulated/floor/plating/xenoarch_desert/burn_tile()
	return

/turf/simulated/floor/plating/xenoarch_desert/break_tile()
	return

/obj/effect/cactus
	name = "Cactus"
	desc = "The plural of cactus is cacti, if you touch this you'll cac-DIE!"
	icon = 'icons/obj/xenoarchaeology.dmi'
	density = 1
	anchored = 1

/obj/effect/cactus/lower
	icon_state = "cactus_lower"

/obj/effect/cactus/lower/New()
	..()
	var/turf/T = get_step(src,NORTH)
	if(!T.density)
		new /obj/effect/cactus/upper (T)
	else
		qdel(src)

/obj/effect/cactus/upper
	icon_state = "cactus_upper"

/obj/effect/shrub
	anchored = 1
	icon_state = "shrub1"
	icon = 'icons/obj/xenoarchaeology.dmi'

/obj/effect/shrub/New()
	..()
	if(prob(20))
		icon_state = "shrub[rand(1,4)]"


/* //Tumbleweeds are janky, leaving this here incase anyone wants to fix them - RR

/obj/effect/tumbleweed
	name = "tumbleweed"
	desc = "a weed that tumbles along"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "tumbleweed"


/obj/effect/tumbleweed/New()
	..()
	processing_objects += src

/obj/effect/tumbleweed/Del()
	processing_objects -= src
	..()

/obj/effect/tumbleweed/process()
	if(prob(50))
		if(!step(src,EAST))
			icon_state = "tumbleweed-R"
			qdel() //Failure to move results in deletion of tumbleweed
	else
		if(!step(src,WEST))
			icon_state = "tumbleweed-L"
			qdel()

/obj/effect/tumbleweed/spawner
	name = ""
	desc = ""
	icon_state = ""
	icon = ""
	var/last_spawn = 0
	var/spawn_delay_ticks = 600

/obj/effect/tumbleweed/spawner/New()
	..()
	last_spawn = world.time
	new /obj/effect/tumbleweed (src.loc)

/obj/effect/tumbleweed/spawner/process()
	if(last_spawn + spawn_delay_ticks <= world.time)
		new /obj/effect/tumbleweed (src.loc)
		last_spawn = world.time

*/