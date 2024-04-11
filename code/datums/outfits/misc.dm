/decl/hierarchy/outfit/standard_space_gear
	name = "Standard space gear"
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/space
	suit = /obj/item/clothing/suit/space
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath
	flags = OUTFIT_HAS_JETPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/soviet_soldier
	name = "Soviet soldier"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/ushanka
	gloves = /obj/item/clothing/gloves/thick/combat
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/gun/projectile/revolver/mateba

/decl/hierarchy/outfit/soviet_soldier/admiral
	name = "Soviet admiral"
	head = /obj/item/clothing/head/hgpiratecap
	l_ear = /obj/item/device/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/thermal/plain/eyepatch
	suit = /obj/item/clothing/suit/hgpirate

	id_slot = slot_wear_id
	id_type = /obj/item/card/id/centcom/station
	id_pda_assignment = "Admiral"

/decl/hierarchy/outfit/merchant
	name = "Merchant"
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/color/grey
	id_slot = slot_wear_id
	id_type = /obj/item/card/id/merchant
	pda_slot = slot_r_store
	pda_type = /obj/item/device/pda/chef //cause I like the look
	id_pda_assignment = "Merchant"

/decl/hierarchy/outfit/merchant/vox
	name = "Merchant - Vox"
	shoes = /obj/item/clothing/shoes/jackboots/unathi
	uniform = /obj/item/clothing/under/vox/vox_robes
	suit = /obj/item/clothing/suit/armor/vox_scrap

/decl/hierarchy/outfit/clown
	name = "Clown"
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_ear =  /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/rank/clown
	l_pocket = /obj/item/bikehorn
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/clown/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack] = /obj/item/storage/backpack/clown

/decl/hierarchy/outfit/job/redsoldier/warptrooper // for admin bullshittery, use 'select equipment' in fun menu
	name = "WARP TROOPER FOUR SIX SMUG"
	suit = /obj/item/clothing/suit/armor/redcoat/warp
	gloves = /obj/item/clothing/gloves/warp
	mask = /obj/item/clothing/mask/gas/warp
	back = /obj/item/tank/oxygen/warp
	gloves = /obj/item/clothing/gloves/warp
	shoes = /obj/item/clothing/shoes/jackboots/warp
	suit_store = /obj/item/gun/projectile/automatic/m22/warmonger/fully_auto

// WARP CORPS WARP CORPS! :smug: FOUR SIX :smug: //

/obj/item/tank/oxygen/warp
	name = "Warp Corps oxygen tank"
	desc = "Has patriotic bands of red showing you exactly where to shoot. Oxygen is good for humans stuck in the Warp. You're not sure if it's better or worse to stay alive longer if you get stuck out there."
	icon_state = "warptank"

/obj/item/clothing/mask/gas/warp // inherits blockhair looks funny but works so whatever
	name = "Warp Corps mask"
	desc = "A closed-cycle mask. Why can't people just hold their breath anymore?"
	icon_state = "warpmask"
	item_state = "warpmask"

/obj/item/clothing/gloves/warp
	name = "Warp Corps gloves"
	desc = "Cheap synthleather gloves. It's rumoured the first battle Warp Corps were deployed in was only five minutes long before the Blusnian officers were dead and their bunker was razed."
	icon_state = "warpgloves"

/obj/item/clothing/shoes/jackboots/warp
	name = "Warp Corps boots"
	desc = "Boots so cheap, you won't feel bad if you can't return them."
	icon_state = "warpboots"

/obj/item/clothing/suit/armor/redcoat/warp
	name = "46th Warpborne suit"
	desc = "A tight fitting flightsuit, marking you as part of the 46th Warpborne. Recently concieved, it's said these brave 'volunteers' will win the Cold Hot War! FOUR SIX!"
	icon_state = "warpsuit"