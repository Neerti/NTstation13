/mob/camera/god/proc/powerc(X, Y)//X is the cost, Y is only used for buildings
	if(X && get_god_points() < X)
		src << "<span class='danger'>You lack the faith points needed to do this.</font>"
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space))) //no building in space.
		src << "<span class='danger'>Your structure would just float away, it needs to be on stable ground.</font>"
		return 0
	else if(Y &&(istype(src.loc, /obj/structure))) //no stacking structures.
		src << "<span class='danger'>There is another structure there.  Select an empty spot for your structure.</span>"
		return 0
	else
		return 1

/mob/camera/god/verb/returntonexus()
	set category = "God Powers"
	set name = "Goto Nexus"
	set desc = "Teleports you to your nexus instantly."

	if(god_nexus)
		src.loc = god_nexus.loc
	else
		src << "You don't have a Nexus yet. Build one first."

/mob/camera/god/verb/newprophet()
	set category = "God Powers"
	set name = "Appoint Prophet (100)"
	var/choice_red
	var/choice_blue
	if(!powerc(100))
		src << "You don't have enough power to make a prophet yet."
		return
	if(src.side == "red")
		if(ticker.mode.red_prophets.len >= 1)
			src << "You can only have one prophet alive at a time."
		else
			choice_red = input("Choose a follower to make into your prophet","Prophet Creation") as null|anything in ticker.mode.red_followers
	else if (src.side == "blue")
		if(ticker.mode.blue_prophets.len >= 1)
			src << "You can only have one prophet alive at a time."
		else
			choice_blue = input("Choose a follower to make into your prophet","Prophet Creation") as null|anything in ticker.mode.blue_followers
	else
		src << "You appear to be unaligned, and cannot have any followers, nor prophets."
		return
//	var/choice = input("Choose who you wish to make your prophet","Prophet Creation") as null|anything in followers
	if(choice_red)
		var/mob/living/carbon/human/B = choice_red
		src << "You choose [B] as your prophet."
//		B.deity = src
//		B.prophet = 1
		ticker.mode.red_prophets += B
		ticker.mode.red_followers -= B
		ticker.mode.update_all_red_follower_icons(B)
		B << "Rejoice, for ye have been chosen to be thy generous god, [src]'s prophet!"
//		yourprophet = B
		src.add_points(-100)
		return
	if(choice_blue)
		var/mob/living/carbon/human/B = choice_blue
		src << "You choose [B] as your prophet."
//		B.deity = src
//		B.prophet = 1
		ticker.mode.blue_prophets += B
		ticker.mode.blue_followers -= B
		ticker.mode.update_all_blue_follower_icons(B)
		B << "Rejoice, for ye have been chosen to be thy generous god, [src]'s prophet!"
//		yourprophet = B
		src.add_points(-100)
		return

/mob/camera/god/verb/talk(msg as text)
	set category = "God Powers"
	set name = "Talk to Anyone (20)"
	set desc = "Allows you to send a message to anyone."
	if(!powerc(20))
		src << "You don't have enough power for this."
		return
	var/choice = input("Choose who you wish to talk to","Talk to Anyone") as null|anything in mob_list
	if(choice)
		var/tempmsg = msg
		msg = "\bold You hear a voice coming from everywhere and nowhere... \italic [tempmsg]"
		choice << msg
		src << "You say the following to [choice], [tempmsg]"
		src.add_points(-20)

