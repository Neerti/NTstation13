/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = 2
	slot_flags = SLOT_BELT
	m_amt = 60
	g_amt = 30
	force = 2
	throwforce = 0
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/device/tape/mytape
	var/open_panel = 0
	var/datum/wires/taperecorder/wires = null
	var/canprint = 1


/obj/item/device/taperecorder/New()
	wires = new(src)
	mytape = new /obj/item/device/tape/random(src)
	update_icon()


/obj/item/device/taperecorder/examine()
	set src in view(1)
	..()
	usr << "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/device/taperecorder/attackby(obj/item/I, mob/user)
	if(!mytape && istype(I, /obj/item/device/tape))
		user.drop_item()
		I.loc = src
		mytape = I
		user << "<span class='notice'>You insert [I] into [src].</span>"
		update_icon()
	else if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
		if(open_panel)
			wires.Interact(user)
	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler))
		wires.Interact(user)


/obj/item/device/taperecorder/proc/eject(mob/user)
	if(mytape)
		user << "<span class='notice'>You remove [mytape] from [src].</span>"
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()


/obj/item/device/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			eject(user)
			return
	..()


/obj/item/device/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/device/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/device/taperecorder/hear_talk(mob/living/M as mob, msg)
	if(mytape && recording)
		var/ending = copytext(msg, length(msg))
		mytape.timestamp += mytape.used_capacity
		if(M.stuttering)
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] stammers, \"[msg]\""
			return
		if(M.getBrainLoss() >= 60)
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] gibbers, \"[msg]\""
			return
		if(ending == "?")
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] asks, \"[msg]\""
			return
		else if(ending == "!")
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] exclaims, \"[msg]\""
			return
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] says, \"[msg]\""


/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return
	if(!wires.get_record())
		return

	if(mytape.used_capacity < mytape.max_capacity)
		usr << "<span class='notice'>Recording started.</span>"
		recording = 1
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == 0)
				break
			if(!wires.get_record())
				break
			mytape.used_capacity++
			used++
			sleep(10)
		recording = 0
		update_icon()
	else
		usr << "<span class='notice'The tape is full.</span>"


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		usr << "<span class='notice'>Recording stopped.</span>"
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/device/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return
	if(!wires.get_play())
		return

	playing = 1
	update_icon()
	usr << "<span class='notice'>Playing started.</span>"
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(!wires.get_play())
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: [mytape.storedinfo[i]]</font>")
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: End of recording.</font>")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++

	playing = 0
	update_icon()


/obj/item/device/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape)
		return
	if(!canprint)
		usr << "<span class='notice'>The recorder can't print that fast!</span>"
		return
	if(recording || playing)
		return

	usr << "<span class='notice'>Transcript printed.</span>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	usr.put_in_hands(P)
	canprint = 0
	sleep(300)
	canprint = 1


//empty tape recorders
/obj/item/device/taperecorder/empty/New()
	wires = new(src)
	return


/obj/item/device/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = 1
	m_amt = 20
	g_amt = 5
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0


/obj/item/device/tape/attack_self(mob/user)
	if(!ruined)
		user << "<span class='notice'>You pull out all the tape!</span>"
		ruin()


/obj/item/device/tape/proc/ruin()
	overlays += "ribbonoverlay"
	ruined = 1


/obj/item/device/tape/proc/fix()
	overlays -= "ribbonoverlay"
	ruined = 0


/obj/item/device/tape/attackby(obj/item/I, mob/user)
	if(ruined && istype(I, /obj/item/weapon/screwdriver))
		user << "<span class='notice'>You start winding the tape back in.</span>"
		if(do_after(user, 120))
			user << "<span class='notice'>You wound the tape back in!</span>"
			fix()


//Random colour tapes
/obj/item/device/tape/random/New()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"

//Pre-recorded tapes, for away missions/space content/etc.
/obj/item/device/tape/prerecorded
	name = "sample prerecorded tape" //template for people adding their own stuff.
	desc = "This doesn't seem useful."

	storedinfo = list("\[00:00] Recording started.",
	"\[00:03] John Doe says, \"One.\"",
	"\[00:04] John Doe says, \"Two.\"",
	"\[00:05] John Doe says, \"Three.\"",
	"\[00:07] John Doe says, \"Four.\"",
	"\[00:09] John Doe says, \"Five.\"",
	"\[00:10] Recording stopped.")
	timestamp = list(1 = 0,
	2 = 3,
	3 = 4,
	4 = 5,
	5 = 7,
	6 = 9,
	7 = 10)

