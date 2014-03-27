
// MOVEMENT CRAP \\

/*
if this looks anything like Mech movement code,
that's because it is *Modified* Mech movement code,
Mechs will be ported to /vehicle!
*/

/obj/vehicle/relaymove(mob/user,direction)
	if(user != Pilot)
		user.forceMove(get_turf(src))
		user << "You climb our from /the [name]."
		return 0

	return vehicle_move(direction)

/obj/vehicle/proc/vehicle_move(direction)
	time_per_step = initial(time_per_step) //To prevent slowdown stacking.
	if(!can_move)
		return 0

	if(anchored)
		return 0

	var/move_result = 0
	switch(movement_style)
		if("Normal")
			move_result = VehicleStep(direction)
		if("TurnThenMove")
			move_result = VehicleTurn(direction)
		if("Strafe")
			move_result = VehicleStrafe(direction)

	if(move_result)
		can_move = 0
		power_cell.use(power_loss_per_step)
		if(do_after(time_per_step))
			can_move = 1
		return 1

	return 0

/obj/vehicle/proc/VehicleTurn(direction)
	if(src.dir != direction)
		dir = direction
		return 1
	else
		VehicleStep(direction)

/obj/vehicle/proc/VehicleStep(direction)
	var/result = step(src,direction)
	if(slowed_indoors)
		if(!istype(get_step(src,direction), /turf/space))
			time_per_step += 8
		else
			time_per_step = initial(time_per_step)
	return result

/obj/vehicle/proc/VehicleStrafe(direction)
	var/old_dir = dir
	if(VehicleStep(direction))
		dir = old_dir
		return 1
	return 0
