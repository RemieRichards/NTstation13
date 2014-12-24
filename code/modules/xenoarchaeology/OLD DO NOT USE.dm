
var/global/datum/tech_tree/xenoarch/x_tech_tree //Global Tech Tree.

#define OTHER_TECH 1
#define COMBAT_TECH 2
#define NON_COMBAT_TECH 3
#define SPECIAL_TECH 4

/proc/xenoarch_tech_tree_check()
	if(!x_tech_tree)
		x_tech_tree = new /datum/tech_tree/xenoarch ()

//A check to make sure the tree exists, AND a way of creating a new tree if one doesn't

/datum/tech_tree
	var/research_points
	var/list/technology = list() //eg technology[NON_COMBAT_TECH]
	var/list/points_spent = list() //eg: points_spent[NON_COMBAT_TECH]
	var/list/possible_techs = typesof(/datum/tech) - /datum/tech //eg: typesof(/datum/tech/xenoarch) - /datum/tech/xenoarch

/datum/tech_tree/New()
	..()

	if(setup_tree()) //do we need to form a new tree or just replace a current one
		form_tech_tree()

/datum/tech_tree/proc/setup_tree()
	return 1 //This proc needs to be unique for each tech_tree datum, look at tech_tree/xenoarch for examples

/datum/tech_tree/xenoarch/setup_tree()
	if(x_tech_tree) //Global var of the tree we are to replace
		research_points = x_tech_tree.research_points
		technology = x_tech_tree.Copy() //Hopefully this copies all the associates to, like NON_COMBAT_TECH etc.
		var/datum/tech_tree/xenoarch_tech_tree/Holder = x_tech_tree
		qdel(Holder)
		x_tech_tree = src
		return 0
	return 1

/datum/tech_tree/proc/form_tech_tree()
	var/local_possible_techs = possible_techs.Copy()

	for(var/datum/tech/T in local_possible_techs)
		switch(tech_ID)
			if(NON_COMBAT_TECH)
				technology[NON_COMBAT_TECH] += T
			if(COMBAT_TECH)
				technology[COMBAT_TECH] += T
			if(OTHER_TECH)
				technology[OTHER_TECH] += T
			if(SPECIAL_TECH)
				technology[SPECIAL_TECH] += T

			local_possible_techs -= T

/datum/tech
	var/tech_name = "Technology!"
	var/tech_desc = "The wonders of science!"
	var/cost = 10
	var/tech_ID = OTHER_TECH

/datum/tech/proc/unlock_tech()
	points_spent[tech_ID] += 1



/datum/tech_tree/xenoarch
	possible_techs = typesof(/datum/tech/xenoarch) - /datum/tech/xenoarch
