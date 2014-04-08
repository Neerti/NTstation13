/datum/game_mode/
	var/list/datum/mind/red_prophets = list()
	var/list/datum/mind/red_followers = list()

	var/list/datum/mind/blue_prophets = list()
	var/list/datum/mind/blue_followers = list()

	var/list/datum/mind/neutral_prophets = list() //for admin abuse
	var/iist/datum/mind/neutral_followers = list()

/datum/game_mode/handofgod
	name = "hand of god"
	config_tag = "handofgod"
	antag_flag = BE_CULTIST //deities are handled seperately

	required_players = 25 //6-8 followers total, everyone else is crew
	required_enemies = 6 //three red, three blue
	recommended_enemies = 8

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

/datum/game_mode/handofgod/pre_setup() //this only works for red followers atm
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
		red_followers += follower //todo: add blue followers too
		log_game("[follower.key] (ckey) has been selected as a red follower")

	return (red_followers.len>=required_enemies)

///////////////
//Greet procs//
///////////////

/datum/game_mode/proc/greet_red_follower(var/datum/mind/red_follower_mind, var/you_are=1)
//	var/obj_count = 1
	if (you_are)
		red_follower_mind.current << "<span class='danger'><B>You are a follwer of the cult of   !</span>"//todo: find way to get god name to show here
//	for(var/datum/objective/objective in red_follower_mind.objectives) //followers don't actually get objectives, the god does.
//		red_follower_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
//		red_follower_mind.special_role = "Red Follower"
//		obj_count++

/////////////////////
//++Convert procs++//
/////////////////////

/datum/game_mode/proc/add_red_follower(var/datum/mind/red_follower_mind) //adds a follower
	var/mob/living/carbon/human/H = red_follower_mind.current//Check to see if the potential follower is implanted
	if(isloyal(H))
		return 0
	if((red_follower_mind in red_followers) || (red_follower_mind in red_prophets) || (red_follower_mind in blue_followers) || (red_follower_mind in blue_prophets)) //sanity
		return 0
	red_followers += red_follower_mind
	red_follower_mind.current << "<span class='danger'>You are now a follower of ! You will now serve your cult to the death. You can identify your allies by the red four sided star icons, and your prophet by the eight-sided red and gold icon. Help them enforce your god's will on the station!</span>"
	red_follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the red follower cult!</font>"
	red_follower_mind.special_role = "Red Follower"
	update_red_follower_icons_added(red_follower_mind)
	return 1

///////////////////////////
//++Follower icon procs++//
///////////////////////////

/////////////////////////////////
//Red follower update all icons//
/////////////////////////////////

//remember that plural means it's the list, singular is the var defined inside the proc.

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


///////////////////////////////////
//Red follower update icons added//
///////////////////////////////////

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

/////////////////////////////////////
//Red follower update icons removed//
/////////////////////////////////////

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