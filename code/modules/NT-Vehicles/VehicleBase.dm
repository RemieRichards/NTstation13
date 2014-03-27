
//NTStation Vehicles, RobRichards + StarToad

/*
TODO:
- Construction - Done
- Deconstruction - Done
- Movement - Done
- Vehicle item interactions - Done
- Power Usage - Done
- Cargo (Items) - Done
- Cargo (Items in hand working)
- Movement modes (Strafe, Turning, Turning and Moving) - Done
- Handle Pilot Breathing
- Test Combat
- More sounds - Done
- Split files into more files - Done
- DATUM CONSTRUCTIONS - SEE construction_datum.dm
- Standardise Variable names - Done
*/

/*
HARD TODO:
- Port Mechs to /vehicle
*/


/*
Contents:
- New()
- Del()
- Definitions (Prebuilt/Ship types)
- Misc Procs
*/


/obj/vehicle
	icon = 'icons/obj/NTvehicles/vehicle_pieces_32.dmi'
	name = "Vehicle"
	density = 1
	anchored = 1
	opacity = 1
	unacidable = 1
	layer = MOB_LAYER
	var/power_loss_per_step = 18
	var/vehicle_health = 200
	var/vehicle_max_health = 200
	var/vehicle_scale = 1
	var/effects_icon = 'icons/obj/NTvehicles/vehicle_effects_32.dmi'
	var/can_move = 1 //Can the vehicle move?
	var/time_per_step = 0 //Think of this as Reverse velocity, the lower this is, the faster you go
	var/movement_style = "Normal" //Normal/Strafe/TurnThenMove - How the vehicle moves
	var/slowed_indoors = 0
	var/max_crew_members = 1
	var/mob/living/carbon/Pilot
	var/list/crew_members = list()
	var/vehicle_id = 0
	var/in_construction = 1
	var/obj/item/weapon/stock_parts/cell/power_cell //The cell that power is used from, and that the Power generator gives power to.
	var/obj/item/vehicle_part/core/core
	var/obj/item/vehicle_part/power_generator/pwr
	var/obj/item/vehicle_part/movement/movement
	var/obj/item/vehicle_part/armour/armour
	var/obj/item/vehicle_part/equipment/active_equip //Active equipment
	var/datum/gas_mixture/cockpit_air
	var/list/required_components = list(/obj/item/vehicle_part/core, /obj/item/vehicle_part/movement, /obj/item/vehicle_part/power_generator, /obj/item/vehicle_part/armour)
	var/list/equipment = list() //Attached weapons/tools
	var/max_equipment = 3 //Max weapons/tools
	var/list/cargo = list()//Cargo bay
	var/max_cargo_weight = 5
	var/on_fire = 0
	var/emp = 0


/obj/vehicle/process()
	if(pwr && power_cell)
		power_cell.give(pwr.power_gain)
		sleep(pwr.power_gain_wait)

	handle_overall_health()


/obj/vehicle/proc/setup_internal_atmos() //Unfinished, this is one proc out of all the ones Mechs use.
	cockpit_air = new
	cockpit_air.temperature = T20C
	cockpit_air.volume = 200
	cockpit_air.oxygen = O2STANDARD*cockpit_air.volume/(R_IDEAL_GAS_EQUATION*cockpit_air.temperature)
	cockpit_air.nitrogen = N2STANDARD*cockpit_air.volume/(R_IDEAL_GAS_EQUATION*cockpit_air.temperature)
	return cockpit_air

/obj/vehicle/proc/do_after(delay)
	sleep(delay)
	if(src)
		return 1
	return 0

/obj/vehicle/examine()
	set src in view()
	..()
	if(core)
		usr << "<span class='notice'>[core.name] is [core.secured ? "secured":"not secured"].</span>"
	if(pwr)
		usr << "<span class='notice'>[pwr.name] is [pwr.secured ? "secured":"not secured"].</span>"
	if(movement)
		usr << "<span class='notice'>[movement.name] is [movement.secured ? "secured":"not secured"].</span>"
	if(armour)
		usr << "<span class='notice'>[armour.name] is [armour.secured ? "secured":"not secured"].</span>"
	if(active_equip)
		usr << "<span class='notice'>Active equipment is [active_equip.name].</span>"
	if(in_construction)
		usr << "<span class='notice'>Vehicle is under construction/maintenance.</span>"
	if(power_cell)
		usr << "Charge:[power_cell.charge]"


