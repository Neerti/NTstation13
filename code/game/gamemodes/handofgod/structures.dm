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
	else if(istype(M, /mob/living/carbon/alien/humanoid/queen))
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
	deity.add_points(point_regen_rate + (powerpylons.len / 5))//todo: add follower to equation
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

/obj/structure/divine/forge //uses Razharas's crafting system which can be found in code/datums/crafting.dm
	name = "Forge"
	desc = "A forge fueled by divine might, it allows the creation of sacred and powerful artifacts.  It requires common materials to craft objects."
	icon_state = "forge"
	health = 250
	maxhealth = 250
	density = 0

/obj/structure/divine/forge/New()

	craft_holder = new /datum/crafting_holder(src, "forge")


/obj/structure/divine/forge/attack_hand()
	if(isfollower(usr))
		craft_holder.interact(usr)
	else
		usr << "<span class='notice'>You can't seem to do anything useful with this.</span>"

/obj/structure/divine/convertaltar //Made by based sawu.
	name = "Conversion Altar"
	desc = "An altar dedicated to a deity.  Cultists can \"forcefully teach\" their non-aligned crewmembers to join their side and take up their deity."
	icon_state = "convertaltar"

	attack_hand(mob/living/user as mob)
		var/mob/living/carbon/human/H = locate(/mob/living/carbon) in loc
		if(!isfollower(user)) //Is the user a follower?
			user << "<span class='notice'>You can't seem to do anything useful with this.</span>"
			return
		if(!H || !H.mind) //If nothing is on top of the alter, or the mob has no mind, stop the proc.
			user << "<span class='danger'>Nobody sentient is on top of the altar, if anything at all.</span>"
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

/obj/structure/divine/healingfountain
	name = "Healing Fountain"
	desc = "It's a fountain with special water."
	icon_state = "fountain"
	health = 50
	maxhealth = 50
	density = 1

	var/on_cooldown = 0
	var/timeleft = 0
	var/last_process = 0

	attack_hand(mob/living/user as mob)
		if(on_cooldown == 1)
			user << "<span class='notice'>The fountain appears to be empty.</span>"
			return
		if(!isfollower(user))
			user << "<span class='danger'><b>The water burns!</b></span>"
			user.reagents.add_reagent("pacid", 20)
			icon_state = "fountain-dry"
			on_cooldown = 1
			timeleft = 2000
			processing_objects.Add(src)
			last_process = world.time
		else
			user << "<span class='notice'>The water feels warm and soothing as you touch it.  The fountian immediately dries up shortly afterwards.</span>"
			user.reagents.add_reagent("doctorsdelight", 20)
			icon_state = "fountain-dry"
			on_cooldown = 1
			timeleft = 2000
			processing_objects.Add(src)
			last_process = world.time

/obj/structure/divine/healingfountain/process()
	timeleft -= (world.time - last_process)
	if(timeleft <= 0)
		src.on_cooldown = 0
		icon_state = "fountain"
		processing_objects.Remove(src)

/obj/structure/divine/gate
	name = "Gateway"
	desc = "A portal kept stable, it allows someone to go to any other gate of the same alignment."
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

/obj/structure/divine/defensepylon //pretty much entirely made by based wb.
	name = "Defense Pylon"
	desc = "A plyon which is blessed to withstand many blows, and fire strong bolts at nonbelivers."
	icon_state = "defensepylon"
	health = 150
	maxhealth = 150
	density = 1

	var/targeting_delay = 20
	var/shot_delay = 20 //2 seconds between shots
	var/mob/living/current_target = null //what the pylon is shooting right now.
	var/scan_range = 7 //used for target validation.
/obj/structure/divine/defensepylon/New()
	spawn() src.targeting_ticker_loop() //Any proc with sleeps should be set off with spawn() -wb
	return
/obj/structure/divine/defensepylon/proc/targeting_ticker_loop()
	while(!src.gc_destroyed)
		if(src.standard_target_scan() \
		|| src.hidden_target_scan() \
		|| src.mecha_scan())
			return
