/obj/item/gun/launcher/rocket
	name = "rocket launcher"
	desc = "MAGGOT."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = ITEM_SIZE_HUGE
	throw_speed = 2
	throw_range = 10
	force = 5.0
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = 0
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 5)
	fire_sound = 'sound/effects/bang.ogg'
	combustion = 1

	release_force = 15
	throw_distance = 30
	var/max_rockets = 1
	var/list/rockets = new/list()

/obj/item/gun/launcher/rocket/examine(mob/user)
	if(!..(user, 2))
		return
	to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")

/obj/item/gun/launcher/rocket/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			user.drop_item()
			I.loc = src
			rockets += I
			to_chat(user, "<span class='notice'>You put the rocket in [src].</span>")
			to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")
		else
			to_chat(usr, "<span class='warning'>\The [src] cannot hold more rockets.</span>")

/obj/item/gun/launcher/rocket/consume_next_projectile()
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new (src)
		M.primed = 1
		rockets -= I
		return M
	return null

/obj/item/gun/launcher/rocket/handle_post_fire(mob/user, atom/target)
	log_and_message_admins("fired a rocket from a rocket launcher ([src.name]) at [target].")
	..()



///////////////////////////////////////////////////////////////////////////////////
////////////////// RPG7
//////////////////////////////////////////////////////////////////////////////////
/obj/item/gun/projectile/rocket/rpg7
	name = "RPG7"
	desc = "A rocket propelled grenade launcher. Useful for blowing holes in buildings and cover."
	icon = 'icons/obj/gun48.dmi'
	icon_state = "rpg"
	item_state = "rpg1"
	slowdown_general = 0.5
	w_class = 5
	throw_speed = 3
	one_hand_penalty = 100
	throw_range = 5
	force = 3
	max_shells = 1
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 5)
	fire_sound = 'sound/weapons/gunshot/rpg_fire.ogg'
	slot_flags = SLOT_S_STORE | SLOT_BACK
	ammo_type = /obj/item/ammo_casing/rpg_missile
	var/datum/effect/effect/system/smoke_spread/puff

/obj/item/gun/projectile/rocket/rpg7/New()
	..()
	puff = new /datum/effect/effect/system/smoke_spread()
	puff.attach(src)
	update_icon()

/obj/item/gun/projectile/rocket/rpg7/update_icon()
	..()
	if(chambered)
		icon = 'icons/obj/gun48.dmi'
		icon_state = "rpg7"
		item_state = "rpg1"
	else
		icon = 'icons/obj/gun48.dmi'
		icon_state = "rpg7-empty"
		item_state = "rpg1-empty"
	update_held_icon()


/obj/item/gun/projectile/rocket/rpg7/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rpg_missile))
		if(!chambered)
			playsound(src,'sound/weapons/guns/interact/rpgreload.ogg',80, 0)
			if(do_after(usr, 30, src))
				user.drop_item()
				I.forceMove(src)
				chambered = I
				update_icon()
		else
			to_chat(user, "<span class='warning'> [src] cannot hold more rockets.</span>")
			update_icon()


/obj/item/gun/projectile/rocket/rpg7/handle_post_fire(mob/user, atom/target)
	sleep(1)
	var/smoke_dir = user.dir
	if(user)
		switch(smoke_dir) //We want the opposite of their direction.
			if(2,8)
				smoke_dir /= 2
			if(1,4)
				smoke_dir *= 2
	puff.set_up(1,,,smoke_dir)//This is awful.
	puff.start()
	if(chambered)
		qdel(chambered)
		chambered = null


/obj/item/ammo_casing/rpg_missile
	name = "RG-7"
	desc = "A regular morkovka for rpg"
	caliber = "7p16"
	icon_state = "rg-7"
	projectile_type = /obj/item/projectile/bullet/rgprocket/he
	w_class = 4
	slot_flags = null
	drop_sound = null

/obj/item/ammo_casing/rpg_missile/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_casing))
		return
	..()


/obj/item/projectile/bullet/rgprocket
	name = "rpg shell"
	icon_state = "rocket"
	damage = 200
	speed = 1
	penetrating = 0
	range = 40
	speed = 1
	fire_sound = null//here we gonna use sound in AGS and not in bullets

/obj/item/projectile/bullet/rgprocket/he
	name = "high explosive rocket"

/obj/item/projectile/bullet/rgprocket/he/on_impact(var/atom/target, var/blocked = 0)
	explosion(target, 1, 3, 5, 6)
	if(istype(target, /obj/structure))
		qdel(src)
	else if(istype(target, /turf/simulated/wall/concrete))
		qdel(src)