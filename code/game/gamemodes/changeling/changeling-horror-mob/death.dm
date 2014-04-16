
/mob/living/carbon/changelinghorror/death(gibbed)
	if(stat == DEAD)
		return
	if(healths)
		healths.icon_state = "health5"
	stat = DEAD
	dizziness = 0
	jitteriness = 0

	if(!gibbed)
		update_canmove()
		if(client)
			if(blind)
				blind.layer = 0


	var/mob/living/simple_animal/head_spider/HS = new (loc)
	HS.name = "[dna.real_name]-Head Spider"
	HS.desc = "it looks like the head of [dna.real_name]!"
	if(mind && mind.changeling)
		//HS.key = key //Minds handle Keys
		mind.transfer_to(HS)

	return ..(gibbed)
