//This is where most of the items made by the forge go.
//To add a recipe, see code/datums/crafting.dm

//*low-tier*
/*
/obj/item/weapon/navigator //gps basically
	name = "navigator's compass"
	desc = "It's a compass... that somehow works in space.  The directions are also replaced with unknown markings.  You still feel like you know where you are when you hold this, however."
	icon_state = null //sprite pls
	var/location_output_xy = null
	var/location_output_z = null

/obj/item/weapon/navigator/attack_self()
	switch(location_output_xy)
		if(src.x && src.y =< 85)
			location_output_xy ="south-east"
		if((src.x >= 86 && src.x =< 170) && src.y =< 85)
			location_output_xy = "south"
		else
			location_outpust_xy = "somewhere"
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
*/
/*
/obj/item/weapon/goddetector
	name = "divine stone"
	desc = "This rock does what mankind has tried to do for thousands of years; find god.  Unfortinately it's hard to tell <i>which</i> god might be looking over your shoulder at any moment."
	icon_state = null //sprites pls
*/

/obj/item/clothing/suit/space/traveler
	name = "traveler's space suit"
	icon_state = "cult_armour"//placeholder
	item_state = "cult_armour"
	w_class = 4
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 25)

/obj/item/clothing/suit/space/traveler/examine()
	..()
	if(!isfollower(usr))
		usr << "A lightweight spacesuit made out of a thin layer of metal."
	else
		usr << "Lightweight spacesuit that's said to be used by space pilgrims to find new derelicts to colonize in.  It's not very protective."

/obj/item/clothing/head/helmet/space/traveler
	name = "traveler's space helmet"
	icon_state = "cult_helmet"//placeholder
	item_state = "cult_helmet"
	flags_inv = HIDEFACE
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 25)

/obj/item/clothing/head/helmet/space/traveler/examine()
	..()
	if(!isfollower(usr))
		usr << "A helmet made out of a thin layer of metal and glass."
	else
		usr << "A helmet that's said to be used by space pilgrims to find new derelicts to colonize in.  It's not very protective."

/obj/item/clothing/suit/robe
	name = "robe"
	icon_state = null //sprites pls
	item_state = null
	desc = "A robe made out of cloth."

/obj/item/clothing/suit/robe/armored
	name = "armored robe"
	icon_state = null
	item_state = null
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 10, bullet = 15, laser = 10, energy = 15, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/suit/robe/armored/examine()
	..()
	if(!isfollower(usr))
		usr << "A robe with an armor vest."
	else
		usr << "Robes blessed to protect you from harm.  It's as effective as traditional armor but it covers your arms and legs."

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

/obj/item/weapon/banner/red/examine()
	..()
	if(!isfollower(usr))
		usr << "A banner with a red motif."
	else if(isredfollower(usr))
		usr << "A banner representing our might against the heretics."
	else if(isbluefollower(usr))
		usr << "A heretical banner that should be destroyed posthaste."
	else //sanity
		usr << "A red banner.  Something also broke and you shouldn't be reading this.  Report it to a coder."

/obj/item/weapon/banner/blue
	name = "red banner"
	icon_state = "bannerred"
	item_state = "bannerred"

/obj/item/weapon/banner/blue/examine()
	..()
	if(!isfollower(usr))
		usr << "A banner with a blue motif."
	else if(isredfollower(usr))
		usr << "A heretical banner that should be destroyed posthaste."
	else if(isbluefollower(usr))
		usr << "A banner representing our might against the heretics."
	else //sanity
		usr << "A blue banner.  Something also broke and you shouldn't be reading this.  Report it to a coder."
/*
/obj/item/weapon/banner/grey //for the Grey Crusades
	name = "grey banner"
	icon_state = "bannergrey"
	item_state = "bannergrey"
	desc = "A banner with a toolbox logo, likely assistant-related."

/obj/item/weapon/banner/grey/examine()
	..()
	if(user.mind.role == "Assistant")
		usr << "GREYTIDE STATIONWIDE!!!!"
	else if(user.mind.role == "Security Officer")
		usr << "A horrible banner representing disorder and chaos."
	else
		usr << "A banner with a toolbox logo, likely assistant-related."
*/
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

/obj/item/clothing/shoes/syndigaloshes/examine()
	..()
	if(!isfollower(usr))
		usr << "A pair of unusual boots."
	else
		usr << "Boots that have been blessed to allow one to walk on water. Unfortunately there's no large bodies of water in space, but they do prevent you from slipping, at least."

