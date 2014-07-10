/datum/game_mode/
	var/list/datum/mind/red_gods = list()
	var/list/datum/mind/red_prophets = list()
	var/list/datum/mind/red_followers = list()

	var/list/datum/mind/blue_gods = list()
	var/list/datum/mind/blue_prophets = list()
	var/list/datum/mind/blue_followers = list()

//	var/list/datum/mind/neutral_gods = list()
//	var/list/datum/mind/neutral_prophets = list() //for admin abuse if I ever get around to it.
//	var/iist/datum/mind/neutral_followers = list()

	var/list/datum/mind/unassigned_followers = list() //for roundstart team assigning
	var/list/datum/mind/assigned_to_red = list() //we will be a red follower after the game starts.
	var/list/datum/mind/assigned_to_blue = list() //ditto for blue team.

/datum/game_mode/handofgod
	name = "hand of god"
	config_tag = "handofgod"
	antag_flag = BE_FOLLOWER

	required_players = 1	//Recommended: 20-25+
	required_enemies = 0 	//This MUST be an even number to function properly.  This number counts
							//all enemy players involved, as in both teams combined.  Recommended: 8
							//If you want to test something by yourself, set to zero.  Note that you will produce one unavoidable
							//runtime due to an empty list being pick()'d.
	recommended_enemies = 2

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
		log_game("[follower.key] (ckey) has been selected as a follower.")
		world << "recommended_enemies = [recommended_enemies]"
//	return (unassigned_followers.len>=required_enemies)

//	var/team_cap = required_enemies / 2

	do
		var/chosen = pick_n_take(unassigned_followers)
		add_red_follower(chosen)
		world << "[chosen] was made a red follower."
	while(unassigned_followers.len > (required_enemies / 2))

	do
		var/chosen = pick_n_take(unassigned_followers)
		add_blue_follower(chosen)
		world << "[chosen] was made a blue follower."
	while(unassigned_followers.len > 0)
	return 1

/*
	for(var/team_cap = 0, team_cap == 3, team_cap ++)
		if(unassigned_followers.len == 3)
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

	for(var/team_cap = 0, team_cap == 3, team_cap ++)
		if(unassigned_followers.len == 0)
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
*/
//////////////
//Post Setup//
//////////////

/datum/game_mode/handofgod/post_setup() //Icons don't work properly at roundstart, hacky but it works.
	update_all_red_follower_icons()
	update_all_blue_follower_icons()

	var/datum/mind/chosen_red = pick(red_followers) //this makes one of the followers a god.
	chosen_red.current.apotheosis("red")
	ticker.mode.forge_deity_objectives(chosen_red)
	remove_follower(chosen_red,0)
	add_red_god(chosen_red)

	var/datum/mind/chosen_blue = pick(blue_followers) //ditto
	chosen_blue.current.apotheosis("blue")
	ticker.mode.forge_deity_objectives(chosen_blue)
	remove_follower(chosen_blue,0)
	add_blue_god(chosen_blue)

///////////////////
//Objective Procs//
///////////////////

