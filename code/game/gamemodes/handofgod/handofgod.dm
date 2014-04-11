/datum/game_mode/
	var/list/datum/mind/red_prophets = list()
	var/list/datum/mind/red_followers = list()

	var/list/datum/mind/blue_prophets = list()
	var/list/datum/mind/blue_followers = list()

//	var/list/datum/mind/neutral_prophets = list() //for admin abuse if I ever get around to it.
//	var/iist/datum/mind/neutral_followers = list()

	var/list/datum/mind/unassigned_followers = list() //for roundstart team assigning
	var/list/datum/mind/assigned_to_red = list() //we will be a red follower after the game starts.
	var/list/datum/mind/assigned_to_blue = list() //ditto for blue team.

/datum/game_mode/handofgod
	name = "hand of god"
	config_tag = "handofgod"
	antag_flag = BE_CULTIST //deities are handled seperately

	required_players = 1 //6-8 followers total, everyone else is crew  if this says one it's for debugging, and if it's in final build then scream at neerti
	required_enemies = 1 //three red, three blue
	recommended_enemies = 1

	uplink_welcome = "Divine Uplink Console:"
	uplink_uses = 10

	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain","Chaplain")

	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/handofgod/announce()
	world << "<B>The current game mode is - Hand of God!</B>"
	world << "<B>Two cults are onboard the station, seeking to overthrow the other, and anyone who stands in their way.</B>"
	world << "<B>Followers</B> - complete your deity's objectives. Convert crewmembers to your cause by using your deity's nexus. Remember - there is no you, there is only the cult."
	world << "<B>Prophets</B> - Command your cult by the will of your deity.  You are a high-value target, so be careful!"
	world << "<B>Personnel</B> - Do not let any cult succeed in its mission. Loyalty implants and holy water will revert them to neutral, hopefully nonviolent crew."

/////////////
//Pre setup//
/////////////