/mob/camera/god/verb/smite()
	set category = "God Powers"
	set name = "Smite (40)"
	set desc = "Hits anything under you with a moderate amount of damage."

	if(!powerc(40))
		src << "You don't have enough power to do that."
		return
	for(var/mob/living/carbon/human/M in src.loc)
		var/mob/living/carbon/human/H = M
		switch(src.name)
			if("Atheism" || "Fedora" || "Hipster")
				src << "You tip your fedora at [H]."
			if("Woody" || "Andy")
				src << "You read your book to [H]."
			if("Zeus")
				src << "You strike [H] with a bolt of lightning!"
			if("Linda" || "Master Controller" || "Byond")
				src << "You lag [H], causing damage."
			if("Lord Singuloth" || "Nar'sie")
				src << "You consume a bit of [H]."
			if("Chaos")
				src << "You roll a one and make [H] get hurt.  Again."
			if("O'telbra Volema" || "Badmin" || "Admin" || "Xom")
				src << "You badmin [H], hurting them."
			if("Cuban Pete")
				src << "You make [H]'s insides explode... just a bit."
			if("Honkmother")
				src << "You HONK [H]!"
			if("Ian")
				src << "You nuzzle [H].  It hurts them!"
			else
				src << "You smite [H] with your godly powers!"
		H.adjustFireLoss(10)
		H.adjustBruteLoss(10)
		H << "<span class='danger'><b>You feel a sense of horrifying agony as you are harmed by an unseen force!</b></span>"
	src.add_points(-40)

/mob/camera/god/verb/holyword()
	set category = "God Powers"
	set name = "Holy Word (20)"
	set desc = "Knocks out the mortal below you for a brief amount of time."

	if(!powerc(20))
		src << "You don't have enough power to do that."
		return
	for(var/mob/living/L in src.loc)
		var/mob/living/T = L
		src << "You whisper a word most holy to [T].  Moments later they faint!"
		T.Paralyse(2)
		T << "<span class='danger'><b>You hear something incomprehensible, then black out!</b></span>"
	src.add_points(-20)

/mob/camera/god/verb/summonguardians()
	set category = "God Powers"
	set name = "Summon Guardians (50)"
	set desc = "Creates several strong allies which will defend your nexus, and kill anyone that does not worship you.  They last for sixty seconds."

/mob/camera/god/verb/bless()
	set category = "God Powers"
	set desc = "Blesses a follower, allowing them to be more resilient to stuns for a bit."
	set name = "Bless Follower (20)"

	if(!powerc(20))
		src << "You don't have enough power to do that."
		return
	for(var/mob/living/carbon/human/M in src.loc)
		var/mob/living/carbon/human/H = M
		src << "You grant a minor blessing to [H]."
		H.reagents.add_reagent("blessedblood", 48) //lasts about two minutes.
		H << "<span class='notice'>You feel warm for a moment, than you feel tough and stalward.</span>"
	src.add_points(-20)

/mob/camera/god/verb/cure()
	set category = "God Powers"
	set name = "Cure Disease (10)"

/mob/camera/god/verb/testconvert() //todo: remove this before release
	set category = "God Powers"
	set name = "Testing Convert Mob"
	var/list/humans = list()
	for(var/mob/living/carbon/human/M in mob_list)
		var/mob/living/carbon/human/C = M
		humans.Add(C)
	var/choice = input("Choose who you wish to make your follower.","Follower Creation") as null|anything in humans
	if(choice)
		var/mob/living/carbon/human/B = choice
		B.deity = src
		src << "You convert [B]."
		followers.Add(choice)
		return

/mob/camera/god/verb/disaster()
	set category = "God Powers"
	set name = "Invoke Disaster (300)" //requires 20+ converts.
	set desc = "Invokes the wrath of O'telbra Volema, god of chaos, causing random disastrous events."

	if(powerc(300))
		var/event
		event = rand(0,9) //I tried pick() but it wouldn't work with paths.
		switch(event)
			if(0)
				new /datum/round_event/meteor_wave()
				message_admins("[src.name] has randomly invoked a meteor wave.")
			if(1)
				new /datum/round_event/communications_blackout()
				message_admins("[src.name] has randomly invoked a communications blackout.")
			if(2)
				new /datum/round_event/carp_migration()
				message_admins("[src.name] has randomly invoked a carp migration.")
			if(3)
				new /datum/round_event/radiation_storm()
				message_admins("[src.name] has randomly invoked a rad storm.")
			if(4)
				new /datum/round_event/electrical_storm{lightsoutAmount = 2}()
				message_admins("[src.name] has randomly invoked an electrical storm.")
			if(5)
				new /datum/round_event/spider_infestation()
				message_admins("[src.name] has randomly invoked a spider infestation.")
			if(6)
				new /datum/round_event/vent_clog()
				message_admins("[src.name] has randomly invoked a vent clog.")
			if(7)
				new /datum/round_event/prison_break()
				message_admins("[src.name] has randomly invoked a prison break.")
			if(8)
				new /datum/round_event/spacevine()
				message_admins("[src.name] has randomly invoked a spacevine infestation.")
			if(9)
				new /datum/round_event/wormholes()
				message_admins("[src.name] has randomly invoked wormholes.")
		src.add_points(-300)
		return

