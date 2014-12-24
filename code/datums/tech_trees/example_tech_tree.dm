
///////////////////////
// EXAMPLE TECH TREE //
///////////////////////

/*
/datum/tech_tree/EXAMPLE
	tech_typepath = /datum/tech/EXAMPLE

/datum/tech_tree/EXAMPLE/setup_tree()
	if(EXAMPLE_tech_tree) //Global var of the tree we are to replace
		research_points = EXAMPLE_tech_tree.research_points
		technology = EXAMPLE_tech_tree.Copy()
		var/datum/tech_tree/xenoarch_tech_tree/Holder = EXAMPLE_tech_tree
		qdel(Holder)
		EXAMPLE_tech_tree = src
		return 0
	return 1

/datum/tech/EXAMPLE
	tech_name = "EXAMPLE"
	tech_desc = "EXAMPLES ARE FUN"
	cost = 99999999999999
	tech_ID = EXAMPLE_TECH


*/