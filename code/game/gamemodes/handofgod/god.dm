/mob/camera/god
	name = "deity" //Players will rename themselves when the game starts.
	real_name = "deity"
	icon = 'icons/mob/god.dmi'
	icon_state = "marker" //Placeholder
	invisibility = 60
	see_in_dark = 8
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	var/god_points = 0 //Used to interact with your followers.
	var/max_god_points = 100
	var/followers = 0 //How many players are currently a part of the god's cult.  If this is zero, the god dies.

	var/side = "neutral" //Which side the god is on. red and blue is for gamemode, neutral is for admins to play with.

	var/obj/structure/divine/nexus/god_nexus = null // The god's nexus.  Without it, they die.

	var/nexus_required = 0 //If they need the nexus to survive.  Defaults to zero so newly spawned gods don't instantly die.
	var/followers_required = 0 //Same as above.

/mob/camera/god/proc/get_god_points()
 	return god_points

/mob/camera/god/Stat()
	statpanel("Status")
	..()
	if (client.statpanel == "Status")
		if(god_nexus)
			stat(null, "Nexus Health: [god_nexus.health]")
		stat(null, "Followers: [followers]")
		stat(null, "Faith Points: [god_points]/[max_god_points]")
	return

/mob/camera/god/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are a deity!</span>"
	src << "You are a deity and are worshipped by a cult!  You are rather weak right now, but that will change as you gain more followers."
	src << "You will need to place an anchor to this world, a <b>Nexus</b>, in two minutes.  If you don't, one will be placed for you randomly."
	src << "Your <b>Follower</b> count determines how many people believe in you and are a part of your cult.  If this drops to zero, you will die."
	src << "Your <b>Nexus Integrity</b> tells you the condition of your nexus.  If your nexus is destroyed, you die as well, but your powers are amplified when near it."
	src << "Your <b>Power</b> is used to interact with the world.  This will regenerate on it's own, and it goes faster when you have more followers."
	src << "The first thing you should do after placing your nexus is to <b>appoint a prophet</b>.  Only prophets can hear you talk, unless you use an expensive power."
	update_health()

/mob/camera/god/proc/update_health() //handles hud stuff
	if(god_nexus)
		hud_used.deity_health_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='green'>[god_nexus.health]</font></div>"

/mob/camera/god/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	god_talk(message)

/mob/camera/god/proc/god_talk(message)
	log_say("[key_name(src)] : [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<font color=\"#045FB4\"><i><span class='game say'>Divine Telepathy, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i></font>"

	for (var/mob/M in mob_list)
		if(isgod(M) || isobserver(M))
			M.show_message(rendered, 2)

/mob/camera/god/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/god/Move(var/NewLoc, var/Dir = 0)
		loc = NewLoc

///mob/camera/god/god_act()
//	return