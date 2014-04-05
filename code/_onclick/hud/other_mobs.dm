
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	return

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0

/datum/hud/proc/ai_hud()
	return

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen_midnight.dmi')

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)

/datum/hud/proc/god_hud()

	deity_power_display = new /obj/screen()
	deity_power_display.name = "faith points"
	deity_power_display.icon_state = "deity_power"
	deity_power_display.screen_loc = ui_internal
	deity_power_display.layer = 20

	deity_health_display = new /obj/screen()
	deity_health_display.name = "nexus health"
	deity_health_display.icon_state = "deity_nexus"
	deity_health_display.screen_loc = ui_health
	deity_health_display.layer = 20

	deity_follower_display = new /obj/screen()
	deity_follower_display.name = "followers"
	deity_follower_display.icon_state = "deity_followers"
	deity_follower_display.screen_loc = ui_nutrition
	deity_follower_display.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(deity_power_display, deity_health_display, deity_follower_display)