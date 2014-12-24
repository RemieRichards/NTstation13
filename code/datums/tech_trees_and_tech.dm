
/datum/tech_tree
	var/research_points = 0
	var/list/technology = list() //eg technology[NON_COMBAT_TECH]
	var/list/points_spent = list() //eg: points_spent[NON_COMBAT_TECH]
	var/list/tech_progress = list() //eg: tech_progress[NON_COMBAT_TECH]
	var/list/possible_techs = list() //Filled in New()
	var/tech_typepath = /datum/tech //Typepath of techs this tree uses

/////////////////////
// TECH TREE DATUM //
/////////////////////


/datum/tech_tree/New()
	..()

	init_subtypes(tech_typepath,possible_techs)

	if(setup_tree()) //do we need to form a new tree or just replace a current one
		form_tech_tree()

/datum/tech_tree/proc/setup_tree() //Optional proc for if a tree is created while a copy exists, defaults to a roundstart equivelant of the list
	return 1 //This proc needs to be unique for each tech_tree datum, look at tech_tree/xenoarch for examples

/datum/tech_tree/proc/form_tech_tree()
	var/local_possible_techs = possible_techs.Copy()

	for(var/datum/tech/T in local_possible_techs)
		switch(T.tech_ID)
			if(NON_COMBAT_TECH)
				technology[NON_COMBAT_TECH] += T
			if(COMBAT_TECH)
				technology[COMBAT_TECH] += T
			if(OTHER_TECH)
				technology[OTHER_TECH] += T
			if(SPECIAL_TECH)
				technology[SPECIAL_TECH] += T

		local_possible_techs -= T

/datum/tech_tree/proc/unlock_tech(var/datum/tech/T)
	if(research_points >= T.cost)
		research_points -= T.cost
		points_spent[T.tech_ID] += T.cost
		tech_progress[T.tech_ID]++
		T.tech_unlocked++
		return 1
	return 0

/datum/tech_tree/proc/check_progress(var/TREE)
	var/percentage_progress = 0

	if(tech_progress[TREE])
		var/local_progress = tech_progress[TREE]
		var/list/local_total = technology[TREE]

		percentage_progress = (local_progress/local_total.len * 100)

	if(percentage_progress)
		return percentage_progress

	return 0

////////////////
// TECH DATUM //
////////////////

/datum/tech
	var/tech_name = "Technology!"
	var/tech_desc = "The wonders of science!"
	var/cost = 10
	var/tech_ID = OTHER_TECH
	var/tech_unlocked = 0

