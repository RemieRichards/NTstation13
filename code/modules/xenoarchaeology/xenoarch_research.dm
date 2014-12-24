/*
Contents:
	-Xenoarch item base
	-Xenoarch scanner base
	-Xenoarch Artifact Scanner and Research Code
	-Xenoarch Biological Remains Scanner and Research Code
*/


var/global/list/Xenoarch_researched_Genes = list() //List of researched Genes by mob typepath, Xenoarch_researched_Genes[typepath]
var/global/list/Xenoarch_raw_Genes = list() //List of unresearched DNA by mob typepath, Xenoarch_raw_Genes[typepath]

/obj/item/xenoarch
	name = "BASE TYPE"
	desc = "BADMINS ABOUT"
	icon = 'icons/obj/xenoarchaeology/xenoarchaeology.dmi'
	var/researched = 0
	var/scan_time = 20

/obj/machinery/xenoarch_scanner
	icon = 'icons/obj/xenoarchaeology/xenoarchaeology.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/scanning = 0

/////////////////////////
/// Artifact Research ///
/////////////////////////

/obj/machinery/xenoarch_scanner/Artifact
	name = "artifact scanner"
	desc = "Scans artifacts to uncover their mysteries"
	icon_state = "ART"
	var/obj/item/xenoarch/artifact/item2scan

/obj/machinery/xenoarch_scanner/Artifact/New()
	..()
	update_icon()

/obj/machinery/xenoarch_scanner/Artifact/update_icon()
	if(panel_open)
		icon_state = "ART-open"
	else if(!(stat & NOPOWER) && scanning)
		icon_state = "ART-active"
	else
		icon_state = "ART"
	return


/obj/machinery/xenoarch_scanner/Artifact/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/xenoarch/artifact))
		user.drop_item()
		I.loc = src
		item2scan = I
		user << "<span class='notice'>[I] has been inserted into the artifact scanner</span>"
		updateUsrDialog()
	else
		..()

/obj/machinery/xenoarch_scanner/Artifact/proc/scan_item(var/mob/user)
	if(scanning)
		user << "<span class='notice'>Scan is already in progress</span>"
		return

	if(!item2scan)
		user << "<span class='notice'>No item to scan</span>"
		return

	if(!istype(item2scan,/obj/item/xenoarch/artifact))
		user << "<span class='warning'>This item is incompatible with the artifact scanner</span>"
		item2scan.loc = src.loc
		item2scan = null
		return

	if(item2scan.researched)
		user << "<span class='notice'>This item has been exhausted of all research potential</span>"
		return

	if(!item2scan.research_points)
		user << "<span class='notice'>This item is worthless</span>"
		return

	scanning = 1
	update_icon()
	updateUsrDialog()
	sleep(item2scan.scan_time)
	updateUsrDialog()

	if(prob(item2scan.scan_success_chance))

		if(!x_tech_tree)
			x_tech_tree = new /datum/tech_tree/xenoarch ()

		x_tech_tree.research_points += item2scan.research_points

		user << "<span class='notice'>[item2scan.name] was researched for [item2scan.research_points] research points!</span>"
		item2scan.researched = 1
		item2scan.name += " (researched)"
	else
		user << "<span class='notice'>[item2scan.name] failed to scan, and was destroyed!</span>"
		item2scan.on_research_fail()
		var/obj/item/Holder = item2scan
		qdel(Holder)
		item2scan = null

	scanning = 0
	update_icon()
	updateUsrDialog()
	return


/obj/machinery/xenoarch_scanner/Artifact/attack_hand(mob/user)
	if(user.stat == 2 || !user)
		return
	interact(user)

/obj/machinery/xenoarch_scanner/Artifact/interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)

	var/dat = {"
	<B>Current Item</B>: [item2scan ? "<A href='?src=\ref[src];ejectitem=1'>[item2scan.name]</A>" : "No item present"]</br></n>
	<B>Research Points</B>: [x_tech_tree.research_points ? "[x_tech_tree.research_points]</A>" : "No stored research points"]</br></n>
	"}

	if(item2scan)
		dat += "<A href='?src=\ref[src];scan=1'><B>Scan Item</B></A>"


	var/datum/browser/popup = new(user,"Scanner","Artifact Scanner",450,250)
	popup.set_content(dat)
	popup.open()


/obj/machinery/xenoarch_scanner/Artifact/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(href_list["scan"])
		scan_item(usr)
	if(href_list["ejectitem"])
		if(item2scan)
			item2scan.loc = src.loc
			item2scan = null
		else
			usr << "<span class='notice'>No item to eject</span>"
	updateUsrDialog()


///////////////////////////////////
/// Biological Remains Research ///
///////////////////////////////////

/obj/machinery/xenoarch_scanner/biological
	name = "biological scanner"
	desc = "Decipher Gene sequences of long dead species"
	icon_state = "DNA"
	var/obj/item/xenoarch/bio_remains/item2scan //Item in the scanner slot
	var/obj/item/genetic_code/Genes //stored genesequence
	var/local_gene_name = "Unknown"//local copy of the mob name from the bio_remains

/obj/machinery/xenoarch_scanner/biological/New()
	..()
	update_icon()

/obj/machinery/xenoarch_scanner/biological/update_icon()
	if(panel_open)
		icon_state = "DNA-open"
	else if(!(stat & NOPOWER) && !scanning)
		icon_state = "DNA-idle"
	else if(!(stat & NOPOWER) && scanning)
		icon_state = "DNA-active"
	else
		icon_state = "DNA"
	return

/obj/machinery/xenoarch_scanner/biological/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/xenoarch/bio_remains))
		var/obj/item/xenoarch/bio_remains/B = I
		user.drop_item()
		B.loc = src
		item2scan = B
		user << "<span class='notice'>The [B] have been inserted into the biological scanner</span>"
		updateUsrDialog()

	else if(istype(I, /obj/item/genetic_code))
		var/obj/item/genetic_code/G = I
		user.drop_item()
		Genes = G
		G.loc = src
		var/mob/MobName = new Genes.DnaMob (src)
		local_gene_name = "[capitalize(MobName.name)]"
		qdel(MobName)
		user << "<span class='notice'>The [G] has been loaded into the Gemesequencer of the biological scanner</span>"
		updateUsrDialog()
	else
		..()

