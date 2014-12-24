
/datum/tech_tree/xenoarch
	tech_typepath = /datum/tech/xenoarch

/datum/tech/xenoarch
	tech_name = "Xenoarch Base Tech"
	tech_desc = "Base Xenoarch Tech"

/datum/tech_tree/xenoarch/setup_tree()
	if(x_tech_tree) //Global var of the tree we are to replace
		research_points = x_tech_tree.research_points
		technology = x_tech_tree.technology.Copy() //Hopefully this copies all the associates to, like NON_COMBAT_TECH etc.
		var/datum/tech_tree/xenoarch/Holder = x_tech_tree
		qdel(Holder)
		x_tech_tree = src
		return 0
	return 1

