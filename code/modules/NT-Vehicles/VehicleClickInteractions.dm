
/*
Contains:
How the Vehicle interacts with the world via clicks
How mobs interact with the Vehicle via clicks
*/

/obj/vehicle/proc/select_active(var/mob/user)
	if(!user)
		return


	if(equipment && !equipment.len || !equipment)
		user << "<span class='notice'>No equipment attached!</span>"
		return

	var/obj/item/vehicle_part/equipment/SELECTED = input("Select Active Equipment:","Active Equipment") as null|anything in equipment

	if(SELECTED)
		ACTIVE = SELECTED
		user << "<span class='notice'>[SELECTED.name] is now the Active Equipment.</span>"
		return


/obj/vehicle/proc/click_action(atom/target, mob/user)
	if(!src.Pilot || src.Pilot != user) return
	if(user.stat) return

	if(src == target) return
	var/dir_to_target = get_dir(src,target)
	if(dir_to_target && !(dir_to_target & src.dir))
		return

	if(!target.Adjacent(src))
		if(ACTIVE && ACTIVE.is_ranged)
			ACTIVE.action(target)
	else if(ACTIVE && ACTIVE.is_melee)
		ACTIVE.action(target)

	return


// CARGO HOLD \\

/obj/vehicle/MouseDrop_T(atom/dropping,mob/user)
	if(dropping in user.contents)
		user << "<span class='notice'>Unequip the [dropping.name] before attempting to deposit it.</span>"
		return


	if(istype(dropping, /obj/item))
		var/obj/item/I = dropping

		if(MaxCargoHoldWeight)
			var/total_cargo_weight = 0
			for(var/obj/item/Cargo_I in cargo)
				total_cargo_weight += Cargo_I.w_class

			total_cargo_weight += I.w_class
			if(total_cargo_weight > MaxCargoHoldWeight)
				user << "<span class='notice'>You cannot fit [I.name] into [src.name]'s cargo hold.</span>"
				return
			else
				user.drop_item()
				cargo += I
				I.loc = src
				user << "<span class='notice'>You add [I.name] to [src.name]'s cargo hold.</span>"
				return
	return


/obj/vehicle/CtrlClick(var/mob/user)
	if(!user)
		return

	if(cargo.len)
		var/obj/item/Selected = input("Remove which item from cargo?","Cargo hold") as null|anything in cargo
		if(Selected)
			cargo -= Selected
			Selected.loc = get_turf(user)
			user << "<span class='notice'>You remove [Selected.name] from [src.name]'s cargo hold.</span>"
	else
		user << "<span class='notice'>No cargo to remove.</span>"
	return

// END CARGO HOLD \\

/obj/vehicle/ShiftClick(var/mob/user)
	if(!user)
		return

	if(!in_construction)
		user << "<span class='notice'>Vehicle not in Maintenance mode.</span>"
		return

	Interact(user)
	return


