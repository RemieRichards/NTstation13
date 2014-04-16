
/*
Horror form abilities, By RR
*/


///////////////////////////
///	   Become Horror	///
///////////////////////////

/obj/effect/proc_holder/changeling/HorrorForm
	name = "Unleash Horror Form"
	desc = "Transform into a Shambling Abomination."
	helptext = "Transform into a Shambling Abomination after a short delay, VERY OBVIOUS."
	chemical_cost = 40
	dna_cost = 0
	req_human = 1
	req_stat = CONSCIOUS

/obj/effect/proc_holder/changeling/HorrorForm/sting_action(var/mob/living/carbon/user)
	if(!istype(user))
		return

	user.visible_message("<span class='danger'>[user] collapses into a mound of flesh!</span>","<span class='notice'>We begin to rework our Genetic structure..</span>","<span class='warning'>You hear the sound of writhing flesh.</span>")

	var/mob/living/carbon/changelinghorror/Horror

	if(user.mind.changeling.assimilant)
		Horror = user.Horrorize(1, "[user.dna.real_name]-Assimilant")
	else
		Horror = user.Horrorize(0, "[user.mind.changeling.horror_name]")

	Horror.dna = user.dna
	Horror.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	Horror.icon_state = Horror.mind.changeling.horror_icon
	Horror.visible_message("<span class='danger'>the mound of flesh transforms into [Horror]!</span>","<span class='warning'>We are Revealed!</span>","<span class='warning'>You hear a Guttural screech.</span>")

	playsound(get_turf(Horror), 'sound/hallucinations/growl2.ogg', 50, 1)

	feedback_add_details("changeling_powers","HF")
	.=1
	qdel(user)


///////////////////////////
///	  Spawn Assimilant	///
///////////////////////////

/obj/effect/proc_holder/changeling/Assimilant
	name = "Produce Assimilant"
	desc = "Split a portion of our being off to form a seperate being."
	helptext = "Lose one of your aborbed DNA to create an Ally with <i>some</i> of your abilities. WARNING, You lose the chosen DNA."
	chemical_cost = 20
	dna_cost = 0
	req_horror = 1

/obj/effect/proc_holder/changeling/Assimilant/sting_action(var/mob/living/carbon/user)
	if(!istype(user))
		return

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
	var/client/C = null

	if(candidates.len)
		C = pick(candidates)

	if(!C)
	/*
		user << "<span class='notice'>You cannot split your consciousness at the present time</span>"
		return
	*/
		C = user.client

	var/datum/dna/CHOSEN = user.mind.changeling.select_dna("Choose a DNA to create an Assimilant from","Choose DNA")

	if(!CHOSEN)
		return

	if(CHOSEN == user.dna)
		user << "<span class='notice'>We cannot seperate our current DNA!</span>"
		return

	user.mind.changeling.absorbed_dna -= CHOSEN

	user << "<span class='notice'>We begin to seperate our Genetic structure...</span>"

	if(!do_after(user,40))
		return

	if(C)
		var/mob/living/carbon/human/Assimilant = new /mob/living/carbon/human (user.loc)

		C.mob.mind.transfer_to(Assimilant)

		playsound(get_turf(Assimilant), 'sound/hallucinations/growl1.ogg', 50, 1)

		var/datum/changeling/AMC = Assimilant.mind.changeling

		Assimilant.make_changeling()
		AMC.assimilant = 1
		AMC.UniqueHorror()
		Assimilant.remove_changeling_powers(0)
		Assimilant.dna = CHOSEN
		updateappearance(Assimilant)
		AMC.purchasedpowers += new /obj/effect/proc_holder/changeling/sting/extract_dna(null)
		AMC.purchasedpowers += new /obj/effect/proc_holder/changeling/fakedeath(null)
		AMC.purchasedpowers += new /obj/effect/proc_holder/changeling/absorbDNA(null)
		AMC.purchasedpowers += new /obj/effect/proc_holder/changeling/transform(null)
		AMC.purchasedpowers += new /obj/effect/proc_holder/changeling/HorrorForm(null)
		Assimilant << "<span class='notice'>We have split off from the Whole!</span>"
		Assimilant << "<span class='notice'>We are weak and have only a select few abilities</span>"
		return 1

	return