/obj/vehicle/proc/handle_enter(var/mob/user)
	if(in_construction)
		user << "<span class='notice'>This vehicle is under construction/maintenance.</span>"
		return 0

	if(Pilot)
		if(Pilot != user)
			user << "<span class='notice'>This vehicle already has a pilot.</span>"
			return 0

	user << "<span class='notice'>Climbing in...</span>"
	if(do_after(40))
		if(user)
			if(user.Adjacent(src))
				user.loc = src
				user << "<span class='notice'>You are now piloting.</span>"
				Pilot = user
				reset_active_equip()
				return 1
			else
				user << "<span class='notice'>Too far away to enter vehicle.</span>"

	return 0

/obj/vehicle/verb/handle_exit(var/mob/user)
	if(!Pilot || Pilot != user)
		return

	Pilot << "<span class='notice'>Climbing out...</span>"
	if(do_after(40))
		if(Pilot)
			Pilot.loc = get_turf(src)
			Pilot << "<span class='notice'>You exit the vehicle.</span>"
			Pilot = null
			reset_active_equip()

	return

/obj/vehicle/proc/reset_active_equip()
	if(active_equip)
		active_equip = null


/obj/vehicle/New()
	..()
	power_cell = new /obj/item/weapon/stock_parts/cell
	power_cell.charge = 15000
	power_cell.maxcharge = 15000

	vehicle_id = rand(1,999)
	name = "[initial(name)] [vehicle_id]"
	icon_state = "[initial(name)]_frame"
	handle_scale()
	setup_internal_atmos()

	processing_objects += src

/obj/vehicle/Del()
	if(Pilot)
		Pilot.loc = get_turf(src)
		Pilot = null
	var/vehicle_loc = get_turf(src)
	if(core)
		if(prob(50))
			core.loc = vehicle_loc
	if(pwr)
		if(prob(50))
			pwr.loc = vehicle_loc
	if(armour)
		if(prob(50))
			armour.loc = vehicle_loc
	if(movement)
		if(prob(50))
			movement.loc = vehicle_loc
	for(var/obj/O in cargo) //Scatter cargo
		if(prob(30))
			O.loc = vehicle_loc
			var/rand_dir = pick(cardinal)
			step(O,rand_dir)

	processing_objects -= src
	..()


// VEHICLE PARTS \\

/obj/item/vehicle_part
	icon = 'icons/obj/NTvehicles/vehicle_parts.dmi'
	icon_state = "debug_part" //DEBUG
	w_class = 5
	var/Broken = 0
	var/obj/vehicle/owner_vehicle
	var/secured = 0
	var/part_health = 100
	var/part_max_health = 100
	var/damage_coefficient = 1 //How much the damage taken is multiplied by
	var/power_loss_per_action = 0 //For parts that need power
	var/has_damaged_vehicle = 0//Whether to deal damage if it's broken, only relevant for the 4 core parts


/obj/item/vehicle_part/core
	name = "Vehicle Core"

/obj/item/vehicle_part/power_generator
	name = "Power generator"
	desc = "Generates far more than 1.21 gigawatts"
	var/power_gain = 20
	var/power_gain_wait = 1

/obj/item/vehicle_part/movement
	name = "Thruster"
	desc = "Thrust forth into the fray" //I don't know this text isn't making it into the main release - RR

/obj/item/vehicle_part/armour
	name = "Armour plating"
	desc = "Protect your vehicle"
	var/armour_value = 5 //How much damage it removes from each attack - RR

/obj/item/vehicle_part/equipment
	name = "Equipment"
	desc = "It's a Weapon, or maybe it's a tool!"
	power_loss_per_action = 20
	var/is_ranged = 0
	var/is_melee = 1

/obj/item/vehicle_part/equipment/proc/action(atom/target)
	return

//debug

/obj/item/vehicle_part/equipment/drill
	name = "DRILL"
	is_melee = 1

/obj/item/vehicle_part/equipment/drill/action(atom/target)
	owner_vehicle.power_cell.use(power_loss_per_action)
	del(target)

/obj/item/vehicle_part/equipment/monkey_spawn
	name = "MONKEYS"
	is_ranged = 1
	is_melee = 0

/obj/item/vehicle_part/equipment/monkey_spawn/action(atom/target)
	owner_vehicle.power_cell.use(power_loss_per_action)
	if(istype(target,/turf))
		new /mob/living/carbon/monkey (target)
		owner_vehicle.Pilot << "SUDDEN MONKEY"

//end debug

/obj/vehicle/usp_talon
	name = "usp"

/obj/vehicle/usp_talon/prebuilt/New() //Build me some shit
	..()
	core = new /obj/item/vehicle_part/core (src)
	pwr = new /obj/item/vehicle_part/power_generator (src)
	movement = new /obj/item/vehicle_part/movement (src)
	armour = new /obj/item/vehicle_part/armour (src)
	core.secured = 1
	pwr.secured = 1
	movement.secured = 1
	armour.secured = 1
	in_construction = 0
	anchored = 0
	regenerate_vehicle_icons()


