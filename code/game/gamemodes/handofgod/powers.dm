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

/mob/camera/god/verb/newprophet()
	set category = "God Powers"
	set name = "Appoint Prophet (100)"

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

/mob/camera/god/verb/disaster()
	set category = "God Powers"
	set name = "Invoke Disaster (100)"
	set desc = "Causes fate to intervene with the station, which may spell doom.  Useful if you wish to encourage leaving."

/mob/camera/god/verb/buildnexus()
	set category = "God Powers"
	set name = "Create Nexus"
	set desc = "Instantly creates your nexus.  You can only do this once, so pick a good spot."

///mob/camera/god/verb/build()
//		set category = "God Powers"
//		set name = "Create Structure"

/mob/camera/god/verb/build()
	set category = "God Powers"
	set name = "Create Structure (75)"
	set desc = "Create the foundation of a divine object."

	if(powerc(75,1))
		var/choice = input("Choose what you wish to create.","Divine structure") as null|anything in list("conduit","forge","convert alter",
																											"sacrifice alter","holy puddle","gate",
																											"power pylon","defense pylon","shrine")
		if(!choice || !powerc(75))	return
		powerc(-75)
		src << "You create an unfinished [choice]."
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
				new /obj/structure/divine/powerpylon(loc)
			if("defense pylon")
				new /obj/structure/divine/defensepylon(loc)
			if("shrine")
				new /obj/structure/divine/shrine(loc)
	return
