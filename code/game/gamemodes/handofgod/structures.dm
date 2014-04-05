/obj/structure/divine/
	name = "Divine Structure"
	desc = "Something went wrong if you can see this."
	icon = 'icons/mob/god.dmi'
	icon_state = "nexus"
	anchored = 1
	var/health = 100
	var/maxhealth = 100
	var/side = 0 //Which side owns the structure.
	var/heal_rate = 1 //How much health it heals per tick.  Set to zero to disable healing.



/obj/structure/divine/proc/validate_health() //Incase it overheals somehow
	if(health > maxhealth)
		health = maxhealth
		return

/obj/structure/divine/proc/checkhealth() //Checks if we should be dead.
	if(health <= 0)
		visible_message("<span class='danger'>The [src.name] was destroyed!</font>")
		qdel(src)
		return


/obj/structure/divine/attackby(var/obj/item/weapon/W, var/mob/user) //hot fresh copypasta for all your damage needs
	playsound(src.loc, W.hitsound, 50, 1)
	src.visible_message("<span class='danger'>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]!</span>")
	health -= W.force
	checkhealth()

/obj/structure/divine/bullet_act(var/obj/item/projectile/Proj)
	health -=Proj.damage
	checkhealth()

/obj/structure/divine/attack_animal(mob/living/simple_animal/M as mob)
	src.visible_message("<span class='danger'>The [src.name] has been attacked by \the [M]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage) // Avoid divide by zero errors
		return
	health -= damage
	checkhealth()
	return

/obj/structure/divine/nexus
	name = "Nexus"
	icon_state = "nexus"
	desc = "It anchors a deity to this world.  It radiates an unusual aura.  Cultists protect this at all costs.  It looks well protected from explosive shock."
	health = 500
	maxhealth = 500

	/obj/structure/divine/nexus/ex_act() //Prevent cheesing the round by a shitty scientist
		return

/obj/structure/divine/conduit
	name = "Conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	health = 150
	maxhealth = 150

/obj/structure/divine/forge
	name = "Forge"
	desc = "A forge fueled by divine might, it allows the creation of sacred and powerful artifacts.  It requires common materials to craft objects."
	health = 250
	maxhealth = 250

/obj/structure/divine/convertalter //todo: make desc reflect the god's name.
	name = "Conversion Alter"
	desc = "An alter dedicated to a deity.  Cultists can \"forcefully teach\" their non-aligned crewmembers to join their side and take up their deity."

/obj/structure/divine/sacrificealter
	name = "Sacrifical Alter"
	desc = "An alter designed to perform blood sacrifice for a deity.  The cultists performing the sacrifice will gain a powerful material to use in their forge.  Sacrificing a prophet will yield even better results."

/obj/structure/divine/puddle
	name = "Puddle of Healing"
	desc = "Cultists standing close to this blessed puddle will be healed."
	health = 50
	maxhealth = 50

/obj/structure/divine/gate
	name = "Gateway"
	desc = "A portal kept stable, it allows cultists to move to any other gateway they control."
	health = 50
	maxhealth = 50

/obj/structure/divine/powerpylon
	name = "Power Pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	health = 30
	maxhealth = 30

/obj/structure/divine/defensepylon
	name = "Defense Pylon"
	desc = "A plyon which is blessed to withstand many blows, and fire strong bolts at nonbelivers."
	health = 150
	maxhealth = 150

/obj/structure/divine/shrine
	name = "Shrine to " //todo: add name of god here.
	desc = "A shrine dedicated to a deity."