/datum/game_mode/proc/forge_deity_objectives(var/datum/mind/deity) //fresh hot copypasta
	switch(rand(1,100))
		if(1 to 30)

			var/datum/objective/deicide/deicide_objective = new
			deicide_objective.owner = deity
			deicide_objective.find_target()
			deity.objectives += deicide_objective

			if (!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit_objective = new
				recruit_objective.owner = deity
				deity.objectives += recruit_objective
				recruit_objective.gen_amount_goal(8, 12)
		if(31 to 60)
			var/datum/objective/sacrifice_prophet/sacrifice_objective = new
			sacrifice_objective.owner = deity
			deity.objectives += sacrifice_objective

			if (!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit_objective = new
				recruit_objective.owner = deity
				deity.objectives += recruit_objective
				recruit_objective.gen_amount_goal(8, 12)

		if(61 to 85)
			var/datum/objective/build/build_objective = new
			build_objective.owner = deity
			deity.objectives += build_objective
			build_objective.gen_amount_goal(8, 16)

			var/datum/objective/sacrifice_prophet/sacrifice_objective = new
			sacrifice_objective.owner = deity
			deity.objectives += sacrifice_objective

			if (!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit_objective = new
				recruit_objective.owner = deity
				deity.objectives += recruit_objective
				recruit_objective.gen_amount_goal(8, 12)

		else
			if (!(locate(/datum/objective/follower_block) in deity.objectives))
				var/datum/objective/follower_block/block_objective = new
				block_objective.owner = deity
				deity.objectives += block_objective
	return

///////////////
//Greet procs//
///////////////

/datum/game_mode/proc/greet_red_follower(var/datum/mind/red_follower_mind, var/you_are=1) //is this even used?
	if (you_are)
		red_follower_mind.current << "<span class='danger'><B>You are a follwer of the cult of   !</span>"//todo: find way to get god name to show here

/datum/game_mode/proc/greet_blue_follower(var/datum/mind/blue_follower_mind, var/you_are=1)
	if (you_are)
		blue_follower_mind.current << "<span class='danger'><B>You are a follwer of the cult of   !</span>"


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

/mob/living/carbon/human/verb/testconvert() //debug
	ticker.mode.add_red_follower(src.mind)

/mob/living/carbon/human/verb/resetredicons() //debug
	ticker.mode.update_all_red_follower_icons()

/datum/game_mode/proc/add_red_god(datum/mind/red_god_mind)
	red_gods += red_god_mind
	red_god_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been made into a red deity!</font>"
	red_god_mind.special_role = "Red Deity"

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
		H << "<span class='danger'>Your [N.name] prevented the deity from brainwashing you.</span>"
		return 0
	blue_followers += blue_follower_mind
	blue_follower_mind.current << "<span class='danger'>You are a follower of a newly created deity! You will now serve your cult to the death. You can identify your allies by the blue four sided star icons, and your prophet by the eight-sided blue and gold icon. Help them enforce your god's will on the station!</span>"
	blue_follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the blue follower cult!</font>"
	blue_follower_mind.special_role = "Blue Follower"
	update_blue_follower_icons_added(blue_follower_mind)
	return 1

/datum/game_mode/proc/add_blue_god(datum/mind/blue_god_mind)
	blue_gods += blue_god_mind
	blue_god_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been made into a blue deity!</font>"
	blue_god_mind.special_role = "Blue Deity"

//////////////////
//Deconvert proc//
//////////////////

/datum/game_mode/proc/remove_follower(var/datum/mind/follower_mind, var/announce = 1) //this deconverts both sides
/*	if(follower_mind in red_followers || follower_mind in blue_followers)
		red_followers -= follower_mind
		blue_followers -= follower_mind
		follower_mind.special_role = null
		if(announce == 0)
			follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been deconverted from a deity's cult!</font>"
			follower_mind.current << "<span class='danger'><b>Your mind has been cleared from the brainwashing the followers have done to you.  Now you serve yourself and the crew.</b></span>"
			for(var/mob/living/M in view(follower_mind.current))
				M << "[follower_mind.current] looks like they just remembered their real allegiance!"
		update_red_follower_icons_removed(follower_mind)
		update_blue_follower_icons_removed(follower_mind)
*/
	if(follower_mind in red_followers)
		red_followers -= follower_mind
		update_red_follower_icons_removed(follower_mind)
	if(follower_mind in blue_followers)
		blue_followers -= follower_mind
		update_blue_follower_icons_removed(follower_mind)

		if(announce == 1)
			follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been deconverted from a deity's cult!</font>"
			follower_mind.current << "<span class='danger'><b>Your mind has been cleared from the brainwashing the followers have done to you.  Now you serve yourself and the crew.</b></span>"
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

//////////////////////
//Roundend Reporting//
//////////////////////

/datum/game_mode/handofgod/declare_completion()
	..()
	return

/datum/game_mode/proc/auto_declare_completion_handofgod()
	if(red_gods.len)
		var/text = "<br><font size=3 color='red'><b>The red cult:</b></font>"
		for(var/datum/mind/red_god in red_gods)
			var/godwin = 1

			text += "<br><b>[red_god.key]</b> was the red deity, <b>[red_god.name]</b> ("
			if(red_god.current)
				if(red_god.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
			else
				text += "ceased existing"
			text += ")"
			if(red_prophets.len)
				for(var/datum/mind/red_prophet in red_prophets)
					text += "<br>The red prophet was <b>[red_prophet.name]</b> (<b>[red_prophet.key]</b>)"
			else
				text += "<br>The red prophet was killed for their beliefs."

			text += "<br><b>Red follower #:</b> [red_followers.len]"
			text += "<br><b>Red followers:</b> "
			for(var/datum/mind/player in red_followers)
				text += "[player.name], "


			var/objectives = ""
			if(red_god.objectives.len)//If the god had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in red_god.objectives)
					if(objective.check_completion())
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("god_objective","[objective.type]|SUCCESS")
					else
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("god_objective","[objective.type]|FAIL")
						godwin = 0
					count++

			text += objectives
/*
			var/special_role_text
			if(red_god.special_role)
				special_role_text = lowertext(red_god.special_role)
			else
				special_role_text = "antagonist"
*/

			if(godwin)
				text += "<br><font color='green'><B>The red cult was successful!</B></font>"
				feedback_add_details("god_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The red cult has failed!</B></font>"
				feedback_add_details("god_success","FAIL")

			text += "<br>"

		world << text

	if(blue_gods.len)
		var/text = "<br><font size=3 color='blue'><b>The blue cult:</b></font>"
		for(var/datum/mind/blue_god in blue_gods)
			var/godwin = 1

			text += "<br><b>[blue_god.key]</b> was the blue deity, <b>[blue_god.name]</b> ("
			if(blue_god.current)
				if(blue_god.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
			else
				text += "ceased existing"
			text += ")"

			if(blue_prophets.len)
				for(var/datum/mind/blue_prophet in blue_prophets)
					text += "<br>The blue prophet was <b>[blue_prophet.name]</b> (<b>[blue_prophet.key]</b>)"
			else
				text += "<br>The blue prophet was killed for their beliefs."

			text += "<br><b>Blue follower #:</b> [blue_followers.len]"
			text += "<br><b>Blue followers:</b> "
			for(var/datum/mind/player in blue_followers)
				text += "[player.name], "

			var/objectives = ""
			if(blue_god.objectives.len)//If the god had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in blue_god.objectives)
					if(objective.check_completion())
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("god_objective","[objective.type]|SUCCESS")
					else
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("god_objective","[objective.type]|FAIL")
						godwin = 0
					count++

			text += objectives
/*
			var/special_role_text
			if(blue_god.special_role)
				special_role_text = lowertext(blue_god.special_role)
			else
				special_role_text = "antagonist"
*/

			if(godwin)
				text += "<br><font color='green'><B>The blue cult was successful!</B></font>"
				feedback_add_details("god_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The blue cult has failed!</B></font>"
				feedback_add_details("god_success","FAIL")

			text += "<br>"

		world << text
	return 1