//This is where most of the items made by the forge go.
//To add a recipe, see code/datums/crafting.dm

//*low-tier*

/obj/item/weapon/navigator //gps basically
	name = "navigator's compass"
	desc = "It's a compass... that somehow works in space.  The directions are also replaced with unknown markings.  You still feel like you know where you are when you hold this, however."
	icon_state = null
	var/location_output_xy
	var/location_output_z = null

/obj/item/weapon/navigator/attack_self()
	switch(location_output_xy)
		if(src.x && src.y < 85)
			location_output_xy ="south-east"
		if(src.x <
	switch(location_output_z)
		if(src.loc.z == 1) //station
			location_output_z = "a bustling area, that can easily shatter."
		if(src.loc.z == 2) //centcom
			location_output_z = "a place forbidden to most."
		if(src.loc.z == 3) //tcommsat
			location_output_z = "an abandoned "
		if(src.loc.z == 4) //derelict
			location_output_z = "a great ruin."
		if(src.loc.z == 5) //mining
			location_output_z = "a world of caves, filled with danger."
		if(src.loc.z == 6) //empty z-level
			location_output_z = "an empty void."
	usr << "You hold the compass in your hand.  A thought rushes into your head; 'You are [location_output_xy] of [location_output_z]'"

/obj/item/weapon/goddetector
	name = "divine stone"
	desc = "This rock does what mankind has tried to do for thousands of years; find god.  Unfortinately it's hard to tell <i>which</i> god might be looking over your shoulder at any moment."
	icon_state = null //sprites pls

/obj/item/weapon/goddetector
	var/track_delay = 0

/obj/item/weapon/goddetector/New()
	..()
	processing_objects += src


/obj/item/weapon/goddetector/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/goddetector/process()

	if(track_delay > world.time)
		return

	var/found_eye = 0
	var/turf/our_turf = get_turf(src)

	if(cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))

		var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)

		if(chunk)
			if(chunk.seenby.len)
				for(var/mob/camera/god/A in chunk.seenby)
					var/turf/eye_turf = get_turf(A)
					if(get_dist(our_turf, eye_turf) < 8)
						found_eye = 1
						world << "DEITY IS HERE!1111"
						break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return

/obj/item/clothing/suit/space/traveler
	name = "traveler's space suit"
	desc = "A lightweight but bulky space suit somehow made out of metal.  It doesn't look very protective."
	icon_state = "cult_armour"//placeholder
	item_state = "cult_armour"
	w_class = 4
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 25)

/obj/item/clothing/head/helmet/space/traveler
	name = "traveler's space helmet"
	icon_state = "cult_helmet"//placeholder
	item_state = "cult_helmet"
	desc = "A helmet made out of glass and metal.  It's somehow sturdy but it doesn't look very protective."
	flags_inv = HIDEFACE
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 25)

/obj/item/clothing/suit/robe
	name = "robe"
	icon_state = null //sprites pls
	item_state = null
	desc = "A robe made out of cloth.  You suspect it's not an ordinary robe."

/obj/item/clothing/suit/robe/armored
	name = "armored robe"
	icon_state = null
	item_state = null
	desc = "A robe with a armor vest.  It's more protective and you still get to wear a robe!"
	armor = list(melee = 40, bullet = 5, laser = 40, energy = 10, bomb = 15, bio = 0, rad = 0)

/obj/item/weapon/banner //Doesn't do anything besides looking cool.  The HoG version of the syndie balloon.
	name = "banner"
	icon = 'icons/obj/items.dmi'
	icon_state = "banner"
	item_state = "banner"
	desc = "A banner with Nanotrasen's logo on it."

/obj/item/weapon/banner/red
	name = "red banner"
	icon_state = "bannerred"
	item_state = "bannerred"
	desc = "A banner with a red motif."

/obj/item/weapon/banner/blue
	name = "red banner"
	icon_state = "bannerred"
	item_state = "bannerred"
	desc = "A banner with a blue motif."

/obj/item/weapon/banner/grey //for the Grey Crusades
	name = "grey banner"
	icon_state = "bannergrey"
	item_state = "bannergrey"
	desc = "A banner with a toolbox logo, likely assistant-related."

