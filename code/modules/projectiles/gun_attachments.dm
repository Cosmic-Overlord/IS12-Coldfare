//Gun attachable related flags.
#define ATTACH_REMOVABLE	1
#define ATTACH_ACTIVATION	2
#define ATTACH_PROJECTILE	4 //for attachments that fire bullets
#define ATTACH_RELOADABLE	8
#define ATTACH_WEAPON		16 //is a weapon that fires stuff
#define ATTACH_MELEE        32 //This attachment should activate if you attack() with it attached.

/obj/item/attachable
	icon = 'icons/obj/gun_attachments.dmi'
	icon_state = "grip"
	w_class = ITEM_SIZE_SMALL
	force = 0 //Don't try killing people with attachments please.
	var/attach_icon = null //the sprite to show when the attachment is attached when we want it different from the icon_state.
	var/pixel_shift_x = 16 //Determines the amount of pixels to move the icon state for the overlay.
	var/pixel_shift_y = 16 //Uses the bottom left corner of the item.
	var/slot = null //"muzzle", "rail", "under", "stock", "special"
	var/flags_attach_features = ATTACH_REMOVABLE
	var/bipod_deployed = FALSE //only used by bipod
	var/light_mod = null

	var/recoil_control = 0 //This number will be subtracted from the base disp_mod variable. The higher this number is, the less recoil you will have.
	var/accuracy_modifier = 0 //This number is added to your base accuracy. The higher this number is, the more accurate at range you will be.
	var/draw_speed = 0 //This number is how quick in deciseconds you will be able to draw your gun from it's slot. Kinda silly but whatever.
	var/hipfire_mod = 0 //This number will be subtracted from the base hipfire_accuracy variable. The higher this number is, the less dispersion on hipfire you will have.
	var/delay_mod = 0 //This number effects how fast you can shoot the gun in non automatic mode. The higher this number is, the quicker you can shoot.
	var/weight_mod = 0 //Adds slowdown to the weapon when equipped in your hands.
	var/screen_shake_mod = 0 //Reduces the screenshake of the weapon, simulates more "recoil control".


/obj/item/attachable/proc/Attach(var/obj/item/gun/G, mob/user)
	if(!istype(G)) return //Guns only

	/*
	This does not check if the attachment can be removed.
	Instead of checking individual attachments, I simply removed
	the specific guns for the specific attachments so you can't
	attempt the process in the first place if a slot can't be
	removed on a gun. can_be_removed is instead used when they
	try to strip the gun.
	*/
	if(G.attachments[slot])
		var/obj/item/attachable/A = G.attachments[slot]
		A.Detach(G, user)

	if(ishuman(loc))
		var/mob/living/carbon/human/M = src.loc
		M.drop_item(src)
	forceMove(G)

	G.attachments[slot] = src
	G.recalculate_attachment_bonuses()
	G.slowdown_per_slot[slot_l_hand] += weight_mod
	G.slowdown_per_slot[slot_r_hand] += weight_mod

/obj/item/attachable/proc/Detach(var/obj/item/gun/G, mob/user)
	if(!istype(G)) return //Guns only

	G.attachments[slot] = null
	G.recalculate_attachment_bonuses()

	forceMove(get_turf(G))
	user.put_in_hands(src)
	G.update_attachables()
	G.slowdown_per_slot[slot_l_hand] -= weight_mod
	G.slowdown_per_slot[slot_r_hand] -= weight_mod




/obj/item/gun/proc/update_attachables() //Updates everything. You generally don't need to use this.
	overlays.Cut()
	if(attachable_offset) //Even if the attachment doesn't exist, we're going to try and remove it.
		for(var/slot in attachments)
			var/obj/item/attachable/R = attachments[slot]
			if(!R) continue
			update_attachment_overlays(R, R.slot)

/obj/item/gun/proc/update_attachable(attachable) //Updates individually.
	if(attachable_offset && attachments[attachable])
		update_attachment_overlays(attachments[attachable], attachable)

/obj/item/gun/proc/update_attachment_overlays(var/obj/item/attachable/A, slot)
	var/image/I = attachable_overlays[slot]
	overlays -= I
	qdel(I)
	if(A) //Only updates if the attachment exists for that slot.
		var/item_icon = A.icon_state
		if(A.attach_icon)
			item_icon = A.attach_icon
		I = image(A.icon,src, item_icon)
		I.pixel_x = attachable_offset["[slot]_x"] - A.pixel_shift_x
		I.pixel_y = attachable_offset["[slot]_y"] - A.pixel_shift_y
		attachable_overlays[slot] = I
		overlays += I
	else attachable_overlays[slot] = null



/obj/item/gun/proc/can_attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(attachable_allowed && !(attachment.type in attachable_allowed) )
		to_chat(user, SPAN_WARNING("[attachment] doesn't fit on [src]!"))
		return 0

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	if(attachments[attachment.slot])
		var/obj/item/attachable/R = attachments[attachment.slot]
		if(R && !(R.flags_attach_features & ATTACH_REMOVABLE))
			to_chat(user, SPAN_WARNING("The attachment on [src]'s [attachment.slot] cannot be removed!"))
			return 0
	//to prevent headaches with lighting stuff
	if(attachment.light_mod)
		for(var/slot in attachments)
			var/obj/item/attachable/R = attachments[slot]
			if(!R)
				continue
			if(R.light_mod)
				to_chat(user, SPAN_WARNING("You already have a light source attachment on [src]."))
				return 0
	return 1

