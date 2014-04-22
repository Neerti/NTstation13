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

/obj/structure/divine/sacrificealtar/proc/sacrifice() //Checks to see what we get when we sac someone.
	var/mob/living/M = locate(/mob/living/) in loc
	if(ismonkey(M)) //monkeys aren't special
		var/luck = rand(1,4)
		if(luck == 1)
			new /obj/item/stack/sheet/lessergem(src.loc)
	else if(isprophet(M)) //enemy prophets are very special
		new /obj/item/stack/sheet/greatergem(src.loc)
	else if(isAI(M)) //Good luck
		new /obj/item/stack/sheet/greatergem(src.loc)
	else //everything else gets a lesser gem
		new /obj/item/stack/sheet/lessergem(src.loc)
	M.gib()
	return


//////////////
//Structures//
//////////////
/obj/structure/divine/nexus
	name = "Nexus"
	desc = "It anchors a deity to this world.  It radiates an unusual aura.  Cultists protect this at all costs.  It looks well protected from explosive shock."
	icon_state = "nexus"
	health = 500
	maxhealth = 500
	density = 1
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
	density = 1

/obj/structure/divine/forge
	name = "Forge"
	desc = "A forge fueled by divine might, it allows the creation of sacred and powerful artifacts.  It requires common materials to craft objects."
	icon_state = "forge"
	health = 250
	maxhealth = 250
	density = 1

/obj/structure/divine/convertaltar //todo: make desc reflect the god's name.
	name = "Conversion Altar"
	desc = "An altar dedicated to a deity.  Cultists can \"forcefully teach\" their non-aligned crewmembers to join their side and take up their deity."
	icon_state = "convertaltar"

	attack_hand(mob/living/user as mob)
		var/mob/living/carbon/human/H = locate(/mob/living/carbon) in loc
		if(!isfollower(user)) //Is the user a follower?
			user << "<span class='notice'>You can't seem to do anything useful with this.</span>"
			return
		if(!H || !H.mind) //If nothing is on top of the alter, or the mob has no mind, stop the proc.
			user << "<span class='danger'>Nobody sentient is on top of the alter, if anything at all.</span>"
			return
		if(src.side == ("red")) //Is the altar red?
			if(isredfollower(user))//Is a red follower using it?
				user << "<span class='notice'>You invoke the conversion ritual.</span>"
				ticker.mode.add_red_follower(H.mind)
				return
			return
		else if(src.side == ("blue")) //Or blue?
			if(isbluefollower(user))
				user <<"<span class='notice'>You invoke the conversion ritual.</span>"
				ticker.mode.add_blue_follower(H.mind)
				return
			return
		else //Or maybe something went wrong.
			user << "Something went wrong when the altar was made, and is unaligned.  You should adminhelp this."

/obj/structure/divine/sacrificealtar
	name = "Sacrifical Altar"
	desc = "An altar designed to perform blood sacrifice for a deity.  The cultists performing the sacrifice will gain a powerful material to use in their forge.  Sacrificing a prophet will yield even better results."
	icon_state = "sacrificealtar"

	attack_hand(mob/living/user as mob)
		var/mob/living/H = locate(/mob/living/) in loc
		if(!isfollower(user))
			user << "<span class='notice'>You can't seem to do anything useful with this.</span>"
			return
		if(!H) //If nothing is on top of the alter, do nothing
			user << "<span class='danger'>Nobody is on the altar.</span>"
			return
		if(src.side == ("red")) //Is the altar red?
			if(isredfollower(user))//Is a red follower using it?
				if(isredfollower(H))//Prevent sacrificing friendlies.
					user << "<span class='danger'>Your deity wouldn't like sacrificing a fellow follower.</span>"
					return
				user << "<span class='notice'>You attempt to sacrifice [H.name].</span>"
				sacrifice()
				return
			else
				user << "<span class='danger'>You can only use your own team's altars!</span>"
			return
		else if(src.side == ("blue")) //Or blue?
			if(isbluefollower(user))
				if(isbluefollower(H))
					user << "<span class='danger'>Your deity wouldn't like sacrificing a fellow follower.</span>"
					return
				user <<"<span class='notice'>You attempt to sacrifice [H.name].</span>"
				sacrifice()
				return
			else
				user << "<span class='danger'>You can only use your own team's altars!</span>"
			return
		else //Or maybe something went wrong.
			user << "Something went wrong when the altar was made, and is unaligned.  You should adminhelp this."

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
	density = 1

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
	density = 1

/obj/structure/divine/shrine
	name = "Shrine to " //todo: add name of god here.
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"
	density = 1

/obj/structure/divine/shrine/postbuild()
	..()
	var/tempname = name
	name = "[tempname][deity.name]"
	deity.max_god_points += 50

/obj/structure/divine/shrine/predelete()
	deity.max_god_points -= 50
	..()

/obj/structure/divine/ward
	name = "Divine Ward"
	desc = "It's a barrier that appeared seemingly from nowhere.  It looks like you could destroy it with enough effort, or just wait for it to go away."
	icon_state = "ward"
	health = 80
	maxhealth = 80
	density = 1

	var/timeleft = 600
	var/last_process = 0

/obj/structure/divine/ward/New()
	..()
	last_process = world.time
	processing_objects.Add(src)

/obj/structure/divine/ward/process()
	timeleft -= (world.time - last_process)
	if(timeleft <= 0)
		processing_objects.Remove(src)
		qdel(src)

/obj/structure/divine/holder //used for building the structures.
	name = "I'm an error." //Name is replaced by the object being built.
	desc = "My description is broken, report me to a coder." //ditto, also tells what is needed to finish.
	icon_state = null //ditto
	alpha = 100 //To show it's a holder and not the actual structure.
	health = 20
	maxhealth = 20
	var/project = null //What is being built.  Determines what to spawn after construction is finished.