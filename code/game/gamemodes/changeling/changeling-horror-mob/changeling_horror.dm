
/mob/living/carbon/changelinghorror
	icon = 'icons/mob/changelinghorror.dmi'
	name = "Shambling Abomination"
	desc = "What disgusting horror birthed this monstrosity?"
	maxHealth = 350
	health = 350
	factions = list("changeling")
	var/Default_Damage = 30
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0


/mob/living/carbon/changelinghorror/assimilant
	maxHealth = 200
	health = 200
	Default_Damage = 20


/mob/living/carbon/changelinghorror/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", a_intent))
	stat(null, text("Move Mode: []", m_intent))
	if(client && mind)
		if(client.statpanel == "Status")
			if(mind.changeling)
				stat("Chemical Storage:", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)
	return


/mob/living/carbon/changelinghorror/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	horror_say(message)


/mob/living/carbon/changelinghorror/proc/horror_say(var/message)
	log_say("[key_name(src)] : [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"


	visible_message(rendered)








