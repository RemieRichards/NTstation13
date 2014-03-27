

/obj/vehicle/attack_hand(mob/user as mob)
	if(!user)
		return

	if(max_crew_members == crew_members.len)
		user << "<span class='notice'>This vehicle is at max crew capacity.</span>"
		return

	if(handle_enter(user))
		user << "<span class='notice'>You enter the vehicle.</span>"

	regenerate_vehicle_icons()
	return


/obj/item/vehicle_part/proc/take_damage(var/damage)
	PartHealth -= damage*damage_coefficient
	if(PartHealth < PartMaxHealth/2 || PartHealth < PartMaxHealth/4)
		OWNER.regenerate_vehicle_icons()



/obj/vehicle/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/wrench))
		if(anchored)
			if(check_required_parts())
				in_construction = !in_construction
				regenerate_vehicle_icons()
				user << "<span class='notice'>Vehicle is now [in_construction ? "modifiable" : "un-modifiable"].</span>"
			else
				user << "<span class='notice'>You cannot complete construction/maintenance while the vehicle is missing parts.</span>"
			return
		else
			user << "<span class='notice'>You can't modify the vehicle when it isn't docked!</span>"
			return

	if(istype(I, /obj/item/weapon))
		var/obj/item/weapon/W = I
		var/obj/item/vehicle_part/damaged_part = handle_random_part_damage(W)
		if(damaged_part)
			user.visible_message("<span class='danger'>The [damaged_part.name] has been hit by [user]!</span>")
		return

	return


/obj/vehicle/proc/check_required_parts()
	var/success = 1
	if(!core)
		success--
	if(!movement)
		success--
	if(!pwr)
		success--
	if(!armour)
		success--
	return success


/obj/vehicle/proc/handle_random_part_damage(var/obj/item/weapon/W, var/damage)
	var/pick_part
	var/damaged_part

	if(!in_construction)
		pick_part = pick(1,2,3,4,5)

		if(W)
			damage = W.force

		switch(pick_part)
			if(1)
				if(core)
					core.take_damage(damage)
					damaged_part = core
			if(2)
				if(pwr)
					pwr.take_damage(damage)
					damaged_part = pwr
			if(3)
				if(armour)
					armour.take_damage(damage)
					damaged_part = armour
			if(4)
				if(movement)
					movement.take_damage(damage)
					damaged_part = movement
			if(5)
				if(ACTIVE)
					ACTIVE.take_damage(damage)
					damaged_part = ACTIVE


	if(damaged_part)
		return damaged_part

	handle_random_part_damage(,damage)


/obj/vehicle/proc/check_status()
	if(!Pilot)
		return

	if(core)
		Pilot << "<span class='notice'>Core integrity: [core.PartHealth]/[core.PartMaxHealth].</span>"
	if(armour)
		Pilot << "<span class='notice'>Armour integrity: [armour.PartHealth]/[armour.PartMaxHealth].</span>"
	if(pwr)
		Pilot << "<span class='notice'>Power Generator integrity: [pwr.PartHealth]/[pwr.PartMaxHealth].</span>"
	if(movement)
		Pilot << "<span class='notice'>Movement Gear integrity: [movement.PartHealth]/[movement.PartMaxHealth].</span>"
	if(ACTIVE)
		Pilot << "<span class='notice'>Active Equipment integrity: [ACTIVE.PartHealth]/[ACTIVE.PartMaxHealth].</span>"

	Pilot << "<span class='notice'>Vehicle intergity: [VehicleHealth]/[VehicleMaxHealth].</span>"


/obj/vehicle/bullet_act(var/obj/item/projectile/P)
	if(P)
		if(armour)
			handle_random_part_damage(,handle_random_part_damage(armour.attempt_block(,P.damage)))
			visible_message("<span class='danger'>[src] has been hit by a projectile!</span>")
			return
		else
			handle_random_part_damage(,P.damage)
			visible_message("<span class='danger'>[src] has been hit by a projectile!</span>")
			return


/obj/vehicle/blob_act()
	if(armour)
		if(armour.secured)
			handle_random_part_damage(armour.attempt_block(,50))
			visible_message("<span class='danger'>[src] is hit by the blob!</span>")
			return

	handle_random_part_damage(,50)
	visible_message("<span class='danger'>[src] is hit by the blob!</span>")

/obj/vehicle/emp_act(time_emp)
	if(!EMP)
		EMP = 1

	time_emp++

	if(time_emp == 100) //if we've looped enough times
		EMP = 0 //Reset the EMP
		time_emp = 0 //and the Timer

	if(time_emp) //if theres a time

		sleep(1) //Lol at looping

		emp_act(time_emp) //Loop round


/obj/item/vehicle_part/armour/proc/attempt_block(var/obj/item/I, var/damage)
	var/final_damage = 0

	if(I)
		if(istype(I, /obj/item/projectile))
			var/obj/item/projectile/P = I
			final_damage = P.damage - armour_value
		else
			final_damage = I.force - armour_value
	else
		if(damage)
			final_damage = damage - armour_value
		else
			final_damage = 1

	if(final_damage)
		return final_damage

/obj/vehicle/proc/handle_overall_health() //FINISH THIS
	if(VehicleHealth > VehicleMaxHealth)
		VehicleHealth = VehicleMaxHealth
