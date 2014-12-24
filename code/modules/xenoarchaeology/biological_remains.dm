/*
Contents:
	-bio_remains item base
	-premade bio_remains defines
	-genetic_code item base
	-genetic_code Genesequence Procs()
*/


#define CHANCE_TO_KEEP_PROTEIN	30 //Percentage chance for a protein in a genesequence to remain known
#define MAX_GENESEQUENCE_LEN	15
#define MIN_GENESEQUENCE_LEN	5

/obj/item/xenoarch/bio_remains
	name = "Remains"
	desc = "Some kind of biological remains..."
	icon_state = "dna"
	var/obj/item/genetic_code/genes

/obj/item/xenoarch/bio_remains/New()
	..()

	if(!genes)
		genes = new /obj/item/genetic_code (src)
		genes.generate_DnaMob()
		genes.generate_genesequence()
		genes.ruin_genesequence()

/obj/item/genetic_code
	name = "DNA genesequence"
	desc = "Deoxyribonucleic acid... I mean... science!"
	icon_state = "dna"
	icon = 'icons/obj/xenoarchaeology/xenoarchaeology.dmi'
	var/list/genesequence = list()
	var/mob/living/simple_animal/DnaMob
	var/gene_integrity = 100

/obj/item/genetic_code/proc/run_integrity_check()
	if(gene_integrity >= 1)
		return 1
	return 0

/obj/item/genetic_code/proc/generate_DnaMob()
	var/list/excluded = list(/mob/living/simple_animal, /mob/living/simple_animal/hostile/retaliate, /mob/living/simple_animal/hostile, \
	/mob/living/simple_animal/hostile/asteroid, /mob/living/simple_animal/construct, /mob/living/simple_animal/hostile/hivebot/tele, \
	/mob/living/simple_animal/construct/armoured, /mob/living/simple_animal/construct/wraith, /mob/living/simple_animal/construct/builder, \
	/mob/living/simple_animal/construct/behemoth, /mob/living/simple_animal/shade, /mob/living/simple_animal/hostile/mining_drone, \
	/mob/living/simple_animal/hostile/retaliate/clown, /mob/living/simple_animal/hostile/syndicate, /mob/living/simple_animal/hostile/syndicate/melee, \
	/mob/living/simple_animal/hostile/syndicate/melee/space, /mob/living/simple_animal/hostile/syndicate/ranged, \
	/mob/living/simple_animal/hostile/syndicate/ranged/space, /mob/living/simple_animal/hostile/russian, /mob/living/simple_animal/hostile/pirate, \
	/mob/living/simple_animal/hostile/pirate/ranged, /mob/living/simple_animal/hostile/mimic, /mob/living/simple_animal/hostile/mimic/crate, \
	/mob/living/simple_animal/hostile/mimic/copy, /mob/living/simple_animal/hostile/mimic/copy/machine, /mob/living/simple_animal/hostile/russian/ranged, \
	/mob/living/simple_animal/hostile/hivebot, /mob/living/simple_animal/hostile/hivebot/rapid, /mob/living/simple_animal/hostile/hivebot/range)
	//SO MANY BANNED MOBS
	var/list/raw_mobs = typesof(/mob/living/simple_animal)
	var/list/valid_mobs = raw_mobs - excluded
	var/mob/living/simple_animal/Picked = pick(valid_mobs)

	if(Picked)
		DnaMob = Picked
	else
		generate_DnaMob() //shouldn't run, failsafe

/obj/item/genetic_code/proc/generate_genesequence()
	if(!DnaMob)
		generate_DnaMob()

	if(Xenoarch_raw_Genes[DnaMob])
		genesequence = Xenoarch_raw_Genes[DnaMob]
		return

	var/list/DNA_proteins = list("A","C","T","G")

	var/I = rand(MIN_GENESEQUENCE_LEN,MAX_GENESEQUENCE_LEN)
	var/II = 1
	genesequence.len = I

	while (II <= I)
		genesequence[II] += pick(DNA_proteins)
		II++

	Xenoarch_raw_Genes[DnaMob] = genesequence


/obj/item/genetic_code/proc/ruin_genesequence()
	if(!genesequence)
		generate_genesequence()

	var/list/new_genesequence = list()

	for(var/I in genesequence) //Ruin the genesequence
		if(prob(CHANCE_TO_KEEP_PROTEIN))
			new_genesequence += I
		else
			new_genesequence += "?"

	genesequence = new_genesequence


/obj/item/genetic_code/proc/genetic_fail(var/amt_to_lower)
	gene_integrity -= amt_to_lower
	if(!run_integrity_check())
		var/mob/living/simple_animal/hostile/genetic_abomination/GA = new (src.loc)
		GA.target = usr //I'mma getcha!
		del(src)
	return 0


#undef CHANCE_TO_KEEP_PROTEIN
#undef MAX_GENESEQUENCE_LEN
#undef MIN_GENESEQUENCE_LEN