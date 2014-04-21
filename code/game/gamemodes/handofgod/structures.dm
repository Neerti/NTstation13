/obj/structure/divine/
	name = "I'm an error."
	desc = "Something went wrong if you can see this."
	icon = 'icons/mob/god.dmi'
	anchored = 1
	var/health = 100
	var/maxhealth = 100
	var/side = "neutral" //Which side owns the structure.
	var/heal_rate = 1 //How much health it heals per tick.  Set to zero to disable healing.
	var/mob/camera/god/deity = null

////////////////////////
//Procs for structures//
////////////////////////
/obj/structure/divine/proc/validate_health() //Incase it overheals somehow
	if(health > maxhealth)
		health = maxhealth
		return

/obj/structure/divine/proc/checkhealth() //Checks if we should be dead.
	if(health <= 0)
		visible_message("<span class='danger'>The [src.name] was destroyed!</font>")
		predelete()
		return


/obj/structure/divine/attackby(var/obj/item/weapon/W, var/mob/user) //hot fresh copypasta for all your damage needs
	playsound(src.loc, W.hitsound, 50, 1)
	src.visible_message("<span class='danger'>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]!</span>")
	health -= W.force
	checkhealth()

/obj/structure/divine/bullet_act(var/obj/item/projectile/Proj)
	health -=Proj.damage
	checkhealth()

/obj/structure/divine/attack_animal(mob/living/simple_animal/M as mob)
	src.visible_message("<span class='danger'>The [src.name] has been attacked by \the [M]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage) // Avoid divide by zero errors
		return
	health -= damage
	checkhealth()
	return

/obj/structure/divine/proc/postbuild() // Handles anything we need done post building.
	if(side == "red")
		icon_state += "-r"
	if(side == "blue")
		icon_state += "-b"

/obj/structure/divine/proc/predelete()
	qdel(src)
//////////////
//Structures//
//////////////
/obj/structure/divine/nexus
	name = "Nexus"
	desc = "It anchors a deity to this world.  It radiates an unusual aura.  Cultists protect this at all costs.  It looks well protected from explosive shock."
	icon_state = "nexus"
	health = 500
	maxhealth = 500
	var/point_regen_rate = 1
	var/list/powerpylons = list()

/obj/structure/divine/nexus/ex_act() //Prevent cheesing the round by a shitty scientist
	return
/obj/structure/divine/nexus/checkhealth() //let me know if this can be done better.
	if(deity)
		deity.update_health() //updates the hud
	if(health <= 0)
		if(deity.nexus_required)
			deity << "<span class='danger'>Your nexus was destroyed.  You feel yourself fading...</font>"
			qdel(deity) //Our nexus died, and so does the god.
		visible_message("<span class='danger'>The [src.name] was destroyed!</font>")
		qdel(src)
	return

/obj/structure/divine/nexus/New()
	processing_objects.Add(src)

/obj/structure/divine/nexus/process()
	deity.add_points(point_regen_rate + powerpylons.len)
	if(deity.yourprophet)
		if(deity.yourprophet.stat == 2)
			deity << "You feel a great deal of pain as you feel your prophet leave this world."
			deity.yourprophet = null
			deity.verbs += /mob/camera/god/verb/newprophet
			deity << "You feel your Nexus has become weaker from your prophet's death."
			maxhealth -= 50
	checkhealth()
/obj/structure/divine/conduit
	name = "Conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"
	health = 150
	maxhealth = 150

/obj/structure/divine/forge
	name = "Forge"
	desc = "A forge fueled by divine might, it allows the creation of sacred and powerful artifacts.  It requires common materials to craft objects."
	icon_state = "forge"
	health = 250
	maxhealth = 250

/obj/structure/divine/convertaltar //todo: make desc reflect the god's name.
	name = "Conversion Altar"
	desc = "An altar dedicated to a deity.  Cultists can \"forcefully teach\" their non-aligned crewmembers to join their side and take up their deity."
	icon_state = "convertaltar"

	attack_hand(mob/living/user as mob)
		var/mob/living/carbon/human/H = locate(/mob/living/carbon) in loc
		if(!isfollower(user)) //Is the user a follower?
			user << "<span class='notice'>You can't seem to do anything useful with this.</span>"
			return
		if(!H || !H.mind)
			user << "<span class='danger'>Nobody sentient is on top of the alter, if anything at all.</span>"
			return
		if(src.side == ("red")) //Is the altar red?
			if(isredfollower(user))
				user << "<span class='notice'>You invoke the conversion ritual.</span>"
				ticker.mode.add_red_follower(H.mind)
				return
			return
		else if(src.side == ("blue")) //Or blue?
			if(isbluefollower(user))
				user <<"<span class='notice'>You inoke the conversion ritual.</span>"
				ticker.mode.add_blue_follower(H.mind)
				return
			return
		else //Or maybe something went wrong.
			user << "Something went wrong when the altar was made, and is unaligned.  You should adminhelp this."

/obj/structure/divine/sacrificealtar
	name = "Sacrifical Altar"
	desc = "An altar designed to perform blood sacrifice for a deity.  The cultists performing the sacrifice will gain a powerful material to use in their forge.  Sacrificing a prophet will yield even better results."
	icon_state = "sacrificealtar"

/obj/structure/divine/puddle
	name = "Puddle of Healing"
	desc = "Cultists standing close to this blessed puddle will be healed."
	icon_state = "puddle"
	health = 50
	maxhealth = 50

/obj/structure/divine/gate
	name = "Gateway"
	desc = "A portal kept stable, it allows cultists to move to any other gateway they control."
	icon_state = "gate"
	health = 50
	maxhealth = 50

/obj/structure/divine/powerpylon
	name = "Power Pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	icon_state = "powerpylon"
	health = 30
	maxhealth = 30

/obj/structure/divine/powerpylon/postbuild()
	..()
	deity.god_nexus.powerpylons.Add(src)

/obj/structure/divine/powerpylon/predelete()
	deity.god_nexus.powerpylons.Remove(src)
	..()
/obj/structure/divine/defensepylon
	name = "Defense Pylon"
	desc = "A plyon which is blessed to withstand many blows, and fire strong bolts at nonbelivers."
	icon_state = "defensepylon"
	health = 150
	maxhealth = 150

/obj/structure/divine/shrine
	name = "Shrine to " //todo: add name of god here.
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"

/obj/structure/divine/shrine/postbuild()
	..()
	var/tempname = name
	name = "[tempname][deity.name]"
	deity.max_god_points += 50

/obj/structure/divine/shrine/predelete()
	deity.max_god_points -= 50
	..()

/obj/structure/divine/holder //used for building the structures.
	name = "I'm an error." //Name is replaced by the object being built.
	desc = "My description is broken, report me to a coder." //ditto, also tells what is needed to finish.
	icon_state = null //ditto
	health = 20
	maxhealth = 20
	var/project = null //What is being built.  Determines what to spawn after construction is finished.