/obj/machinery/xenoarch_scanner/biological/power_change()
	..()
	update_icon()

/obj/machinery/xenoarch_scanner/biological/proc/scan_Genesequence(var/mob/user)
	if(scanning)
		user << "<span class='notice'>Scan is already in progress</span>"
		return

	if(!item2scan)
		user << "<span class='notice'>No item to scan for a Genesequence</span>"
		return

	if(!istype(item2scan,/obj/item/xenoarch/bio_remains))
		user << "<span class='warning'>The biological scanner only supports organic materials</span>"
		item2scan.loc = src.loc
		item2scan = null
		return

	if(item2scan.researched)
		user << "<span class='notice'>This item has been exhausted of all research potential</span>"
		return

	scanning = 1
	update_icon()
	updateUsrDialog()
	sleep(item2scan.scan_time)
	updateUsrDialog()

	if(item2scan.genes)
		if(prob(80))
			user << "<span class='notice'>The [item2scan.name] were scanned and a Genesequence was extracted and removed from the remains</span>"
			Genes = item2scan.genes
			var/mob/MobName = new Genes.DnaMob (src)
			local_gene_name = "[capitalize(MobName.name)]"
			qdel(MobName)
		else
			user << "<span class='danger'>SCAN FAILED, GENESEQUENCE INTEGRITY DAMAGED</span>"
			Genes.genetic_fail(50)
			scanning = 0
			update_icon()
			updateUsrDialog()
			return
	else
		user << "<span class='notice'>The [item2scan.name] were scanned, but no Genesequence was located</span>"

	item2scan.researched = 1
	item2scan.name += " (researched)"
	item2scan.genes = null

	scanning = 0
	update_icon()
	updateUsrDialog()
	return


/obj/machinery/xenoarch_scanner/biological/attack_hand(mob/user)
	if(user.stat == 2 || !user)
		return
	interact(user)