/datum/game_mode/handofgod/pre_setup() //
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for(var/follower_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/follower = pick(antag_candidates)
		antag_candidates -= follower
		unassigned_followers += follower
//		log_game("[follower.key] (ckey) has been selected as a red follower")
		world << "[follower.key] has been chosen to be a follower." //debug stuff
		world << "recommended_enemies = [recommended_enemies]"
//	return (unassigned_followers.len>=required_enemies)

//	var/team_cap = required_enemies / 2

	for(var/team_cap = required_enemies / 2 to recommended_enemies)
		if(unassigned_followers.len == team_cap)
			world << "Loop for unassigned length was broken for red." //debug
			world << "team_cap = [team_cap]"
			break
		var/datum/mind/chosen = pick(unassigned_followers)
		unassigned_followers -= chosen
		world << "[chosen.key] was removed from unassigned list." //debug
		world << "team_cap = [team_cap]"
		assigned_to_red += chosen
		world << "[chosen.key] was placed on assign to red list." //debug
		world << "team_cap = [team_cap]"
		add_red_follower(chosen)
		world << "[chosen.key] was converted to red." //debug
		world << "team_cap = [team_cap]"

	for(var/team_cap = required_enemies to recommended_enemies)
		if(!unassigned_followers.len)
			world << "Loop for unassigned lengh was broken for blue." //debug
			world << "team_cap = [team_cap]"
			break
		var/datum/mind/chosen = pick(unassigned_followers)
		unassigned_followers -= chosen
		world << "[chosen.key] was removed from unassigned list." //debug
		world << "team_cap = [team_cap]"
		assigned_to_blue += chosen
		world << "[chosen.key] was placed on assign to blue list." //debug
		world << "team_cap = [team_cap]"
		add_blue_follower(chosen)
		world << "[chosen.key] was converted to blue." //debug
		world << "team_cap = [team_cap]"
	return 1

//	unassigned_followers.Cut(,team_cap)
//	world << "Unassigned followers were cut."

/datum/game_mode/handofgod/post_setup() //Icons don't work properly at roundstart, hacky but it works.
	update_all_red_follower_icons()
	update_all_blue_follower_icons()

///////////////
//Greet procs//
///////////////

/datum/game_mode/proc/greet_red_follower(var/datum/mind/red_follower_mind, var/you_are=1)
	if (you_are)
		red_follower_mind.current << "<span class='danger'><B>You are a follwer of the cult of   !</span>"//todo: find way to get god name to show here


/////////////////
//Convert procs//
/////////////////

//red

/datum/game_mode/proc/add_red_follower(datum/mind/red_follower_mind)
	var/mob/living/carbon/human/H = red_follower_mind.current//Check to see if the potential follower is implanted
	if(isloyal(H))
		H << "<span class='danger'>Your loyalty implant blocked out the deity's influence.</span>"
		return 0
	if((red_follower_mind in red_followers) || (red_follower_mind in red_prophets) || (red_follower_mind in blue_followers) || (red_follower_mind in blue_prophets)) //sanity
		H << "<span class='danger'>You already belong to a deity.  Your strong faith has blocked out the conversion attempt.</span>"
		return 0
	var/obj/item/weapon/nullrod/N = locate() in H
	if(N)
		H << "<span class='danger'>Your null rod prevented the deity from brainwashing you.</span>"
		return 0
	red_followers += red_follower_mind
	red_follower_mind.current << "<span class='danger'>You are a follower of a newly created deity! You will now serve your cult to the death. You can identify your allies by the red four sided star icons, and your prophet by the eight-sided red and gold icon. Help them enforce your god's will on the station!</span>"
	red_follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the red follower cult!</font>"
	red_follower_mind.special_role = "Red Follower"
	update_red_follower_icons_added(red_follower_mind)
	return 1

/mob/living/carbon/human/verb/testconvert()
	ticker.mode.add_red_follower(src.mind)

/mob/living/carbon/human/verb/resetredicons()
	ticker.mode.update_all_red_follower_icons()

//blue

/datum/game_mode/proc/add_blue_follower(var/datum/mind/blue_follower_mind)
	var/mob/living/carbon/human/H = blue_follower_mind.current//Check to see if the potential follower is implanted
	if(isloyal(H))
		H << "<span class='danger'>Your loyalty implant blocked out the deity's influence.</span>"
		return 0
	if((blue_follower_mind in red_followers) || (blue_follower_mind in red_prophets) || (blue_follower_mind in blue_followers) || (blue_follower_mind in blue_prophets)) //sanity
		H << "<span class='danger'>You already belong to a deity.  Your strong faith has blocked out the conversion attempt.</span>"
		return 0
	var/obj/item/weapon/nullrod/N = locate() in H
	if(N)
		H << "<span class='danger'>Your null rod prevented the deity from brainwashing you.</span>"
		return 0
	blue_followers += blue_follower_mind
	blue_follower_mind.current << "<span class='danger'>You are a follower of a newly created deity! You will now serve your cult to the death. You can identify your allies by the blue four sided star icons, and your prophet by the eight-sided blue and gold icon. Help them enforce your god's will on the station!</span>"
	blue_follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the blue follower cult!</font>"
	blue_follower_mind.special_role = "Blue Follower"
	update_blue_follower_icons_added(blue_follower_mind)
	return 1

//////////////////
//Deconvert proc//
//////////////////

/datum/game_mode/proc/remove_follower(var/datum/mind/follower_mind) //this deconverts both sides
	if(follower_mind in red_followers || blue_followers)
		red_followers -= follower_mind
		blue_followers -= follower_mind
		follower_mind.special_role = null
		follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been deconverted from a deity's cult!</font>"

		follower_mind.current << "<span class='danger'><b>Your mind has been cleared from the brainwashing the followers have done to you.  Now you serve yourself and the crew.</b></span>"

		update_red_follower_icons_removed(follower_mind)
		update_blue_follower_icons_removed(follower_mind)
		for(var/mob/living/M in view(follower_mind.current))
			M << "[follower_mind.current] looks like they just remembered their real allegiance!"

///////////////////////
//Follower icon procs//
///////////////////////

/////////////////////////////
//Follower update all icons//
/////////////////////////////

//remember that plural means it's the list, singular is the var defined inside the proc.

//Red

/datum/game_mode/proc/update_all_red_follower_icons()
	spawn(0)
		for(var/datum/mind/red_prophet_mind in red_prophets)
			if(red_prophet_mind.current)
				if(red_prophet_mind.current.client)
					for(var/image/I in red_prophet_mind.current.client.images)
						if(I.icon_state == "follower-red" || I.icon_state == "prophet-red")
							del(I)

		for(var/datum/mind/red_follower_mind in red_followers)
			if(red_follower_mind.current)
				if(red_follower_mind.current.client)
					for(var/image/I in red_follower_mind.current.client.images)
						if(I.icon_state == "follower-red" || I.icon_state == "prophet-red")
							del(I)

		for(var/datum/mind/red_prophet in red_prophets)
			if(red_prophet.current)
				if(red_prophet.current.client)
					for(var/datum/mind/red_follower in red_followers)
						if(red_follower.current)
							var/I = image('icons/mob/mob.dmi', loc = red_follower.current, icon_state = "follower-red")
							red_prophet.current.client.images += I
					for(var/datum/mind/red_prophet_1 in red_prophets)
						if(red_prophet_1.current)
							var/I = image('icons/mob/mob.dmi', loc = red_prophet_1.current, icon_state = "prophet-red")
							red_prophet.current.client.images += I

		for(var/datum/mind/red_follower in red_followers)
			if(red_follower.current)
				if(red_follower.current.client)
					for(var/datum/mind/red_prophet in red_prophets)
						if(red_prophet.current)
							var/I = image('icons/mob/mob.dmi', loc = red_prophet.current, icon_state = "prophet-red")
							red_follower.current.client.images += I
					for(var/datum/mind/red_follower_1 in red_followers)
						if(red_follower_1.current)
							var/I = image('icons/mob/mob.dmi', loc = red_follower_1.current, icon_state = "follower-red")
							red_follower.current.client.images += I

//Blue

/datum/game_mode/proc/update_all_blue_follower_icons()
	spawn(0)
		for(var/datum/mind/blue_prophet_mind in blue_prophets)
			if(blue_prophet_mind.current)
				if(blue_prophet_mind.current.client)
					for(var/image/I in blue_prophet_mind.current.client.images)
						if(I.icon_state == "follower-blue" || I.icon_state == "prophet-blue")
							del(I)

		for(var/datum/mind/blue_follower_mind in blue_followers)
			if(blue_follower_mind.current)
				if(blue_follower_mind.current.client)
					for(var/image/I in blue_follower_mind.current.client.images)
						if(I.icon_state == "follower-blue" || I.icon_state == "prophet-blue")
							del(I)

		for(var/datum/mind/blue_prophet in blue_prophets)
			if(blue_prophet.current)
				if(blue_prophet.current.client)
					for(var/datum/mind/blue_follower in blue_followers)
						if(blue_follower.current)
							var/I = image('icons/mob/mob.dmi', loc = blue_follower.current, icon_state = "follower-blue")
							blue_prophet.current.client.images += I
					for(var/datum/mind/blue_prophet_1 in blue_prophets)
						if(blue_prophet_1.current)
							var/I = image('icons/mob/mob.dmi', loc = blue_prophet_1.current, icon_state = "prophet-blue")
							blue_prophet.current.client.images += I

		for(var/datum/mind/blue_follower in blue_followers)
			if(blue_follower.current)
				if(blue_follower.current.client)
					for(var/datum/mind/blue_prophet in blue_prophets)
						if(blue_prophet.current)
							var/I = image('icons/mob/mob.dmi', loc = blue_prophet.current, icon_state = "prophet-blue")
							blue_follower.current.client.images += I
					for(var/datum/mind/blue_follower_1 in blue_followers)
						if(blue_follower_1.current)
							var/I = image('icons/mob/mob.dmi', loc = blue_follower_1.current, icon_state = "follower-blue")
							blue_follower.current.client.images += I

///////////////////////////////
//Follower update icons added//
///////////////////////////////

//Red

/datum/game_mode/proc/update_red_follower_icons_added(datum/mind/red_follower_mind)
	spawn(0)
		for(var/datum/mind/red_prophet_mind in red_prophets)
			if(red_prophet_mind.current)
				if(red_prophet_mind.current.client)
					var/I = image('icons/mob/mob.dmi', loc = red_follower_mind.current, icon_state = "follower-red")
					red_prophet_mind.current.client.images += I
			if(red_follower_mind.current)
				if(red_follower_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = red_prophet_mind.current, icon_state = "prophet-red")
					red_follower_mind.current.client.images += J

		for(var/datum/mind/red_follower_mind_1 in red_followers)
			if(red_follower_mind_1.current)
				if(red_follower_mind_1.current.client)
					var/I = image('icons/mob/mob.dmi', loc = red_follower_mind.current, icon_state = "follower-red")
					red_follower_mind_1.current.client.images += I
			if(red_follower_mind.current)
				if(red_follower_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = red_follower_mind_1.current, icon_state = "follower-red")
					red_follower_mind.current.client.images += J

//Blue

/datum/game_mode/proc/update_blue_follower_icons_added(datum/mind/blue_follower_mind)
	spawn(0)
		for(var/datum/mind/blue_prophet_mind in blue_prophets)
			if(blue_prophet_mind.current)
				if(blue_prophet_mind.current.client)
					var/I = image('icons/mob/mob.dmi', loc = blue_follower_mind.current, icon_state = "follower-blue")
					blue_prophet_mind.current.client.images += I
			if(blue_follower_mind.current)
				if(blue_follower_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = blue_prophet_mind.current, icon_state = "prophet-blue")
					blue_follower_mind.current.client.images += J

		for(var/datum/mind/blue_follower_mind_1 in blue_followers)
			if(blue_follower_mind_1.current)
				if(blue_follower_mind_1.current.client)
					var/I = image('icons/mob/mob.dmi', loc = blue_follower_mind.current, icon_state = "follower-blue")
					blue_follower_mind_1.current.client.images += I
			if(blue_follower_mind.current)
				if(blue_follower_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = blue_follower_mind_1.current, icon_state = "follower-blue")
					blue_follower_mind.current.client.images += J

/////////////////////////////////
//Follower update icons removed//
/////////////////////////////////

//Red

/datum/game_mode/proc/update_red_follower_icons_removed(datum/mind/red_follower_mind)
	spawn(0)
		for(var/datum/mind/red_prophet_mind in red_prophets)
			if(red_prophet_mind.current)
				if(red_prophet_mind.current.client)
					for(var/image/I in red_prophet_mind.current.client.images)
						if((I.icon_state == "follower-red" || I.icon_state == "prophet-red") && I.loc == red_follower_mind.current)
							del(I)

		for(var/datum/mind/red_follower_mind_1 in red_followers)
			if(red_follower_mind_1.current)
				if(red_follower_mind_1.current.client)
					for(var/image/I in red_follower_mind_1.current.client.images)
						if((I.icon_state == "follower-red" || I.icon_state == "prophet-red") && I.loc == red_follower_mind.current)
							del(I)

		if(red_follower_mind.current)
			if(red_follower_mind.current.client)
				for(var/image/I in red_follower_mind.current.client.images)
					if(I.icon_state == "follower-red" || I.icon_state == "prophet-red")
						del(I)

//Blue

/datum/game_mode/proc/update_blue_follower_icons_removed(datum/mind/blue_follower_mind)
	spawn(0)
		for(var/datum/mind/blue_prophet_mind in blue_prophets)
			if(blue_prophet_mind.current)
				if(blue_prophet_mind.current.client)
					for(var/image/I in blue_prophet_mind.current.client.images)
						if((I.icon_state == "follower-blue" || I.icon_state == "prophet-blue") && I.loc == blue_follower_mind.current)
							del(I)

		for(var/datum/mind/blue_follower_mind_1 in blue_followers)
			if(blue_follower_mind_1.current)
				if(blue_follower_mind_1.current.client)
					for(var/image/I in blue_follower_mind_1.current.client.images)
						if((I.icon_state == "follower-blue" || I.icon_state == "prophet-blue") && I.loc == blue_follower_mind.current)
							del(I)

		if(blue_follower_mind.current)
			if(blue_follower_mind.current.client)
				for(var/image/I in blue_follower_mind.current.client.images)
					if(I.icon_state == "follower-blue" || I.icon_state == "prophet-blue")
						del(I)
