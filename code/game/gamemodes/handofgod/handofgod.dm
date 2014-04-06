/datum/game_mode/
	var/list/datum/mind/red_prophets = list()
	var/list/datum/mind/red_followers = list()

	var/list/datum/mind/blue_prophets = list()
	var/list/datum/mind/blue_followers = list()

/datum/game_mode/handofgod
	name = "hand of god"
	config_tag = "handofgod"
	antag_flag = BE_DEITY

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
