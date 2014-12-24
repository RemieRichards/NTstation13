/*
Contents:
	-digspot object
	-digspot interactions
*/

var/global/list/xenoarch_digspots = list() //List of valid digspots

/obj/structure/digspot //Not lockers or closets because they'd have welding and other weirdness
	icon = 'icons/obj/xenoarchaeology.dmi'
	name = "loose dirt"
	icon_state = "dig_closed"
	desc = "it looks light the ground is uneven..."
	var/state = 0

/obj/structure/digspot/New()
	..()
	if(prob(40))
		var/obj/item/xenoarch/X = pick(typesof(/obj/item/xenoarch) - /obj/item/xenoarch)
		contents += new X (src)

/obj/structure/digspot/proc/on_open()
	for(var/atom/movable/M in contents)
		M.loc = src.loc
		contents -= M
	icon_state = "dig_open"

/obj/structure/digspot/proc/on_close(var/mob/user)
	for(var/atom/movable/M in src.loc)
		M.loc = src
		contents += M
	icon_state = "dig_closed"

/obj/structure/digspot/attackby(var/obj/item/I,var/mob/user)
	if(istype(I, /obj/item/weapon/shovel))
		state = !state
		user << "<span class='notice'>You [state ? "dig up" : "settle"] the loose dirt"
		switch(state)
			if(0)
				on_close()
			if(1)
				on_open()

	else
		if(state)
			user.drop_item()
			I.loc = src.loc
			user << "<span class='notice'>You place the [I] in the hole</span>"

/obj/structure/digspot/attack_hand(var/mob/user)
	if(!state)
		user << "<span class='notice'>You feel around the dirt</span>"
		if(do_after(user,20))
			if(contents.len)
				user << "<span class='notice'>You can tell there is something buried here</span>"
			else
				user << "<span class='notice'>There doesn't seem to be anything buried here</span>"
		else
			user << "<span class='notice'>You stop examining the dirt</span>"


/obj/machinery/computer/shuttle/xenoarch
	name = "Xenoarch shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	id = "xenoarch"
	req_access = list(access_brig) //debug