/mob/camera/god/verb/heavyion()
	set category = "God Powers"
	set name = "Heavy Ion(300)" //requires 20+ converts.
	set desc = "Causes everything you can see to be ionized."

	if(powerc(300))
		empulse(src, 4, 8)
		src.add_points(-300)

/mob/camera/god/verb/buildnexus()
	set category = "God Powers"
	set name = "Create Nexus"
	set desc = "Instantly creates your nexus.  You can only do this once, so pick a good spot."
	if(!isturf(src.loc) || istype(src.loc, /turf/space)) //I tried using the powerc() proc but it just wouldn't work.
		src << "<span class='danger'>Your structure would just float away, it needs to be on stable ground.</font>"
	else
		var/obj/structure/divine/nexus/O = new(loc)
		O.deity = src
		O.side = src.side
		src.god_nexus = O
		src.nexus_required = 1
		src.verbs -= /mob/camera/god/verb/buildnexus
		src.update_health()
		return


/mob/camera/god/verb/build()
	set category = "God Powers"
	set name = "Create Structure (75)"
	set desc = "Create the foundation of a divine object."

	if(powerc(75,1))
		var/choice = input("Choose what you wish to create.","Divine structure") as null|anything in list("conduit","forge","convert altar",
																											"sacrifice altar","holy puddle","gate",
																											"power pylon","defense pylon","shrine",
																											"translocator <greater gem>","lazarus altar <greater gem>")
		if(!choice || !powerc(75))	return
		src << "You create an unfinished [choice]."
		src.add_points(-75)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='notice'>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</span>"), 1) //todo:span classes
		switch(choice)
			if("conduit")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "conduit"
				O.icon_state = "conduit"
				O.side = src.side
				O.metal_cost = 25
				O.glass_cost = 10
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/conduit
				O.postbuild()
			if("forge")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "forge"
				O.icon_state = "forge"
				O.side = src.side
				O.metal_cost = 40
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/forge
				O.postbuild()
			if("convert altar")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "conversion altar"
				O.icon_state = "convertaltar"
				O.side = src.side
				O.metal_cost = 20
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/convertaltar
				O.postbuild()
			if("sacrifice altar")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "sacrificial altar"
				O.icon_state = "sacrificealtar"
				O.side = src.side
				O.metal_cost = 30
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/sacrificealtar
				O.postbuild()
			if("holy puddle")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "holy puddle"
				O.icon_state = "puddle"
				O.side = src.side
				O.metal_cost = 15
				O.glass_cost = 10
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/healingfountain
				O.postbuild()
			if("gate")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "gate"
				O.icon_state = "gate"
				O.side = src.side
				O.metal_cost = 40
				O.glass_cost = 30
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/gate
				O.postbuild()
			if("power pylon")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "power pylon"
				O.icon_state = "powerpylon"
				O.side = src.side
				O.metal_cost = 10
				O.glass_cost = 30
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/powerpylon
				O.postbuild()
			if("defense pylon")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "defense pylon"
				O.icon_state = "defensepylon"
				O.side = src.side
				O.metal_cost = 30
				O.glass_cost = 40
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/defensepylon
				O.postbuild()
			if("shrine")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "shrine"
				O.icon_state = "shrine"
				O.side = src.side
				O.metal_cost = 20
				O.glass_cost = 20
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.glass_cost] glass sheets to complete."
				O.project = /obj/structure/divine/shrine
				O.postbuild()
			if("translocator <greater gem>")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "translocator"
				O.icon_state = "translocator"
				O.side = src.side
				O.metal_cost = 20
				O.glass_cost = 20
				O.greater_gem_cost = 1
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, [O.glass_cost] glass sheets, and [O.greater_gem_cost] to complete."
				O.project = /obj/structure/divine/translocator
				O.postbuild()
			if("lazarus altar <greater gem>")
				var/obj/structure/divine/holder/O = new(loc)
				O.name = "lazarus altar"
				O.icon_state = "lazarusaltar"
				O.side = src.side
				O.metal_cost = 20
				O.greater_gem_cost = 1
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets, and [O.greater_gem_cost] to complete."
				O.project = /obj/structure/divine/lazarusaltar
				O.postbuild()
	return