obj/vehicle/Topic(href,href_list)
	if(usr.lying || usr.stat || !in_range(src, usr))
		return 1
	if(!(ishuman(usr)))
		usr << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return 1

	var/mob/living/carbon/human/user = usr
	var/obj/item/held_item = user.get_active_hand()

	if(href_list["Name"])
		src.name = input("Vehicle name:", "Vehicle name") as text

	if(href_list["Core"])
		if(!core)
			if(istype(held_item, /obj/item/vehicle_part/core))
				var/obj/item/vehicle_part/core/C = held_item
				core = C
				user.drop_item()
				C.loc = src
				C.OWNER = src
				user << "<span class='notice'>The [core.name] is in position.</span>"
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
				update_core()

		if(core)
			if(istype(held_item, /obj/item/weapon/screwdriver))
				core.secured = !core.secured
				user << "<span class='notice'>The [core.name] is [core.secured ? "secured" : "unsecured"].</span>"
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

			if(istype(held_item, /obj/item/weapon/crowbar))
				if(!core.secured)
					user << "<span class='notice'>The [core.name] is removed.</span>"
					playsound(src.loc, 'sound/effects/bamf.ogg',50,1)
					core.loc = get_turf(user)
					core.OWNER = null
					core = null
					update_core()
				else
					user << "<span class='notice'>The [core.name] cannot be removed, as it is secured.</span>"

	if(href_list["Movement"])
		if(!movement)
			if(istype(held_item, /obj/item/vehicle_part/movement))
				var/obj/item/vehicle_part/movement/M = held_item
				movement = M
				user.drop_item()
				M.loc = src
				M.OWNER = src
				user << "<span class='notice'>The [movement.name] is in position.</span>"
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
				update_movement()

		if(movement)
			if(istype(held_item, /obj/item/weapon/screwdriver))
				movement.secured = !movement.secured
				user << "<span class='notice'>The [movement.name] is [movement.secured ? "secured" : "unsecured"].</span>"
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

			if(istype(held_item, /obj/item/weapon/crowbar))
				if(!movement.secured)
					user << "<span class='notice'>The [movement.name] is removed.</span>"
					playsound(src.loc, 'sound/effects/bamf.ogg',50,1)
					movement.loc = get_turf(user)
					movement.OWNER = null
					movement = null
					update_movement()
				else
					user << "<span class='notice'>The [movement.name] cannot be removed, as it is secured.</span>"

	if(href_list["Armour"])
		if(!armour)
			if(istype(held_item, /obj/item/vehicle_part/armour))
				var/obj/item/vehicle_part/armour/A = held_item
				armour = A
				user.drop_item()
				A.loc = src
				A.OWNER = src
				user << "<span class='notice'>The [armour.name] is in position.</span>"
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
				update_armour()

		if(armour)
			if(istype(held_item, /obj/item/weapon/screwdriver))
				armour.secured = !armour.secured
				user << "<span class='notice'>The [armour.name] is [armour.secured ? "secured" : "unsecured"].</span>"
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

			if(istype(held_item, /obj/item/weapon/crowbar))
				if(!armour.secured)
					user << "<span class='notice'>The [armour.name] is removed.</span>"
					playsound(src.loc, 'sound/effects/bamf.ogg',50,1)
					armour.loc = get_turf(user)
					armour.OWNER = null
					armour = null
					update_armour()
				else
					user << "<span class='notice'>The [armour.name] cannot be removed, as it is secured.</span>"

	if(href_list["Power"])
		if(!pwr)
			if(istype(held_item, /obj/item/vehicle_part/power_generator))
				var/obj/item/vehicle_part/power_generator/P = held_item
				pwr = P
				user.drop_item()
				P.loc = src
				P.OWNER = src
				user << "<span class='notice'>The [pwr.name] is in position.</span>"
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		if(pwr)
			if(istype(held_item, /obj/item/weapon/screwdriver))
				pwr.secured = !pwr.secured
				user << "<span class='notice'>The [pwr.name] is [pwr.secured ? "secured" : "unsecured"].</span>"
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

			if(istype(held_item, /obj/item/weapon/crowbar))
				if(!pwr.secured)
					user << "<span class='notice'>The [pwr.name] is removed.</span>"
					playsound(src.loc, 'sound/effects/bamf.ogg',50,1)
					pwr.loc = get_turf(user)
					pwr.OWNER = null
					pwr = null
				else
					user << "<span class='notice'>The [pwr.name] cannot be removed, as it is secured.</span>"

	if(href_list["Equip"])

		if(istype(held_item, /obj/item/weapon/crowbar) && equipment.len)
			var/obj/item/vehicle_part/equipment/removed = input("Remove which Equipment?","Equipment") as null|anything in equipment
			if(removed)
				equipment -= removed
				removed.OWNER = null
				removed.loc = get_turf(user)
				user << "<span class='notice'>You remove the [removed.name].</span>"
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		if(istype(held_item, /obj/item/vehicle_part/equipment))
			var/obj/item/vehicle_part/equipment/E = held_item
			equipment += E
			user.drop_item()
			E.loc = src
			E.OWNER = src
			user << "<span class='notice'>You attatch the [E.name].</span>"
			playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

	add_fingerprint(usr)
	Interact(usr)
	return 0

/obj/vehicle/proc/Interact(mob/user)
	var/t1 = text("Name: <A href='?\ref[];Name=1'>[(name ? "[name]" : "Unnamed")]</a><br>",src)

	t1 += text("\n Core Component: <A href='?\ref[];Core=1'>[(core ? "[core.name]" : "Uninstalled")]</a><br>",src)

	if(core)
		t1 += text("Core Component Status: [(core.secured ? "Secured" : "Unsecured")]<br>")

	t1 += text("\n Power Generator: <A href='?\ref[];Power=1'>[(pwr ? "[pwr.name]" : "Uninstalled")]</a><br>",src)

	if(pwr)
		t1 += text("Power Generator Status: [(pwr.secured ? "Secured" : "Unsecured")]<br>")

	t1 += text("\n Movement Component: <A href='?\ref[];Movement=1'>[(movement ? "[movement.name]" : "Uninstalled")]</a><br>",src)

	if(movement)
		t1 += text("Movement Component Status: [(movement.secured ? "Secured" : "Unsecured")]<br>")

	t1 += text("\n Armour Plating: <A href='?\ref[];Armour=1'>[(armour ? "[armour.name]" : "Uninstalled")]</a><br>",src)

	if(armour)
		t1 += text("Armour Plating Status: [(armour.secured ? "Secured" : "Unsecured")]<br>")

	t1 += text("<A href='?\ref[];Equip=1'>[(equipment.len ? "Equipment" : "No installed Equipment")]</a><br>",src)

	var/datum/browser/popup = new(user, "buildvehicle","\proper [src.name] Components", 400,300)
	popup.set_content(t1)
	popup.open()
