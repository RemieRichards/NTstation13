
/mob/living/carbon/changelinghorror/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED
	if (notransform)	return
	..()

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	if (stat != DEAD)

		handle_changeling()

	blinded = null

	if(environment)
		handle_environment(environment)

	handle_fire()

	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()

	for(var/obj/item/weapon/grab/G in src)
		G.process()


/mob/living/carbon/changelinghorror/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if(!on_fire)
		if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
			var/transfer_coefficient = 1

			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat != 2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			pressure_alert = -1
		else
			pressure_alert = -1
	return

/mob/living/carbon/changelinghorror/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return
	var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0*discomfort)

	else
		adjustFireLoss(5.0*discomfort)


/mob/living/carbon/changelinghorror/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)
		blinded = 1
		silent = 0
	else
		if(health < 0 || health == 0)
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1
		else
			stat = CONSCIOUS
			return 1

		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)

	return 1


/mob/living/carbon/changelinghorror/proc/handle_regular_hud_updates()

	if (stat == 2)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING
		if(see_override)
			see_invisible = see_override

	if (healths)
		if (stat != 2)
			switch(health)
				if(200 to INFINITY)
					healths.icon_state = "health0"
				if(160 to 200)
					healths.icon_state = "health1"
				if(120 to 160)
					healths.icon_state = "health2"
				if(80 to 120)
					healths.icon_state = "health3"
				if(40 to 80)
					healths.icon_state = "health4"
				if(0 to 40)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 2 : 0]"

	if(bodytemp)
		switch(bodytemperature)
			if(345 to INFINITY)
				bodytemp.icon_state = "temp4"
			if(335 to 345)
				bodytemp.icon_state = "temp3"
			if(327 to 335)
				bodytemp.icon_state = "temp2"
			if(316 to 327)
				bodytemp.icon_state = "temp1"
			if(300 to 316)
				bodytemp.icon_state = "temp0"
			if(295 to 300)
				bodytemp.icon_state = "temp-1"
			if(280 to 295)
				bodytemp.icon_state = "temp-2"
			if(260 to 280)
				bodytemp.icon_state = "temp-3"
			else
				bodytemp.icon_state = "temp-4"

	client.screen.Remove(global_hud.blurry,global_hud.druggy,global_hud.vimpaired)

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/changelinghorror/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()
		hud_used.lingchemdisplay.invisibility = 0
		hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[src.mind.changeling.chem_charges]</font></div>"


/mob/living/carbon/changelinghorror/handle_fire()
	if(..())
		return
	adjustFireLoss(20) //changeling horrors do NOT like fire
	return


