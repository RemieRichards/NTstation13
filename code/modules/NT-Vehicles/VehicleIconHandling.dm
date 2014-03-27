
// OVERLAYS/ICON CODE \\

/*
If you don't know what you're doing, Don't touch it - RR
*/

#define CORE_LAYER 1 //The Core part of the vehicle.
#define MOVEMENT_LAYER 2 //Thrusters/Wheels/Wings Whatever moves the vehicle
#define EQUIPMENT_LAYER 3 //Equipment
#define ARMOUR_LAYER 4 //Armour plates
#define EFFECT_LAYER 5 //Fires, EMP, etc.


#define TOTAL_LAYERS 5

/obj/vehicle/proc/regenerate_vehicle_icons()
	update_core()
	update_movement()
	update_armour()
	update_effects()


/obj/vehicle
	var/list/vehicle_overlays[TOTAL_LAYERS]


/obj/vehicle/proc/apply_overlay(cache_index)
	var/image/I = vehicle_overlays[cache_index]
	if(I)
		overlays += I

/obj/vehicle/proc/remove_overlay(cache_index)
	if(vehicle_overlays[cache_index])
		overlays -= vehicle_overlays[cache_index]
		vehicle_overlays[cache_index] = null


/obj/vehicle/proc/update_core()
	remove_overlay(CORE_LAYER)
	var/list/Core_images = list()

	if(core)
		Core_images += image("icon"=icon,"icon_state"="[initial(name)]_core","layer"=-CORE_LAYER)

	if(Core_images.len)
		vehicle_overlays[CORE_LAYER] = Core_images

	apply_overlay(CORE_LAYER)
	update_cockpit()


/obj/vehicle/proc/update_movement()
	remove_overlay(MOVEMENT_LAYER)
	var/list/Movement_images = list()

	if(movement)
		if(in_construction || anchored)
			Movement_images += image("icon"=icon,"icon_state"="[initial(name)]_movement_off","layer"=-MOVEMENT_LAYER)
		else
			Movement_images += image("icon"=icon,"icon_state"="[initial(name)]_movement_on","layer"=-MOVEMENT_LAYER)

	if(Movement_images.len)
		vehicle_overlays[MOVEMENT_LAYER] = Movement_images

	apply_overlay(MOVEMENT_LAYER)


/obj/vehicle/proc/update_armour()
	remove_overlay(ARMOUR_LAYER)
	var/list/Armour_images = list()

	if(armour)
		Armour_images += image("icon"=icon,"icon_state"="[initial(name)]_armour_plates","layer"=-ARMOUR_LAYER)

	if(Armour_images.len)
		vehicle_overlays[ARMOUR_LAYER] = Armour_images

	apply_overlay(ARMOUR_LAYER)


/obj/vehicle/proc/update_effects()
	remove_overlay(EFFECT_LAYER)
	var/list/Effect_images = list()

	if(on_fire)
		Effect_images += image("icon"=effects_icon,"icon_state"="[initial(name)]_fire","layer"=-EFFECT_LAYER)

	if(EMP)
		Effect_images += image("icon"=effects_icon,"icon_state"="[initial(name)]_EMP","layer"=-EFFECT_LAYER)

	if(Effect_images.len)
		vehicle_overlays[EFFECT_LAYER] = Effect_images


	apply_overlay(EFFECT_LAYER)


/obj/vehicle/proc/handle_scale()
/*
handle_scale() allows for objects from 32x32 pixels
to 160x160 pixels and each pixel set has support
for sprites of the next multiple of 32
(32x32 supports 32x32 and 64x64 sprites)

vehicle_scale variable breakdown:
---------------------------------
0 = 32x32 bounds, with 32x32 sprites
1 = 32x32 bounds, with 64x64 sprites
2 = 64x64 bounds, with 64x64 sprites
3 = 64x64 bounds, with 96x96 sprites
4 = 96x96 bounds, with 96x96 sprites
5 = 96x96 bounds, with 128x128 sprites
6 = 128x128 bounds, with 128x128 sprites
7 = 128x128 bounds, with 160x160 sprites
8 = 160x160 bounds, with 160x160 sprites
9 = 160x160 bounds, with 192x192 sprites
*/
	switch(vehicle_scale)
		if(0)
			return
		if(1)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_64.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_64.dmi'
			pixel_x = -16
			pixel_y = -16
		if(2)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_64.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_64.dmi'
			bound_height = 64
			bound_width  = 64
		if(3)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_96.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_96.dmi'
			bound_height = 64
			bound_width  = 64
			pixel_x = -32
			pixel_y = -32
		if(4)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_96.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_96.dmi'
			bound_height = 96
			bound_width  = 96
		if(5)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_128.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_128.dmi'
			bound_height = 96
			bound_width  = 96
			pixel_x = -48
			pixel_y = -48
		if(6)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_128.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_128.dmi'
			bound_height = 128
			bound_width  = 128
		if(7)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_160.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_160.dmi'
			bound_height = 128
			bound_width  = 128
			pixel_x = -64
			pixel_y = -64
		if(8)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_160.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_160.dmi'
			bound_height = 160
			bound_width  = 160
		if(9)
			icon = 'icons/obj/NTvehicles/vehicle_pieces_192.dmi'
			effects_icon = 'icons/obj/NTvehicles/vehicle_effects_192.dmi'
			bound_height = 160
			bound_width  = 160
			pixel_x = -80
			pixel_y = -80