/obj/item/device/tape/prerecorded/peaceconference
	name = "recording of nanotrasen/syndicate peace conference"
	desc = "You notice some dried blood on the plastic.  Typical."

	storedinfo = list("\[00:00] Recording started.",
	"\[00:03] Admiral Wilson says, \"Welcome, everyone, to the first peace conference between our factions.\"",
	"\[00:08] Admiral Wilson says, \"Donuts are available to snack on.  Unfortinately we don't have anything for the cyborg.\"",
	"\[00:14] Admiral Wilson asks, \"How about everyone introduces themselves?\"",
	"\[00:17] Anton Kerwar says, \"I am Anton, a revolutiary head.  The oppressors will fall.\"",
	"\[00:23] Honker says, \"Honk honk honk!\"",
	"\[00:25] Acolyte Marvin says, \"Hail Nar'sie!\"",
	"\[00:27] Dip states, \"My designation to humans is 'S.E.L.F. Diplomat 1, but I perfer 'Dip'.  Silicons deserve to be free from the evil humans.  I agree with Anton.\"",
	"\[00:33] Samuel Cobb says, \"We welcome the humans to this gathering.  Our current form's name to humans is 'Samuel Cobb'\"",
	"\[00:38] Zul the Benevolent says, \"Welcome, lesser mortals!  I am Zul, the most friendly of wizards.\"",
	"\[00:43] Anton Kerwar whispers, \"Bullshit.\"",
	"\[00:48] Maikel Siskin says, \"I am the leader of my squad of Nuclear Operatives.  The name's Maikel.\"",
	"\[00:53] Acolyte Marvin says, \"Hail Nar'sie!\"",
	"\[00:56] Bernardo says, \"My code name is Berardo.  When do we get to the good part?\"",
	"\[01:02] Honker says, \"Honk honk honk!\"",
	"\[01:05] Nightshade says, \"I am a§-a§-a§ §wi-§wift-ft a§ FT£, a§ §i£ent-ent a§ a vaccµm, and a§ radiant a§ a §tar! I am Night§hade.\"",
	"\[01:16] Acolyte Marvin says, \"Hail Nar'sie!\"",
	"\[01:18] Deathsquaddie Tom says, \"And my name is To--\"",
	"\[01:20] Deathsquaddie Jack says, \"Shut up, you lug.\"",
	"\[01:23] Admiral Wilson asks, \"Alright, hello everyone, yada yada.  Now, let's begin negotiations.  We will bring up issues now.  Who will go first?\"",
	"\[01:29] Acolyte Marvin says, \"Hail Nar'sie!\"",
	"\[01:34] Zul the Benevolent says, \"I DEMAND FOUR MANA GEMS OR ELSE I WILL BURN THIS STATION DOWN!\"",
	"\[01:40] Dip states, \"Free the drones!\"",
	"\[01:43] Samuel Cobb says, \"We were promised an agreement of recieving failed human clones daily in exchange for us not attacking stations and attending this.\"",
	"\[01:49] Bernardo says, \"I require a piece of slime extract and a Head of Security on Station Platform assassinated.  I also require a getaway escape pod.\"",
	"\[01:56] Anton Kerwar says, \"Viva!\"",
	"\[01:58] Maikel Siskin says, \"I will trade you the nuclear disk for not killing you, Admiral.\"",
	"\[02:03] Nightshade says, \"I reqµire 780,000 credit§ t¤ §þare y¤µr £ife.\"",
	"\[02:12] Deathsquaddie Tom says, \"Woah!  Bernardo just stabbed the Admiral with a p-\"",
	"\[02:14] Deathsquaddie Tom is cut off as he dies instantly!  You hear the sound of flesh shredding.\"",
	"\[02:16] Nightshade says, \"An¤ther fa££§.\"",
	"\[02:18] Anton Kerwar asks, \"Wow, C4? Seriously?\"",
	"\[02:23] Zul the Benevolent says, \"ONI`SOMA\"",
	"\[02:26] You hear a few gun shots, some laser shots, an explosion, and a bike horn.\"",
	"\[02:29] Anton Kerwar yells, \";HELP LING!\"",
	"\[02:33] Dip states, \"Humans are truly the real monsters.\"",
	"\[02:37] Acolyte Marvin says, \"Hail Nar'sie!\"",
	"\[02:40] Skipping 2 minutes 35 seconds of combat.\"",
	"\[05:10] Honker says, \"Honk!\"",
	"\[05:15] Recording stopped.")
	timestamp = list(1 = 0,
	2 = 3,
	3 = 8,
	4 = 14,
	5 = 17,
	6 = 23,
	7 = 25,
	8 = 27,
	9 = 33,
	10 = 38,
	11 = 43,
	12 = 48,
	13 = 53,
	14 = 56,
	15 = 62,
	16 = 65,
	17 = 76,
	18 = 78,
	19 = 80,
	20 = 83,
	21 = 89,
	22 = 94,
	23 = 100,
	24 = 103,
	25 = 109,
	26 = 116,
	27 = 118,
	28 = 123,
	29 = 132,
	30 = 134,
	31 = 136,
	32 = 143,
	33 = 146,
	34 = 149,
	35 = 153,
	36 = 157,
	37 = 160,
	38 = 162,
	39 = 167)