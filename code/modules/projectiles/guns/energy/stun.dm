/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	desc_info = "This is used to stun people at a distance.  You get five shots with this one."
	desc_fluff = "This stun gun has become the standard in Nanotrasen security teams due to it being very cheap to produce, while being effective (as long as you don't miss)."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "An integrated taser that draws directly from a cyborg's power cell. Used by security cyborgs and defense turrets to subdue humanoids at range. Integrated into the weapon is a limiter to prevent the cyborg's power cell from overheating."
	desc_info = "This taser works like a normal one, except for the fact that it will recharge on it's own as long as you have it out."
	desc_fluff = "A modified taser gun with the powercell removed.  A series of wires runs out of where the powercell would be, presumably transfering power from an external cell to the gun."
	fire_sound = 'sound/weapons/Taser.ogg'
	icon_state = "taser"
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()

	process() //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(!power_supply) return 0 //sanity
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
				if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
					power_supply.give(shot.e_cost)	//... to recharge the shot

		update_icon()
		return 1


/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires disposable, compressed stun cartidges. The stun cartridges can be recharged using a conventional energy weapon recharger and their compact size allows for more shots over the standard taser before the cell needs recharging."
	desc_info = "An upgrade to the taser, this is more efficent, resulting in more shots before recharging."
	desc_fluff = "Originally, the designer of this weapon intended for it to work like a normal revolver, firing specialized shells that would deliver an electric shock.\
	Due to the ammo being both expensive and a pain to reload, the designer decided to switch to rechargable stun cartidges."
	icon_state = "stunrevolver"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/gun)
	cell_type = "/obj/item/weapon/stock_parts/cell"



/obj/item/weapon/gun/energy/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by many syndicate stealth specialists."
	desc_info = "This will stun a person and inflict minor toxin damage.  It will recharge itself slowly."
	icon_state = "crossbow"
	w_class = 2.0
	item_state = "crossbow"
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
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
		return 1


	update_icon()
		return

/obj/item/weapon/gun/energy/crossbow/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "energy crossbow"
	desc = "A reverse-engineered energy crossbow with a bulky frame."
	icon_state = "crossbow_large"
	w_class = 4.0
	item_state = "crossbow_large"
	force = 10
	m_amt = 200000