/obj/item/clothing/glasses/thermal/monocle/hunter
	name = "hunter's eye"
	icon_state = "thermoncle"

/obj/item/clothing/glasses/thermal/monocle/hunter/examine()
	..()
	if(!isfollower(usr))
		usr << "A monocle, but with a red glass."
	else
		usr << "A monocle that seems to let you see someone's 'aura', allowing you to judge where they are, even behind walls!"

/obj/item/weapon/selfhealer
	name = "Amulet of Healing"

/obj/item/weapon/selfhealer/examine()
	..()
	if(!isfollower(usr))
		usr << "A necklace with a blue gem hanging at the end."
	else
		usr << "A necklace that speeds up the natual healing process."

//***high-tier***

/obj/item/weapon/selfhealer/super
	name = "Amulet of Rapid Regeneration"

/obj/item/weapon/selfhealer/super/examine()
	..()
	if(!isfollower(usr))
		usr << "A necklace with a purple gem handing at the end.."
	else
		usr << "This necklace makes you heal fast, and be harder to kill, even while down."

//this is all part of one item set
/obj/item/clothing/suit/armor/plate/crusader
	name = "Crusader's Armor"
	icon_state = "crusader"
	w_class = 4 //bulky
	slowdown = 2.0 //gotta pretend we're balanced.
	armor = list(melee = 70, bullet = 70, laser = 70, energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/plate/crusader/examine()
	..()
	if(!isfollower(usr))
		usr << "Armor that's comprised of metal and cloth."
	else
		usr << "Armor that was used to protect from backstabs, gunshots, explosives, and lasers.  The original wearers of this type of armor were trying to avoid being murdered.  Since they're not around anymore, you're not sure if they were successful or not."

/obj/item/clothing/head/helmet/plate/crusader
	name = "Crusader's Hood"
	icon_state = "crusader"
	w_class = 3 //normal
	flags = BLOCKHAIR
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 70, bullet = 70, laser = 70, energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/plate/examine()
	..()
	if(!isfollower(usr))
		usr << "A brownish hood."
	else
		usr << "A hood that's very protective, despite being made of cloth.  Due to the tendency of the wearer to be targeted for assassinations, being protected from being shot in the face was very important.."

/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	icon_state = "crusader"
	siemens_coefficient = 0 //this protects from shock

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/plate/examine()
	..()
	if(!isfollower(usr))
		usr << "They're like gloves, but made of metal."
	else
		usr << "Protective gloves that are also blessed to protect from heat and shock."

/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	icon_state = "crusader"
	w_class = 3 //normal
//	armor = list(melee = 70, bullet = 70, laser = 70,energy = 40, bomb = 60, bio = 0, rad = 0) //does this even do anything on boots?
	flags = NOSLIP

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/plate/examine()
	..()
	if(!isfollower(usr))
		usr << "Metal boots, they look heavy."
	else
		usr << "Heavy boots that are blessed for sure footing.  You'll be safe from being taken down by the heresy that is the banana peel."

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
	icon_state = "heavy"
	w_class = 4 //bulky
	slowdown = 1.0
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 70, bomb = 80, bio = 100, rad = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/juggernaut/examine()
	..()
	if(!isfollower(usr))
		usr << "A space suit with armor plates on it."
	else
		usr << "A space suit blessed to protect from the elements.  That is, you'll be safe from both space, and extreme heat with this on."

/obj/item/clothing/head/helmet/space/juggernaut
	name = "Juggernaut's Helmet"
	icon_state = "crusader"
	w_class = 3 //normal
	flags = BLOCKHAIR
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 70, bomb = 80, bio = 100, rad = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/juggernaut/examine()
	..()
	if(!isfollower(usr))
		usr << "A space helmet, with metal plating around the head and thick glass."
	else
		usr << "A space helmet that makes you feel unstoppable, at least, to the elements."

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
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullshield"
	force = 13.0
	throwforce = 5.0
	w_class = 4 //bulky
	attack_verb = list("shoved", "bashed")
	reflect_chance = 80

/obj/item/weapon/shield/nullshield/examine()
	..()
	if(!isfollower(usr))
		usr << "An obsidian shield with a glowing rune on it."
	else
		usr << "An obsidian shield with a reflective rune on it.  It protects from projectiles and might send them back at your enemies."

/obj/item/weapon/shield/energy/IsShield()
	return 1

/obj/item/weapon/shield/energy/IsReflect()
	return 1