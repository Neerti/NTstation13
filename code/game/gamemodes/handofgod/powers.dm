/mob/camera/god/proc/powerc(X, Y)//X is the cost, Y is only used for buildings
	if(X && get_god_points() < X)
		src << "<span class='danger'>You lack the faith points needed to do this.</font>"
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space))) //no building in space.
		src << "<span class='danger'>Your structure would just float away, it needs to be on stable ground.</font>"
		return 0
	else	return 1

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
	if(!powerc(100))
		src << "You don't have enough power to make a prophet yet."
		return
	var/list/cultists = list()
	for(var/mob/living/carbon/human/M in mob_list)
		var/mob/living/carbon/human/C = M
		if(C.deity == src)
			cultists.Add(C)
	var/choice = input("Choose who you wish to make your prophet","Prophet Creation") as null|anything in cultists
	if(choice)
		var/mob/living/carbon/human/B = choice
		src << "You choose [B] as your prophet."
		B.deity = src
		B.prophet = 1
		B << "Rejoice, for ye have been chosen to be thy generous god, [src]'s prophet!"
		src.verbs -= /mob/camera/god/verb/newprophet
		god_points -= 100
		return

/mob/camera/god/verb/talk()
	set category = "God Powers"
	set name = "Talk to Anyone (75)"
	set desc = "Allows you to send a message to anyone."

/mob/camera/god/verb/smite()
	set category = "God Powers"
	set name = "Smite (40)"
	set desc = "Hits anything under you with a large amount of damage."

/mob/camera/god/verb/summonguardians()
	set category = "God Powers"
	set name = "Summon Guardians (50)"
	set desc = "Creates several strong allies which will defend your nexus, and kill anyone that does not worship you.  They last for sixty seconds."

/mob/camera/god/verb/bless()
	set category = "God Powers"
	set name = "Bless Cultist (20)"

/mob/camera/god/verb/heal()
	set category = "God Powers"
	set name = "Healing Aura (2/sec)"

/mob/camera/god/verb/cure()
	set category = "God Powers"
	set name = "Cure Disease (10)"

/mob/camera/god/verb/testconvert()
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

/mob/camera/god/verb/disaster()
	set category = "God Powers"
	set name = "Invoke Disaster (300)"
	set desc = "Invokes the wrath of O'telbra Volema, god of chaos, causing random disastrous events."

/mob/camera/god/verb/heavyion()
	set category = "God Powers"
	set name = "Heavy Ion(300)"
	set desc = "Causes everything you can see to be ionized."

/mob/camera/god/verb/buildnexus()
	set category = "God Powers"
	set name = "Create Nexus"
	set desc = "Instantly creates your nexus.  You can only do this once, so pick a good spot."
	if(!isturf(src.loc) || istype(src.loc, /turf/space)) //I tried using the powerc() proc but it just wouldn't work.
		src << "<span class='danger'>Your structure would just float away, it needs to be on stable ground.</font>"
	else
		var/obj/structure/divine/nexus/O = new(loc)
		O.deity = usr
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
		var/choice = input("Choose what you wish to create.","Divine structure") as null|anything in list("conduit","forge","convert alter",
																											"sacrifice alter","holy puddle","gate",
																											"power pylon","defense pylon","shrine")
		if(!choice || !powerc(75))	return
		src << "You create an unfinished [choice]."
		src.add_points(-75)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<font color='blue'><b>[src] creates a transparent, unfinished [choice].  It can be finished by adding materials.</B></font>"), 1) //todo:span classes
		switch(choice)
			if("conduit")
				new /obj/structure/divine/conduit(loc)
			if("forge")
				new /obj/structure/divine/forge(loc)
			if("convert alter")
				new /obj/structure/divine/convertalter(loc)
			if("sacrifice alter")
				new /obj/structure/divine/sacrificealter(loc)
			if("holy puddle")
				new /obj/structure/divine/puddle(loc)
			if("gate")
				new /obj/structure/divine/gate(loc)
			if("power pylon")
				var/obj/structure/divine/powerpylon/O = new(loc)
				O.deity = usr
			if("defense pylon")
				new /obj/structure/divine/defensepylon(loc)
			if("shrine")
				new /obj/structure/divine/shrine(loc)
	return

/mob/camera/god/verb/god_chat(msg as text)
	set category = "God Powers"
	set name = "Talk to Gods"
	set desc = "Talk with the other Gods tethered to this station."
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")
	var/tempmsg = msg
	msg = "<font color=\"#045FB4\"><i><span class='game say'>Divinity Chat, <span class='name'>[name]</span> <span class='message'>[tempmsg]</span></span></i></font>"
	for(var/mob/M in mob_list)
		if(isgod(M) || isobserver(M))
			M.show_message(msg, 2)
	return