//		world << "Didn't find a target."
		sleep(src.targeting_delay)
	return

/obj/structure/divine/defensepylon/proc/standard_target_scan()
	for(var/mob/M in (oviewers(src.scan_range,src)))
		if(!src.validate_target(M)) continue
		spawn() src.engage_target(M)
		return 1
	return

/obj/structure/divine/defensepylon/proc/hidden_target_scan()
	for(var/mob/M in player_list)
		if(!src.validate_target(M))
			continue
		if(!((get_turf(M)) in (oview(scan_range,src))))
			continue
		src.engage_target(M)
		return 1
	return

/obj/structure/divine/defensepylon/proc/mecha_scan()
	for(var/obj/mecha/M in mechas_list)
		if(!M.occupant)
			continue
		if(!src.validate_target(M.occupant))
			continue
		if(!((get_turf(M)) in (oview(scan_range,src))))
			continue
		src.engage_target(M.occupant)
		return 1
	return

/obj/structure/divine/defensepylon/proc/engage_target(mob/M)
	src.current_target = M
//	world << "Found a valid target ([M]). Engaging."
	src.shoot_target(M)
	return

/obj/structure/divine/defensepylon/proc/validate_target(mob/living/target)
	if(target.stat)
//		world << "[target.name]'s stat was [target.stat] so it was invalid."
		return 0
	if(src.side == "red" && isredfollower(target))
//		world << "[target.name] was on red and so am I. Invalid."
		return 0
	if(src.side == "blue" && isbluefollower(target))
//		world << "[target.name] was on blue, and so am I. Invalid."
		return 0
//	world << "validate_target() passed."
	return 1

/obj/structure/divine/defensepylon/proc/check_current_target()
	if((src.current_target) \
	&& (!src.current_target.stat) \
	&& ((get_turf(src.current_target)) in (oview(scan_range,src)))) \
		return 1
	return

/obj/structure/divine/defensepylon/proc/shoot_target()
	while(!src.gc_destroyed)
		if(!src.check_current_target())
//			world << "target became invalid"
			break
//		world << "I shoot at [src.current_target.name]."
		src.icon_state = "defensepylonattack"
		src.postbuild()
		playsound(src, 'sound/weapons/pulse3.ogg', 50, 1)
		src.shoot_projectile()
		sleep(shot_delay)
//	world << "lost valid target"
	src.icon_state = "defensepylon"
	src.postbuild()
	src.current_target = null
	src.targeting_ticker_loop()
	return

/obj/structure/divine/defensepylon/proc/shoot_projectile()
//	world << "firing projectile"
	var/turf/curloc = get_turf(src)//more copypasta
	var/turf/targloc = get_turf(current_target)
	var/obj/item/projectile/A = new /obj/item/projectile/pylon_bolt(curloc)
	if(src.side == "blue")
		A.icon_state = "pulse1_bl"
	A.current = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	spawn(0)
		A.process()
	return

/*
FUCK THIS CODE DOWN HERE
/obj/structure/divine/defensepylon/New(loc)
	var/obj/effect/step_trigger/pylon_target/A = new(loc)
	my_fake_area = A
	A.my_pylon = src
	A.x -= 7
	A.y -= 7
	..()

/obj/structure/divine/defensepylon/proc/engage() //only fires when a mob enters the fake area.  ends when target list is empty.
	do
		engaging = 1
		fire()
//		world << "I'm going to robust [current_target.name]."
		sleep(shot_delay)
	while(potential_targets.len > 0) //stop running if the list is empty
	current_target = null
	engaging = 0

/obj/structure/divine/defensepylon/proc/get_target()
	if(!potential_targets || potential_targets.len == 0) //runtime prevention
		return
	current_target = pick(oviewers()) //this runtimes

/*	for(var/i in oviewers)
		if (istype(i,mob)) newlist+=i
	var/rng = pick(newlist)
	current_target = rng
*/
//	for(mobs in oviewers)


