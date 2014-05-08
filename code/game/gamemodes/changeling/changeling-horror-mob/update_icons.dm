//Changeling Horror Overlays/////
#define CH_FIRE_LAYER			1
#define CH_TOTAL_LAYERS			1
/////////////////////////////////

/mob/living/carbon/changelinghorror
	var/list/overlays_standing[CH_TOTAL_LAYERS]

/mob/living/carbon/changelinghorror/regenerate_icons()
	..()
	update_inv_hands(0)
	update_fire()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/changelinghorror/update_icons()
	update_hud()
	overlays.Cut()
	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/changelinghorror/update_inv_hands(var/update_icons=1)
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		return
	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand
		var/t_state = l_hand.item_state
		if(!t_state)	 t_state = l_hand.icon_state

	if(update_icons)
		update_icons()

/mob/living/carbon/changelinghorror/update_hud()
	if(client)
		client.screen |= contents

/mob/living/carbon/changelinghorror/update_fire()
	overlays -= overlays_standing[CH_FIRE_LAYER]
	if(on_fire)
		overlays_standing[CH_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"= -CH_FIRE_LAYER)
		overlays += overlays_standing[CH_FIRE_LAYER]
		return
	else
		overlays_standing[CH_FIRE_LAYER] = null

#undef CH_FIRE_LAYER
#undef CH_TOTAL_LAYERS
