/datum/game_mode/handofgod
	name = "handofgod"
	config_tag = "handofgod"
	antag_flag = BE_DEITY

	required_players = 30
	required_enemies = 8
	recommended_enemies = 8

	restricted_jobs = list("Cyborg", "AI")

/datum/game_mode/announce()
	world << "<B>The current game mode is - Hand of God!</B>"
	world << "<B>Two cults are onboard the station, seeking to overthrow the other, and anyone who stands in their way.</B>"