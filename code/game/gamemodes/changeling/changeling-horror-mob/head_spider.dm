
/mob/living/simple_animal/head_spider
	name = "Unknown-Head Spider"
	desc = "You can't quite make out who it looks like..."

	icon_state = "head_spider"
	icon_living = "head_spider"
	icon_dead = "head_spider_dead"

	speak_chance = 0
	turns_per_move = 5
	response_help = "thinks better of touching"
	response_disarm = "cautiously shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 40
	health = 40

	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "leaps at"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "changeling"

/mob/living/simple_animal/head_spider/proc/attempt_takeover(mob/living/carbon/Victim)
	if(ischangeling(Victim) || ishorror(Victim))
		src << "<span class='warning'>We will not Assimilate our own kind!</span>"
		return

	if(ishuman(Victim)) //Only humans have a head slot
		var/mob/living/carbon/human/HV = Victim
		if(HV.head)
			if(HV.head.flags_inv & HIDEFACE) //helmet is in the way - maybe theres a better way than this?
				src << "<span class='warning'>Their [HV.head.name] prevents you from attatching!</span>"
				return

	if(Victim.wear_mask)
		if(Victim.wear_mask.flags_inv & MASKCOVERSMOUTH)
			src << "<span class='warning'>Their [Victim.wear_mask.name] prevents you from Attatching!</span>"
			return

	//"Revive" previous changeling inside of Victim

	visible_message("<span class='danger'>The [name] is trying to climb onto [Victim]!</span>","<span class='danger'>We are climbing [Victim], we must hold still!</span>")

	if(!do_after(src,20))
		visible_message("<span class='danger'>The [name] falls off of [Victim]!</span>","<span class='danger'>We have fallen!</span>")
		return


	if(mind && mind.changeling)
		Victim.visible_message("<span class='danger'>The [name] climbs onto [Victim]'s head!</span>","<span class='danger'>The [name] climbs onto your head!</span>")
		Victim.ghostize(0)
		mind.transfer_to(Victim)
		Victim << "<span class='danger'>Assimilation Complete!</span>" //Victim = ling here
		qdel(src)

	return


/mob/living/simple_animal/head_spider/Die()
	if(ticker && ticker.mode)
		ticker.mode.check_win() //our mind is (should be) a Ling

	..()
