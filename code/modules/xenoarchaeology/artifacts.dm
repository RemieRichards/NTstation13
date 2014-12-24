/*
Contents:
	-artifact item base
	-premade artifact defines
	-artifact event code
*/


/obj/item/xenoarch/artifact
	name = "Unkown Artifact"
	desc = "some kind of artifact"
	var/research_points = 0 //How many points to give for researching
	var/scan_success_chance = 0 //Chance to succeed in a scan


/obj/item/xenoarch/artifact/New()
	..()

	//supply values if they're not overridden in definition
	if(!research_points)
		research_points = rand(1,10)
	if(!scan_success_chance)
		scan_success_chance = rand(75,100)


/obj/item/xenoarch/artifact/alien_pistol
	name = "alien pistol"
	icon_state = "alienpistol"
	desc = "an alien weapon, seems to be a pistol"
	research_points = 10
	scan_success_chance = 85

/obj/item/xenoarch/artifact/light_alien_rifle
	name = "light alien rifle"
	icon_state = "lightalienrifle"
	desc = "an alien weapon, seems to be a light rifle"
	research_points = 20
	scan_success_chance = 75

/obj/item/xenoarch/artifact/alien_rifle
	name = "alien rifle"
	icon_state = "alienrifle"
	desc = "an alien weapon, seems to be a rifle"
	research_points = 30
	scan_success_chance = 65

/obj/item/xenoarch/artifact/proc/on_research_fail()
	if(prob(5))
		if(prob(20))
			new /datum/round_event/electrical_storm ()
		else if(prob(20))
			new /datum/round_event/meteor_wave ()
		else if(prob(20))
			new /datum/round_event/communications_blackout ()
		else if(prob(20))
			new /datum/round_event/radiation_storm ()
		else
			new /datum/round_event/falsealarm ()