/obj/vehicle/valid
	name = "valid"
	vehicle_scale = 1

/obj/vehicle/valid/prebuilt/New()
	..()
	core = new /obj/item/vehicle_part/core (src)
	pwr = new /obj/item/vehicle_part/power_generator (src)
	movement = new /obj/item/vehicle_part/movement (src)
	armour = new /obj/item/vehicle_part/armour (src)
	core.secured = 1
	pwr.secured = 1
	movement.secured = 1
	armour.secured = 1
	in_construction = 0
	anchored = 0
	regenerate_vehicle_icons()

/*
/obj/vehicle/construction
	name = "UNFINISHED HAH HA HAHAHAHAH-Frame"
	var/vehicle = "Valid"
	var/datum/construction/Construct


/obj/vehicle/construction/proc/find_construction_path()
	switch(vehicle)
		if("Valid")
			Construct = new /datum/construction/vehicle/valid
		if("Talon")
		if("Debug")


/datum/construction/vehicle/valid_frame
	steps = list(list("key"=/obj/item/vehicle_parts/),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
		const_holder.icon = 'icons/mecha/mech_construction.dmi'
		const_holder.icon_state = "ripley0"
		const_holder.density = 1
		const_holder.overlays.len = 0
		spawn()
			del src
		return


/datum/construction/reversible/vehicle/valid  //NOTE, THE STEPS ARE WRITTEN BACKWARDS FOR SOME REASON - RR
	result = "/obj/vehicle/valid"
	steps = list(




					list("key"=/obj/item/weapon/screwdriver,
							"backkey"=/obj/item/weapon/crowbar,
							"desc"="Flight computer is installed."),

					list("key"=/obj/item/weapon/circuitboard/vehicle/valid/flight_comp,
							"backkey"=/obj/item/weapon/wirecutters,
							"desc"="Flight computer is in position."),

					list("key"=/obj/item/stack/cable_coil,
							"backkey"=/obj/item/weapon/screwdriver,
							"desc"="FUCK UNFINISHED."),

					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
				)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(14)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
				holder.icon_state = "ripley1"
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
					holder.icon_state = "ripley2"
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
					holder.icon_state = "ripley0"
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
					holder.icon_state = "ripley3"
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
					holder.icon_state = "ripley1"
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
					holder.icon_state = "ripley4"
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
					coil.amount = 4
					holder.icon_state = "ripley2"
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
					holder.icon_state = "ripley5"
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
					holder.icon_state = "ripley3"
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
					holder.icon_state = "ripley6"
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
					holder.icon_state = "ripley4"
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
					holder.icon_state = "ripley7"
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
					holder.icon_state = "ripley5"
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
					holder.icon_state = "ripley8"
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
					holder.icon_state = "ripley6"
			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
					holder.icon_state = "ripley9"
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
					holder.icon_state = "ripley7"
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
					holder.icon_state = "ripley10"
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You pry internal armor layer from [holder].")
					var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
					MS.amount = 5
					holder.icon_state = "ripley8"
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
					holder.icon_state = "ripley11"
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
					holder.icon_state = "ripley9"
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
					holder.icon_state = "ripley12"
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
					holder.icon_state = "ripley10"
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
					holder.icon_state = "ripley13"
				else
					user.visible_message("[user] pries external armor layer from [holder].", "You pry external armor layer from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
					holder.icon_state = "ripley11"
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
					holder.icon_state = "ripley12"
		return 1

	spawn_result()
		..()
		feedback_inc("vehicle_valid_created",1)
		return


*/

//DATUM CONSTRUCTIONS

/datum/construction/vehicle/custom_action(step, atom/used_atom, mob/user)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = used_atom
		if (W.remove_fuel(0, user))
			playsound(holder, 'sound/items/Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'sound/items/Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/screwdriver))
		playsound(holder, 'sound/items/Screwdriver.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'sound/items/Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
			playsound(holder, 'sound/items/Deconstruct.ogg', 50, 1)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < 5)
			user << ("There's not enough material in this stack.")
			return 0
		else
			S.use(5)
	return 1

/datum/construction/reversible/vehicle/custom_action(index as num, diff as num, atom/used_atom, mob/user as mob)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = used_atom
		if (W.remove_fuel(0, user))
			playsound(holder, 'sound/items/Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'sound/items/Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/screwdriver))
		playsound(holder, 'sound/items/Screwdriver.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'sound/items/Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
			playsound(holder, 'sound/items/Deconstruct.ogg', 50, 1)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < 5)
			user << ("There's not enough material in this stack.")
			return 0
		else
			S.use(5)
	return 1
