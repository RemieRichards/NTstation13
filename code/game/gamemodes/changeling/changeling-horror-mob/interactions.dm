
/*
	If it interacted with a Changeling horror, Here's why!
	Feel free to undermine me and move things to their *Correct* places
	- RR
*/


/mob/living/carbon/human/attack_horror(mob/user as mob)
	if(!user || !user.mind || !user.mind.changeling|| !ishorror(user))
		return

	if(user.stat)
		return

	switch(user.a_intent)
		if("help")
			user.visible_message("<span class='notice'>[user] caresses [src] with one of it's many apendages.")

		if("harm")
			var/mob/living/carbon/changelinghorror/CH = user
			var/datum/dna/attacker_dna = CH.obtain_valid_dna()
			var/attacker = attacker_dna.real_name
			var/attack_verb = pick("punches","claws at","swipes at","slices","cuts")
			var/attacking_body_part = pick("right arm","left arm")
			var/dam_zone = pick("chest","l_hand", "r_hand", "l_lef", "r_leg","head")
			var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
			var/DAMAGE = CH.Default_Damage*(CH.mind.changeling.absorbed_dna.len/2)
			apply_damage(DAMAGE, BRUTE, affecting, run_armor_check(affecting, "melee"))
			visible_message("<span class='danger'>[CH] reaches out, [attacker]'s [attacking_body_part] [attack_verb] [src]'s [parse_zone(affecting.name)]!</span>","<span class='danger'>[CH] reaches out, [attacker]'s [attacking_body_part] [attack_verb] your [parse_zone(affecting.name)]!</span>")

		if ("grab")
			if (user == src || anchored)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src )

			user.put_in_active_hand(G)

			G.synch()

			LAssailant = user

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[user] has grabbed [name] passively!</span>")

		if ("disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			if(prob(95))
				Weaken(15)
				visible_message("<span class='danger'>[user] has knocked downn [name]!</span>")
			else
				if(drop_item())
					visible_message("<span class='danger'>[user] has disarmed [name]!</span>")
			adjustBruteLoss(damage)
			updatehealth()
	return

/mob/living/carbon/changelinghorror/proc/obtain_valid_dna() //Loop to ensure a non null DNA is chosen
	var/datum/dna/chosen_dna = pick(mind.changeling.absorbed_dna)

	if(!isnull(chosen_dna))
		return chosen_dna

	return obtain_valid_dna()

/obj/machinery/door/airlock/attack_horror(mob/user as mob)
	var/delay = 30

	if(!user || user.stat)
		return

	if(!requiresID() || allowed(user))
		return

	if(arePowerSystemsOn() && !(stat & NOPOWER))
		user << "<span class='notice'>The airlock's motors resist our efforts to force it, we will try harder...</span>"
		delay = 60

	else if(locked)
		user << "<span class='notice'>The airlock's bolts prevent it from being forced.</span>"
		return


	if(!do_after(user,delay))
		return

	user.visible_message("<span class='warning'>[user] forces the door open!</span>", "<span class='warning'>We force the door to open!</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
	open(1)

/obj/item/attack_horror(mob/user as mob)
	attack_hand(user)

/obj/attack_horror(mob/user as mob)
	attack_alien(user)

/turf/simulated/wall/attack_horror(mob/user as mob)

	if(prob(hardness))
		user.visible_message("<span class='warning'>[user] smashes through the wall!</span>","<span class='warning'>You smash through the wall!</span>","<span class='warning'>You hear the sound of crunching metal.</span>")
		dismantle_wall(1)
		return
	else
		user.visible_message("<span class='warning'>[user]'s claw smashes against the wall, but the wall remains!</span>","<span class='warning'>Your claw smashes against the wall, but the wall remains!</span>","<span class='warning'>You hear a metallic clang.</span>")
		return