/mob/camera/god/verb/build_trap()
	set category = "God Powers"
	set name = "Create Ward/Trap (20)"
	set desc = "Creates a ward or a trap."

	if(powerc(20,1))
		var/choice = input("Choose what you wish to create.","Divine structure") as null|anything in list("ward","shock trap","flame trap","frost trap","earth trap")
		if(!choice || !powerc(20))	return
		src << "You create an unfinished [choice]."
		src.add_points(-20)
		switch(choice)
			if("ward") //todo: remove this and add it to onclick
				var/obj/structure/divine/ward/O = new(loc)
				for(var/mob/V in viewers(src, null))
					V.show_message(text("<span class='notice'>[src] creates a ward, able to prevent anything from passing it.</span>"), 1)
				O.deity = src
				O.side = src.side
				O.postbuild()
			if("shock trap")
				var/obj/structure/divine/holder/O = new(loc)
				for(var/mob/V in viewers(src, null))
					V.show_message(text("<span class='notice'>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</span>"), 1)
				O.name = "shock trap"
				O.icon_state = "trap-shock"
				O.side = src.side
				O.metal_cost = 5
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/trap/stun
				O.postbuild()
			if("flame trap")
				var/obj/structure/divine/holder/O = new(loc)
				for(var/mob/V in viewers(src, null))
					V.show_message(text("<span class='notice'>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</span>"), 1)
				O.name = "flame trap"
				O.icon_state = "trap-fire"
				O.side = src.side
				O.metal_cost = 5
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/trap/fire
				O.postbuild()
			if("frost trap")
				var/obj/structure/divine/holder/O = new(loc)
				for(var/mob/V in viewers(src, null))
					V.show_message(text("<span class='notice'>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</span>"), 1)
				O.name = "frost trap"
				O.icon_state = "trap-frost"
				O.side = src.side
				O.metal_cost = 5
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/trap/chill
				O.postbuild()
			if("earth trap")
				var/obj/structure/divine/holder/O = new(loc)
				for(var/mob/V in viewers(src, null))
					V.show_message(text("<span class='notice'>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</span>"), 1)
				O.name = "earth trap"
				O.icon_state = "trap-earth"
				O.side = src.side
				O.metal_cost = 5
				O.desc = "It's an unfinsihed [O.name].  It needs [O.metal_cost] metal sheets to complete."
				O.project = /obj/structure/divine/trap/damage
				O.postbuild()
	return

/mob/camera/god/verb/god_chat(msg as text)
	set category = "God Powers"
	set name = "Talk to Gods"
	set desc = "Talk with the other Gods tethered to this station."
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")
	var/tempmsg = msg
	msg = "<font color=\"#045FB4\"><i><span class='game say'>Divinity Chat, <span class='name'>[name]</span> says, <span class='message'>[tempmsg]</span></span></i></font>"
	for(var/mob/M in mob_list)
		if(isgod(M) || isobserver(M))
			M.show_message(msg, 2)
	src << msg
	return