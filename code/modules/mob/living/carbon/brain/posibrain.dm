/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "biotech=3;programming=2"

	construction_cost = list("metal" = 700, "glass" = 350)
	construction_time = 75
	var/searching = 0
	var/askDelay = 10 * 60 * 1
	brainmob = null
	req_access = list(access_robotics)
	locked = 0
	mecha = null//This does not appear to be used outside of reference in mecha.dm.


/obj/item/device/mmi/posibrain/attack_self(mob/user as mob)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		user << "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>"
		searching = 1
		handle_posibrain_icon()
		request_player()
		spawn(600)
			reset_search()

/obj/item/device/mmi/posibrain/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "pAI"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_PAI)
				question(O.client)

/obj/item/device/mmi/posibrain/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "Someone is requesting a personality for a positronic brain. Would you like to play as one?", "Positronic brain request", "Yes", "No", "Never for this round")
		if(!C || brainmob.key || 0 == searching)
			return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
		if(response == "Yes")
			transfer_personality(C.mob)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_PAI


/obj/item/device/mmi/posibrain/transfer_identity(var/mob/living/carbon/H)
	name = "positronic brain ([H])"
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.stat = 0
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob << "<span class='notice'>Hello World!</span>"
	handle_posibrain_icon()
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(var/mob/candidate)

	searching = 0
	brainmob.mind = candidate.mind
	brainmob.ckey = candidate.ckey
	name = "positronic brain ([brainmob.name])"

	brainmob << "<b>You are a positronic brain, brought into existence on [station_name()].</b>"
	brainmob << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
	brainmob << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	brainmob << "<b>Use say :b to speak to other artificial intelligences.</b>"
	brainmob.mind.assigned_role = "Positronic Brain"

	var/turf/T = get_turf()
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>The positronic brain chimes quietly.</span>")
	handle_posibrain_icon()

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.

	if(brainmob && brainmob.key) return

	searching = 0
	handle_posibrain_icon()

	var/turf/T = get_turf()
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

/obj/item/device/mmi/posibrain/examine()

	set src in oview()

	if(!usr || !src)	return
	if( (usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	msg += "<span class='warning'>"

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "<span class='info'>*---------*</span>"
	usr << msg
	return

/obj/item/device/mmi/posibrain/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/posibrain/New()

	brainmob = new(src)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	brainmob.robot_talk_understand = 1
	brainmob.stat = 0
	brainmob.silent = 0
	dead_mob_list -= brainmob

	..()


/obj/item/device/mmi/posibrain/attackby(var/obj/item/O as obj, var/mob/user as mob)
	return


/obj/item/device/mmi/posibrain/proc/handle_posibrain_icon()
	if(searching)
		icon_state = "posibrain-searching"
		return
	if(brainmob)
		icon_state = "posibrain-occupied"
	else
		icon_state = "posibrain"