/*	var/rng = null
	var/possible_targets = potential_targets
	rng = pick(possible_targets)
	if(!(rng in view(src.loc)))
		rng -= possible_targets
	current_target = rng
*/
/obj/structure/divine/defensepylon/proc/fire()
	if(validate(current_target))
//		world << "[current_target] is a valid kill." //debug
		src.dir = get_dir(src,current_target) //point at our target
		if(!src) //more sanity
			return
		var/turf/curloc = get_turf(src)//more copypasta
		var/turf/targloc = get_turf(current_target)
		if(!targloc || !curloc)
			return
		if(targloc == curloc)
			return
		playsound(src, 'sound/weapons/pulse3.ogg', 50, 1)
		var/obj/item/projectile/A = new /obj/item/projectile/pylon_bolt(curloc)
		if(src.side == "blue")
			A.icon_state = "pulse1_bl"
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		spawn(0)
			A.process()
		return
	else
		current_target = null
		get_target()

/obj/structure/divine/defensepylon/proc/validate(atom/target) //taken from gun turret code
	if(get_dist(target, src)>scan_range)
		potential_targets -= current_target
		return 0 //too far, not valid, get them out of the list
	if(!(target in view(src.loc))) //can we see them?
		world << "I CAN'T SEE SHIT!"
		return 0
	if(istype(target, /mob))
		var/mob/M = target
		if(!M.stat)
			return 1 //mobs are valid
	else if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		if(M.occupant)
			return 1 //mechs with a person inside are valid.
	else
//		potential_targets -= current_target
		return 0

/obj/effect/step_trigger/pylon_target //creates a pseudo-area for a pylon to use to determine a target.
	affect_ghosts = 0
	invisibility = 0 //debug
	icon = 'icons/turf/areas.dmi' //debug
	icon_state = "red"
	bounds = "480,480" //15x15 tiles
	var/obj/structure/divine/defensepylon/my_pylon = null //to make sure different pylons don't share the same targeting area.

	Crossed(var/atom/A)
		..()
		if(!A) //sanity
			return
		if(istype(A, /mob/dead/observer)) //ghosts don't trigger it.
			return
//		world << "Something crossed me!"
		if(!my_pylon) //sanity
//			world << "I don't have a pylon."
			return
		if(istype(A, /mob/living)) //don't add non-mobs to the pylon's list
			if(my_pylon.side == "red")
				if(!isredfollower(A)) //do not add red followers to a red pylon's target list
//					world << "I've added [A.name] to my pylon's list of targets."
					my_pylon.potential_targets |= A
					if(my_pylon.engaging == 0) //don't engage if already engaging.
						my_pylon.engage()
					return
			else if(my_pylon.side == "blue")
				if(!isbluefollower(A))
//					world << "I've added [A.name] to my pylon's list of targets."
					my_pylon.potential_targets |= A
					if(my_pylon.engaging == 0)
						my_pylon.engage()
					return
			else
				world << "A pylon has no assigned side, which is a bug."
				return

	Uncrossed(var/atom/A)
		..()
		if(!A) //sanity
			return
		if(istype(A, /mob/dead/observer)) //ghosts don't trigger it.
			return
//		world << "Something moved out of me!"
		if(!my_pylon) //sanity
//			world << "I don't have a pylon."
			return
		if(istype(A, /mob/living)) //don't add non-mobs to the pylon's list
//			world << "I've removed [A.name] to my pylon's list of targets."
			my_pylon.potential_targets -= A
			return

	/obj/effect/step_trigger/pylon_target/Move() //prevent singulo from dragging it.
		return 0
*/
/obj/structure/divine/shrine
	name = "Shrine to " //todo: add name of god here.
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"
	density = 1

/obj/structure/divine/shrine/postbuild()
	..()
	var/tempname = name
	name = "[tempname][deity.name]"