/obj/item/gun/proc/attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(!can_attach_to_gun(user, attachment))
		return

	user.visible_message(SPAN_NOTICE("[user] begins attaching [attachment] to [src]."),
	SPAN_NOTICE("You begin attaching [attachment] to [src]."), null, 4)
	if(do_after(user, 20))
		if(attachment && attachment.loc)
			user.visible_message(SPAN_NOTICE("[user] attaches [attachment] to [src]."),
			SPAN_NOTICE("You attach [attachment] to [src]."), null, 4)
			user.drop_from_inventory(attachment)
			attachment.Attach(src, user)
			update_attachable(attachment.slot)
			playsound(user, 'sound/items/attachment_add.ogg', 25)

/obj/item/gun/proc/recalculate_attachment_bonuses()

	disp_buildup = initial(disp_buildup)
	accuracy = initial(accuracy)
	time_to_unequip = initial(time_to_unequip)
	hipfire_accuracy = initial(hipfire_accuracy)
	screen_shake = initial(screen_shake)

	//Add attachment bonuses
	for(var/slot in attachments)
		var/obj/item/attachable/R = attachments[slot]
		if(!R) continue
		disp_buildup -= R.recoil_control
		accuracy += R.accuracy_modifier
		time_to_unequip -= R.draw_speed
		hipfire_accuracy -= R.hipfire_mod
		screen_shake -= R.screen_shake_mod
		/*
		fire_delay += R.delay_mod
		accuracy_mult += R.accuracy_mod
		accuracy_mult_unwielded += R.accuracy_unwielded_mod
		scatter += R.scatter_mod
		scatter_unwielded += R.scatter_unwielded_mod
		damage_mult += R.damage_mod
		damage_falloff_mult += R.damage_falloff_mod
		damage_buildup_mult += R.damage_buildup_mod
		effective_range_min += R.range_min_mod
		effective_range_max += R.range_max_mod
		recoil += R.recoil_mod
		burst_scatter_mult += R.burst_scatter_mod
		burst_amount += R.burst_mod
		recoil_unwielded += R.recoil_unwielded_mod
		aim_slowdown += R.aim_speed_mod
		wield_delay += R.wield_delay_mod
		movement_acc_penalty_mult += R.movement_acc_penalty_mod
		force += R.melee_mod
		w_class += R.size_mod

		if(R.silence_mod)
			flags_gun_features |= GUN_SILENCED
			muzzle_flash = null
			fire_sound = "gun_silenced"
		*/


/obj/item/gun/proc/field_strip(mob/living/user)
	if(!istype(user))
		return

	if(!istype(user.get_active_hand(), src))
		return

	if(zoom)
		to_chat(user, SPAN_WARNING("You cannot conceviably do that while looking down \the [src]'s scope!"))
		return

	var/list/possible_attachments = list()
	for(var/slot in attachments)
		var/obj/item/attachable/R = attachments[slot]
		if(R && (R.flags_attach_features & ATTACH_REMOVABLE))
			possible_attachments += R

	if(!possible_attachments.len)
		to_chat(user, SPAN_WARNING("[src] has no removable attachments."))
		return

	var/obj/item/attachable/A
	if(possible_attachments.len == 1)
		A = possible_attachments[1]
	else
		A = input("Which attachment to remove?") as null|anything in possible_attachments

	if(!A || user.get_active_hand() != src || zoom || (!(A == attachments[A.slot])) || !(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	user.visible_message(SPAN_NOTICE("[user] begins stripping [A] from [src]."),
	SPAN_NOTICE("You begin stripping [A] from [src]."), null, 4)

	if(!do_after(user, 35))
		return

	if(!(A == attachments[A.slot]))
		return
	if(!(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	if(zoom)
		return

	user.visible_message(SPAN_NOTICE("[user] strips [A] from [src]."),
	SPAN_NOTICE("You strip [A] from [src]."), null, 4)
	A.Detach(src, user)

	playsound(src, 'sound/items/attachment_remove.ogg', 25)
	update_icon()

/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A vertical foregrip that offers less recoil, and less scatter, especially during burst fire. \nHowever, it also increases weapon weight."
	icon_state = "verticalgrip_icon"
	attach_icon = "verticalgrip"
	slot = "under"
	recoil_control = 1
	weight_mod = 1
	screen_shake_mod = 0.5

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight. A zero magnification optic that offers faster, and more accurate target aquisition."
	icon_state = "reddot_icon"
	attach_icon = "reddot"
	slot = "rail"
	accuracy_modifier = 6
	weight_mod = 0.5

/obj/item/attachable/holosight
	name = "holosight"
	desc = "It's like a reddot sight but cooler."
	icon_state = "holosight_icon"
	attach_icon = "holosight"
	slot = "rail"
	accuracy_modifier = 6
	weight_mod = 0.5

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight that attaches to the underside of most weapons. Increases your hip fire capacities, and makes aiming faster and easier."
	icon_state = "laser_icon"
	attach_icon = "laser"
	slot = "special"
	draw_speed = 2
	hipfire_mod = 1
	w_class = ITEM_SIZE_TINY

/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "An angled foregrip that improves weapon ergonomics and offers less recoil, and faster wielding time. \nHowever, it also increases weapon weight."
	icon_state = "angledgrip_icon"
	attach_icon = "angledgrip"
	slot = "under"
	recoil_control = 0.5
	weight_mod = 0.5
	screen_shake_mod = 0.5
	w_class = ITEM_SIZE_TINY