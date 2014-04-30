//This is where all the items made by the forge go.
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

/obj/item/clothing/shoes/waterwalker
	name = "waterwalker boots"
	icon_state = "cult" //placeholder
	desc = "Boots rumored to let the wearer walk on water.  Unfortunately there's no large bodies of water in space, but they do prevent you from slipping, at least."
	flags = NOSLIP