//	deity.max_god_points += 50 //goofball pls don't add stuff w/o asking me -neerti

/obj/structure/divine/shrine/predelete()
//	deity.max_god_points -= 50
	..()

//**Tier 2 structures**
//Requires a greater gem to build.

/obj/structure/divine/translocator
	name = "Nexus Translocator"
	desc = "A powerful structure, made with a greater gem.  It allows a deity to move their nexus to where this stands.  It may only move once, however."
	icon_state = "translocator"
	health = 100
	maxhealth = 100
	density = 1

/obj/structure/divine/lazarusaltar
	name = "Lazarus Altar"
	desc = "A very powerful altar capable of bringing life back to the recently deceased, made with a greater gem.  It can revive anyone and will heal virtually all wounds, but they will not come back at full strength."
	icon_state = "lazarusaltar"
	health = 100
	maxhealth = 100
	density = 0

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
				user << "<span class='notice'>You attempt to raise [H.name].</span>"
				H.revive()
				H.adjustCloneLoss(50) //They're stick with half health to balance instant revival.
				H.adjustStaminaLoss(100)
				return
			else
				user << "<span class='danger'>You can only use your own team's altars!</span>"
			return
		else if(src.side == ("blue")) //Or blue?
			if(isbluefollower(user))
				user <<"<span class='notice'>You attempt to raise [H.name].</span>"
				H.revive()
				H.adjustCloneLoss(50)
				H.adjustStaminaLoss(100)
				return
			else
				user << "<span class='danger'>You can only use your own team's altars!</span>"
			return
		else //Or maybe something went wrong.
			user << "Something went wrong when the altar was made, and is unaligned.  You should adminhelp this."

//**Traps**

/obj/structure/divine/trap
	name = "IT'S A TARP"
	desc = "You shouldn't be reading this."
	icon_state = "trap"
	density = 1
	alpha = 30
	health = 20
	maxhealth = 20
	var/triggered = 0
	var/timeleft = 0
	var/last_process = 0

/obj/structure/divine/trap/Crossed(AM as mob)
	Bumped(AM)

/obj/structure/divine/trap/Bumped(mob/M as mob)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<span class='danger'>[M] triggered the [src]</span>"
		triggered = 1

/obj/structure/divine/trap/examine()
	..()
	if(isliving(usr)) //prevent ghosts from revealing.
		usr << "Trap detected and is now visible."
		alpha = 200
		timeleft = 2000 //about a minute
		last_process = world.time
		processing_objects.Add(src)
	else
		return

/obj/structure/divine/trap/process()
	timeleft -= (world.time - last_process)
	if(timeleft <= 0)
		processing_objects.Remove(src)
		src.alpha = 30

/obj/structure/divine/trap/stun
	name = "shock trap"
	desc = "A trap that will shock you, making you unable to move and being really painful.  You'd better avoid it."
	icon_state = "trap-shock"

/obj/structure/divine/trap/stun/Bumped(mob/living/M as mob)
	..()
	if(ismob(M)) //to prevent runtimes
		M << "<span class='danger'><b>You are paralyzed from the intense shock!</b></span>"
		M.Weaken(5)
		new /obj/effect/effect/sparks/electricity(M.loc)
		new /obj/effect/effect/sparks(src.loc)
		qdel(src)

/obj/structure/divine/trap/fire
	name = "flame trap"
	desc = "A trap that will light you on fire.  You'd better avoid it."
	icon_state = "trap-fire"

/obj/structure/divine/trap/fire/Bumped(mob/living/M as mob)
	..()
	if(ismob(M)) //to prevent runtimes
		M << "<span class='danger'><b>You burn!</b></span>"
		M.Weaken(1)
		new /obj/effect/hotspot(M.loc)
		new /obj/effect/effect/sparks(src.loc)
		qdel(src)