/obj/machinery/xenoarch_scanner/biological/interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)

	var/dat = {"
	<B>Current Item</B>: [item2scan ? "<A href='?src=\ref[src];ejectitem=1'>[item2scan.name]</A>" : "No item present"]</br>
	"}
	if(item2scan)
		dat += "<A href='?src=\ref[src];scan=1'><B>Scan Item</B></A></br></n>"

	dat += "\n"

	if(!scanning)
		if(Genes)
			dat += "<A href='?src=\ref[src];ejectgenes=1'><B>[local_gene_name] Genesequence</B></A></br></n>"
			var/sequence_num = 0
			for(var/thing in Genes.genesequence)
				sequence_num++
				dat += "<A href='?src=\ref[src];changegenes=1,sequence_num=[sequence_num]'>[thing]</A>"

			if(Genes.gene_integrity >= 50)
				dat += "</br></n><span class='green'>Genesequence integrity: [Genes.gene_integrity]</span>"
			else
				dat += "</br></n><span class='danger'>Genesequence integrity: [Genes.gene_integrity]</span>"
				dat += "</br></n><IMG CLASS=icon SRC=\ref'/icons/obj/xenoarchaeology/warning.dmi'>"

			dat += "</br></n><A href='?src=\ref[src];validategenes=1'><B>Simulate Genesequence</B></A>"
	else
		dat += "<B>PLEASE WAIT</B>"
		dat += "</br></n><IMG CLASS=icon SRC=\ref[icon] ICONSTATE='pls_wait'>"

	var/datum/browser/popup = new(user,"Scanner","Biological Scanner",450,250)
	popup.set_content(dat)
	popup.open()

/obj/machinery/xenoarch_scanner/biological/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(href_list["scan"])
		if(Genes)
			usr << "<span class='notice'>There is already a Genesequence in the Genesequencer</span>"
			return
		scan_Genesequence(usr)
	if(href_list["ejectitem"])
		if(item2scan)
			item2scan.loc = src.loc
			item2scan = null
		else
			usr << "<span class='notice'>No item to eject</span>"
	if(href_list["ejectgenes"])
		if(Genes)
			Genes.loc = src.loc
			Genes = null
			local_gene_name = "Unknown"
		else
			usr << "<span class='notice'>No Genesequence to eject</span>"
	if(href_list["changegenes"])

		var/list/DNA_Protein_Choices = list("A","C","T","G","?")

		var/which_protein

/*		var/list/new_sequence = list()

		for(var/I in Genes.genesequence)
			which_protein = input("Change Genesequence","Genetic Code") in DNA_Protein_Choices
			new_sequence += which_protein

		Genes.genesequence = new_sequence.Copy()

*/
		var/sequence = text2num(href_list["sequence_num"])


		which_protein = input("Change Protein","Genetic Code") as null|anything in DNA_Protein_Choices
		if(which_protein)
			Genes.genesequence[sequence] = which_protein
			usr << "[Genes.genesequence[sequence]] / [which_protein]"
			Genes.genesequence -= sequence//TEMP
			//BUG List entry adds "11"th entry to the list causing errors.

		updateUsrDialog()

	if(href_list["validategenes"])
		if(Genes && Genes.genesequence && Xenoarch_raw_Genes[Genes.DnaMob])
			usr << "<span class='notice'>Running simulation of current Genesequence</span>"

			//decodes both lists and sees if they match
			var/list/X = Xenoarch_raw_Genes[Genes.DnaMob]
			var/progress = 0
			var/success = 0

			var/I = 1
			while (I <= Genes.genesequence.len && I <= X.len) //While(I <= Genes.genesequence.len) //Perhaps change BACK to this after BUG is fixed
				if(Genes.genesequence[I] == X[I])
					progress++
				I++
			if(progress == Genes.genesequence.len)
				success++
			//end decode

			if(success)
				sleep(20)
				usr << "<span class='notice'>Genesequence simulation succesful!</span>"
				Xenoarch_researched_Genes[Genes.DnaMob] = Genes.genesequence
			else
				usr << "<span class='notice'>Error, Genesequence is not stable</span>"
				usr << "<span class='danger'>GENESEQUENCE INTEGRITY DAMAGED</span>"
				Genes.genetic_fail(25)
				usr << "<span class='danger'>GENESEQUENCE INTEGRITY NOW AT [Genes.gene_integrity]%"

	updateUsrDialog()


///////////////////////////////
/// Genetic Abomination Mob ///
///////////////////////////////

/mob/living/simple_animal/hostile/genetic_abomination
	icon = 'icons/obj/xenoarchaeology/xenoarchaeology.dmi'
	factions = list("abomination")

	force_threshold = 50

	heat_damage_per_tick = 0
	cold_damage_per_tick = 0

	melee_damage_lower = 15
	melee_damage_upper = 20

	ventcrawler = 2

	speak_emote = list("moans","groans","screeches")
	emote_hear = list("moans","groans","screeches")

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 0

/mob/living/simple_animal/hostile/genetic_abomination/New()
	..()

	icon_state = "abom[rand(1,4)]"
	icon_dead = "[icon_state]_dead"
	icon_living = icon_state

/////////////////////////////////////
/// Genetic Fabricator (Mob spawner) ///
/////////////////////////////////////

/obj/machinery/xenoarch_scanner/gene_fabricator
	name = "Genetic Fabricator"
	desc = "A machine designed to spin genetic sequences together to form mobs"
	icon_state = "bio_scan"
	var/mob/Mob2Create

/obj/machinery/xenoarch_scanner/gene_fabricator/attack_hand(mob/user)
	if(user.stat == 2 || !user)
		return
	interact(user)

/obj/machinery/xenoarch_scanner/gene_fabricator/interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)

	var/dat

	if(!scanning)
		dat += "Chosen Mob\n"
		dat += "\n"

		if(Xenoarch_researched_Genes)
			dat += "<A href='?src=\ref[src];mob=1'><B>Choose a valid genesequence</B></A></br></n>"
		else
			dat += "No valid genesequences\n"

		if(Mob2Create)
			dat += "<A href='?src=\ref[src];Make=1'><B>Mob Selected</B></A></br></n>"
		else
			dat += "No Mob selected\n"
	else
		dat += "<B>PLEASE WAIT</B>"
		dat += "</br></n><IMG CLASS=icon SRC=\ref/icons/obj/xenoarchaeology/pls_wait.dmi>"

	var/datum/browser/popup = new(user,"Genetic Fabricator","Genetic Fabricator",450,250)
	popup.set_content(dat)
	popup.open()

/obj/machinery/xenoarch_scanner/gene_fabricator/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	if(href_list["mob"])
		if(Xenoarch_researched_Genes)
			var/Mob = input(usr,"Choose a mob to create","Create Mob") as null|anything in Xenoarch_researched_Genes
			if(Mob)
				Mob2Create = Mob

	if(href_list["Make"])
		if(Mob2Create)
			new Mob2Create (src.loc)
			scanning = 1
			updateUsrDialog()
			spawn(300)
			scanning = 0

	updateUsrDialog()
