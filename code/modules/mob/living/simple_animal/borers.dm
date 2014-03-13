//Credit:
//Baystation12 (Original) + RobRichards (Porting/Fixes/Balance)

/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='warning'>You cannot speak in IC (muted).</span>"
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "The captive mind of [src] whispers, \"[message]\""

		for (var/mob/M in player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				M << "The captive mind of [src] whispers, \"[message]\""

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 4
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	pass_flags = PASSTABLE
	ventcrawler = 2

	// ATMOS - Weak to it, for balance
	unsuitable_atoms_damage = 5

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and secreting chemicals.
	var/mob/living/carbon/host        		// Carbon host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Control variable.
	var/docile = 0                          // Sugar can stop borers from acting.

/mob/living/simple_animal/borer/Life()

	..()


	if(host)

		if(!stat && !host.stat)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						host << "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>"
					else
						src << "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>"
					docile = 1
			else
				if(docile)
					if(controlling)
						host << "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>"
					else
						src << "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>"
					docile = 0

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					host << "<span class='notice'>You are feeling far too docile to continue controlling your host...</span>"
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/New()
	..()
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	host_brain = new/mob/living/captive_brain(src)

	request_player()


/mob/living/simple_animal/borer/say(var/message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='warning'>You cannot speak in IC (muted).</span>"
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if (copytext(message, 1, 2) == ";") //Brain borer hivemind.
		return borer_speak(message)

	if(!host)
		src << "You have no host to speak to."
		return //No host, no audible speech.

	src << "You drop words into [host]'s mind: \"[message]\""
	host << "Your own thoughts speak: \"[message]\""

	for (var/mob/M in player_list)
		if (istype(M, /mob/new_player))
			continue
		else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
			M << "[src.truename] whispers to [host], \"[message]\""


/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || istype(M, /mob/dead/observer)))
			M << "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>"

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Scare Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	if(host)
		src << "You cannot do that from within a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != 2)
			choices += C

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to scare?") in null|choices

	if(!M || !src) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	src << "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>"
	M << "<span class='warning'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>"
	M.Weaken(3)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	if(!host.getorgan(/obj/item/organ/brain)) //this should only run in admin-weirdness situations, but it's here non the less - RR
		src << "<span class='warning'>This creature's brain is too simple in structure!</span>"
		return

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that."
		return

	src << "You begin delicately adjusting your connection to the host brain..."

	spawn(300+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else
			src << "<span class='warning'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>"
			host << "<span class='warning'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>"

			host_brain.ckey = host.ckey
			host.ckey = src.ckey
			controlling = 1

			host.verbs += /mob/living/proc/release_control
			host.verbs += /mob/living/simple_animal/borer/proc/punish_host
			host.verbs += /mob/living/simple_animal/borer/proc/spawn_larvae

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot secrete chemicals in your current state."

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that.</span>"
		return

	if(chemicals < 50)
		src << "You don't have enough chemicals!"

	var/chem = input("Select a chemical to secrete.", "Chemicals") in list("bicaridine","hyperzine","plasma","space_drugs","oxygen")

	if(chemicals < 50 || !host || controlling || !src || stat) //Sanity check.
		return

	src << "<span class='warning'>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</span>"
	host.reagents.add_reagent(chem, 15)
	chemicals -= 50

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot leave your host in your current state."

	if(docile)
		src << "<span class='warning'>You are feeling far too docile to do that.</span>"
		return

	if(!host || !src) return

	src << "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal."

	if(!host.stat)
		host << "An odd, uncomfortable pressure begins to build inside your skull, behind your ear..."

	spawn(200)

		if(!host || !src) return

		if(src.stat)
			src << "You cannot infest a target in your current state."
			return

		src << "You wiggle out of [host]'s ear and plop to the ground."
		if(!host.stat)
			host << "Something slimy wiggles out of your ear and plops to the ground!"

		detatch()

mob/living/simple_animal/borer/proc/detatch()

	if(!host) return

	src.loc = get_turf(host)
	controlling = 0

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	host.verbs -= /mob/living/proc/release_control
	host.verbs -= /mob/living/simple_animal/borer/proc/punish_host
	host.verbs -= /mob/living/simple_animal/borer/proc/spawn_larvae

	if(host_brain.ckey)
		src.ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"

	host = null

/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
	set name = "Infest"
	set desc = "Infest a suitable carbon-based host."

	if(host)
		src << "You are already within a host."
		return

	if(stat)
		src << "You cannot infest a target in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != 2 && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(!H.can_inject(src,1,1))
			return

	src << "You slither up [M] and begin probing at their ear canal..."

	if(!do_after(src,50))
		src << "As [M] moves away, you are dislodged and fall to the ground."
		M << "You hear something fall to the ground..."
		return

	if(!M || !src) return

	if(src.stat)
		src << "You cannot infest a target in your current state."
		return

	if(M.stat == 2)
		src << "That is not an appropriate target."
		return

	if(src.Adjacent(M))
		src << "You wiggle into [M]'s ear."

		src.host = M
		src.loc = M


		host_brain.name = M.name
		host_brain.real_name = M.real_name

		return
	else
		src << "They are no longer in range!"
		return


//Procs for grabbing players.
mob/living/simple_animal/borer/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Alien"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_ALIEN)
				question(O.client)

mob/living/simple_animal/borer/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "A cortical borer needs a player. Are you interested?", "Cortical borer request", "Yes", "No", "Never for this round")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_ALIEN

mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Cortical Borer"


/mob/living/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		src << "<span class='warning'>You withdraw your probosci, releasing control of [B.host_brain]</span>"
		B.host_brain << "<span class='warning'>Your vision swims as the alien parasite releases control of your body.</span>"
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	verbs -= /mob/living/proc/release_control
	verbs -= /mob/living/simple_animal/borer/proc/punish_host
	verbs -= /mob/living/simple_animal/borer/proc/spawn_larvae

//Brain slug proc for tormenting the host.
/mob/living/simple_animal/borer/proc/punish_host()
	set category = "Borer"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		src << "<span class='warning>You send a punishing spike of psychic agony lancing into your host's brain.</B>"
		B.host_brain << "<span class='danger'>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</span>"

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/living/simple_animal/borer/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		src << "<span class='userdanger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>"
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		B.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src))

	else
		src << "You do not have enough chemicals stored to reproduce."
		return

/mob/living/simple_animal/borer/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Borer"

	handle_hide()