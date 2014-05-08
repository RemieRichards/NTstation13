
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

	return ..(gibbed)