/obj/structure/divine/trap/chill
	name = "frost trap"
	desc = "A trap that will chill you to the bone.  You'd better avoid it."
	icon_state = "trap-frost"

/obj/structure/divine/trap/chill/Bumped(mob/living/M as mob)
	..()
	if(ismob(M)) //to prevent runtimes
		M << "<span class='danger'><b>You feel really cold!</b></span>"
		M.Weaken(1)
		if(ishuman(M)) //so it doesn't runtime if a borg runs into it.
			M.bodytemperature -= 300
		new /obj/effect/effect/sparks(src.loc)
		qdel(src)

/obj/structure/divine/trap/damage
	name = "earth trap"
	desc = "A trap that will impale you with sharp rocks.  You'd better avoid it."
	icon_state = "trap-earth"

/obj/structure/divine/trap/damage/Bumped(mob/living/M as mob)
	..()
	if(ismob(M)) //to prevent runtimes
		M << "<span class='danger'><b>Sharp rocks impale you from below!</b></span>"
		M.Weaken(1)
		M.adjustBruteLoss(35)
		new /obj/effect/effect/sparks(src.loc)
		qdel(src)

//**Temporary structures**

/obj/structure/divine/ward
	name = "Divine Ward"
	desc = "It's a barrier that appeared seemingly from nowhere.  It looks like you could destroy it with enough effort, or just wait for it to go away."
	icon_state = "ward"
	health = 80
	maxhealth = 80
	density = 1

	var/timeleft = 3000
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

//**Other**

/obj/structure/divine/holder //used for building the structures.
	name = "I'm an error" //Name is replaced by the object being built.
	desc = "My description is broken, report me to a coder." //ditto, also tells what is needed to finish.
	icon_state = null //ditto
	alpha = 100 //To show it's a holder and not the actual structure.
	health = 20
	maxhealth = 20

	var/project = null //What is being built.  Determines what to spawn after construction is finished.
	var/metal_cost = null //How much metal is needed to build
	var/glass_cost = null //ditto
	var/greater_gem_cost = null
	var/metal_complete = 0
	var/glass_complete = 0
	var/greater_gem_complete = 0

/obj/structure/divine/holder/attackby(obj/item/stack/W, mob/user)
	if(isnull(metal_cost))
		metal_complete = 1
	if(isnull(glass_cost))
		glass_complete = 1
	if(isnull(greater_gem_cost))
		greater_gem_complete = 1
	if(istype(W, /obj/item/stack/sheet/metal))
		if(metal_complete == 1)
			user << "You don't need to add anymore metal!"
			return
		if(W.amount < metal_cost)
			user << "You need [metal_cost] sheets of metal to complete this."
		else
			var/obj/item/stack/sheet/metal/pile = W
			pile.use(metal_cost)
			user << "You use your metal sheets to construct the [name]."
			src.metal_complete = 1
	if(istype(W, /obj/item/stack/sheet/glass))
		if(glass_complete == 1)
			user << "You don't need to add anymore glass!"
			return
		if(W.amount < glass_cost)
			user << "You need [glass_cost] sheets of glass to complete this."
		else
			var/obj/item/stack/sheet/glass/pile = W
			pile.use(glass_cost)
			user << "You use your glass sheets to construct the [name]."
			src.glass_complete = 1
	if(istype(W, /obj/item/stack/sheet/greatergem))
		if(greater_gem_complete == 1)
			user << "You don't need to add anymore greater gems!"
			return
		if(W.amount < greater_gem_cost)
			user << "You need [greater_gem_cost] greater gem to complete this."
		else
			var/obj/item/stack/sheet/greatergem/pile = W
			pile.use(greater_gem_cost)
			user << "You use your greater gem to construct the [name]."
			src.greater_gem_complete = 1
	if(metal_complete && glass_complete && greater_gem_complete == 1)
		var/obj/structure/divine/S = new project(loc)
		S.side = src.side
		S.postbuild()
		qdel(src)
	return
	..()