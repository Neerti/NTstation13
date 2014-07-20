/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "An energy-based laser gun that uses normal energy cells to fire concentrated beams of light that pass through glass and thin metal."
	desc_info = "This gun can only fire lasers."
	icon_state = "laser"
	item_state = "laser"
	w_class = 3.0
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)


/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	desc_info = "This 'weapon' cannot harm anyone."
	desc_fluff = "The focusing lens appears a bit dusty, and the actual laser has been modified to fire less potent bolts.  Unfortately, the modification can't be undone."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0

obj/item/weapon/gun/energy/laser/retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	desc_info = "This works just like the normal laser gun."
	desc_fluff = "This model fell out of favor in the last few years due to the manufacturing cost, being out-phased with the equally powerful current laser gun."

/obj/item/weapon/gun/energy/laser/captain
	icon_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	desc_info = "This gun can only fire lasers.  It self-recharges."
	desc_fluff = "Most Captains are expected to own an antique in order to be regarded as prestigious among the other command staff.  A common choice is a gun, as it's both valuable and practical."
	force = 10
	origin_tech = null
	var/charge_tick = 0


	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1

/obj/item/weapon/gun/energy/laser/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	desc_info = "This will use about one hundred units of charge per shot."
	desc_fluff = "This laser has a wire running from where the power cell would be, to the cyborg's internal powercell.\
	  Advanced cooling technologies allow continious fire without having to recharge, as long as the demand for energy is met."

/obj/item/weapon/gun/energy/laser/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/weapon/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	desc_info = "This laser can fire 'spread bolts', like a shotgun."
	desc_fluff = "This laser's lens was swapped with a refractive lens, causing light to spread and potentially wound multiple targets at great efficency."
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)

	attack_self(mob/living/user as mob)
		select_fire(user)
		update_icon()


/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "A heavier, experimental version of the common laser gun. The concentrated light is fired through a housing lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with less energy charge!"
	desc_info = "This laser does twice the damage of a normal one."
	icon_state = "lasercannon"
	item_state = "laser"
	origin_tech = "combat=4;materials=3;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/heavy)


/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts that pass through multiple soft targets and heavier materials."
	desc_info = "This bolt pierces all mobs and certain structures."
	icon_state = "xray"
	item_state = "laser"
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)


////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless beams of light. Sound effects included!"
	desc_info = "Requires wearing a laser tag vest to fire."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0
	var/charge_tick = 0

	special_check(var/mob/living/carbon/human/M)
		if(ishuman(M))
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				return 1
			M << "\red You need to be wearing your laser tag vest!"
		return 0

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1



/obj/item/weapon/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams of light. Sound effects included!"
	desc_info = "Requires wearing a laser tag vest to fire."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0
	var/charge_tick = 0

	special_check(var/mob/living/carbon/human/M)
		if(ishuman(M))
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				return 1
			M << "\red You need to be wearing your laser tag vest!"
		return 0

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1