/obj/item/clothing/suit/armor/vest/blessed
	name = "blessed armor vest"
	desc = "It look like all the other armor vests you've seen, but wearing it makes you feel slightly warm.  Maybe it's also better?"
	armor = list(melee = 60, bullet = 25, laser = 60, energy = 20, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/blessed
	name = "blessed helmet"
	desc = "A helmet that seems warm for some reason.  Not warm enough to protect you in space, but it's still nice.  Might be better too?"
	armor = list(melee = 60, bullet = 25, laser = 60,energy = 20, bomb = 35, bio = 0, rad = 0)

/obj/item/weapon/storage/backpack/bannerpack
	name = "nanotrasen banner backpack"
	desc = "It's a backpack with lots of extra room.  A banner with Nanotrasen's logo is attached, that can't be removed."
	max_combined_w_class = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.
	icon_state = "bannerpack"

/obj/item/weapon/storage/backpack/bannerpack/red
	name = "red banner backpack"
	desc = "It's a backpack with lots of extra room.  A red banner is attached, that can't be removed."
	icon_state = "bannerpackred"

/obj/item/weapon/storage/backpack/bannerpack/blue
	name = "blue banner backpack"
	desc = "It's a backpack with lots of extra room.  A blue banner is attached, that can't be removed."
	icon_state = "bannerpackblue"

//**mid-tier**

/obj/item/clothing/shoes/syndigaloshes/waterwalker
	name = "waterwalker boots"
	icon_state = "cult" //placeholder
	desc = "Boots rumored to let the wearer walk on water.  Unfortunately there's no large bodies of water in space, but they do prevent you from slipping, at least."
	flags = NOSLIP

/obj/item/clothing/glasses/thermal/monocle/hunter
	name = "hunter's eye"
	desc = "A monocle that seems to let you see a person's 'aura', allowing you to easily judge where they are even behind a wall."
	icon_state = "thermoncle"

/obj/item/weapon/selfhealer
	name = "Amulet of Healing"
	desc = "A necklace that is said to speed up the natual healing process, if used.  Squeezing it seems to count as 'using'."

//***high-tier***

/obj/item/weapon/selfhealer/super
	name = "Amulet of Rapid Regeneration"
	desc = "This necklace makes you very hard to kill if used before a fight.  Even if you are mortally wounded, it will sustain you until you get up once more, or your enemies kill you for good."


//this is all part of one item set
/obj/item/clothing/suit/armor/plate/crusader
	name = "Crusader's Armor"
	desc = "This is a very protective piece of armor, even if it doesn't look like it."
	icon_state = "crusader"
	w_class = 4 //bulky
	slowdown = 1.0 //gotta pretend we're balanced.
	armor = list(melee = 70, bullet = 70, laser = 70,energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/plate/crusader
	name = "Crusader's Hood"
	desc = "An hood that's somehow as protective as a metal helmet."
	icon_state = "crusader"
	w_class = 3 //normal
	flags = BLOCKHAIR
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 70, bullet = 70, laser = 70,energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	desc = "A pair of metal gauntlets.  They protect against heat, and electrity.  You're not sure how metal can do that but it's too useful to question."
	icon_state = "crusader"
	siemens_coefficient = 0 //this protects from shock

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	desc = "Boots that are made of metal.  The weight of them makes you unable to slip, and they don't seem to even slow you down."
	icon_state = "crusader"
	w_class = 3 //normal
//	armor = list(melee = 70, bullet = 70, laser = 70,energy = 40, bomb = 60, bio = 0, rad = 0) //does this even do anything on boots?
	flags = NOSLIP

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/weapon/storage/box/itemset/crusader
	name = "Crusader's Armor Set" //i can't into ck2 references
	desc = "This armor is said to be based on the armor of kings on another world thousands of years ago, who tended to assassinate, conspire, and plot against everyone who tried to do the same to them.  Some things never change."
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/suit/armor/plate/crusader(src)
		new /obj/item/clothing/head/helmet/plate/crusader(src)
		new /obj/item/clothing/gloves/plate(src)
		new /obj/item/clothing/shoes/plate(src)
		return

/obj/item/clothing/suit/space/juggernaut
	name = "Juggernaut's Armor"
	desc = "This armor is moderately protective, as well as space-worthy and fireproof."
	icon_state = "heavy"
	w_class = 4 //bulky
	slowdown = 1.0
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 70, bomb = 80, bio = 100, rad = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/juggernaut
	name = "Juggernaut's Helmet"
	desc = "A helmet that's spaceworthy, and makes you feel unstoppable, at least, to the elements."
	icon_state = "crusader"
	w_class = 3 //normal
	flags = BLOCKHAIR
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 70, bomb = 80, bio = 100, rad = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

/obj/item/weapon/storage/box/itemset/juggernaut
	name = "Juggernaut's Armor Set"
	desc = "This armor's spaceworthy as well as fireproof."
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/suit/space/juggernaut(src)
		new /obj/item/clothing/head/helmet/space/juggernaut(src)
		new /obj/item/clothing/gloves/plate(src)
		new /obj/item/clothing/shoes/plate(src)
		return

/obj/item/weapon/shield/nullshield
	name = "null shield"
	desc = "A shield made out of obsidian, with a rune carved into it.  It seems to sometimes reflect projectiles."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullshield"
	force = 13.0
	throwforce = 5.0
	w_class = 4 //bulky
	attack_verb = list("shoved", "bashed")
	reflect_chance = 40

/obj/item/weapon/shield/energy/IsShield()
	return 1

/obj/item/weapon/shield/energy/IsReflect()
	return 1