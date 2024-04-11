/procvars
	var/name as text
	var/desc as text
	var/category as text
	var/invisibility as num


var/list/categoryaliases = list(
	"Preferences" = "PREFS",
	"Emotions" = "EMOTES",
	"Mecha" = "VEHICLE",
	"Spacepod" = "VEHICLE",
	"AI Commands" = "AI",
	"Robot Commands" = "ROBOT"
)

/client
	var/datum/fancyverbs/fancyverbs
	var/fancyverbs_loaded = 0

/client/proc/refreshvars()
	if(!fancyverbs)
		return
	var/list/fvs = list(
		"STATUS" = list(),
		"MC" = list(),
		"IC" = list(),
		"OOC" = list(),
		"AI" = list(),
		"ROBOT" = list(),
		"VEHICLE" = list(),
		"EMOTES" = list(),
		"PREFS" = list(),
		"ADMIN" = list(),
		"SERVER" = list(),
		"FUN" = list(),
		"DEBUG" = list(),
		"MISC" = list()
	)

	var/list/procvar_list = list()
	var/list/vehicle_list = list()

	for(var/a in verbs | mob.verbs)
		var/procvars/v = a
		procvar_list[a] = v
	if(istype(mob.loc, /obj))
		var/obj/A = mob.loc
		for(var/a in A.verbs)
			var/procvars/v = a
			procvar_list[a] = v
			vehicle_list += v
	for(var/a in procvar_list)
		var/procvars/v = procvar_list[a]
		if(!v.category || v.category == "Object")
			continue
		if(v.invisibility == TRUE)
			continue
		var/category = (v.category in categoryaliases) ? categoryaliases[v.category] : uppertext(v.category)
		if(category in fvs)
			fvs[category][uppertext(v.name)] = "?callverb[(a in vehicle_list) ? "vehicle" : ""]=[a]"
		else
			fvs["MISC"][uppertext(v.name)] = "?callverb[(a in vehicle_list) ? "vehicle" : ""]=[a]"

	src << output(list2json(fvs), "browserinfo:BYONDRedrawVerbs")

/client/Topic(href, href_list, hsrc)
	. = ..()
	if(href_list["callverb"])
		sound_to(src, 'sound/uibutton.ogg')
		for(var/a in verbs)
			if("[a]" == href_list["callverb"])
				call(src, a)()
		for(var/a in mob.verbs)
			if("[a]" == href_list["callverb"])
				call(mob, a)()
	if(istype(mob.loc, /atom))
		var/atom/A = mob.loc
		if(href_list["callverbvehicle"])
			for(var/a in A.verbs)
				if("[a]" == href_list["callverbvehicle"])
					call(A, a)()

/datum/fancyverbs
	var/client/host

/datum/fancyverbs/New(client/C)
	host = C
	C.fancyverbs = src

	var/datum/asset/stuff = get_asset_datum(/datum/asset/simple/fancyverbs)
	stuff.send(C)

	show_browser(C, file('code/modules/fancyverbs/resources/fancyverbs.html'), "window=browserinfo")

/datum/asset/simple/fancyverbs
	verify = TRUE
	assets = list(
	"fancyverbs.js" = 'code/modules/fancyverbs/resources/fancyverbs.js',
	"fancyverbs.html" = 'code/modules/fancyverbs/resources/fancyverbs.html',
	"fancyverbs.css" = 'code/modules/fancyverbs/resources/fancyverbs.css',
	"scanlines.png" = 'code/modules/fancyverbs/resources/scanlines.png',
	"STATUS.png" ='code/modules/fancyverbs/resources/images/STATUS.png',
	"ADMIN.png" = 'code/modules/fancyverbs/resources/images/ADMIN.png',
	"DEBUG.png" = 'code/modules/fancyverbs/resources/images/DEBUG.png',
	"EMOTES.png" = 'code/modules/fancyverbs/resources/images/EMOTES.png',
	"IC.png" = 'code/modules/fancyverbs/resources/images/IC.png',
	"ROBOT.png" = 'code/modules/fancyverbs/resources/images/ROBOT.png',
	"AI.png" = 'code/modules/fancyverbs/resources/images/AI.png',
	"MISC.png" = 'code/modules/fancyverbs/resources/images/MISC.png',
	"OOC.png" = 'code/modules/fancyverbs/resources/images/OOC.png',
	"PREFS.png" = 'code/modules/fancyverbs/resources/images/PREFS.png',
	"SERVER.png" = 'code/modules/fancyverbs/resources/images/SERVER.png',
	"VEHICLE.png" = 'code/modules/fancyverbs/resources/images/VEHICLE.png',
	"FUN.png" = 'code/modules/fancyverbs/resources/images/FUN.png',
	"MC.png" = 'code/modules/fancyverbs/resources/images/MC.png',
	"C64.eot" = 'code/modules/fancyverbs/resources/C64.eot',
	)



/datum/fancyverbs/proc/setStatus(var/message)
	message = url_encode(url_encode(message))
	host << output("[message]", "browserinfo:setStatusTab")

/datum/fancyverbs/proc/setMC(var/message)
	message = url_encode(url_encode(message))
	host << output("[message]", "browserinfo:setMCTab")

/datum/fancyverbs/proc/playuisound()
	sound_to(host, 'sound/uibutton.ogg')

/datum/fancyverbs/proc/show_fancyverbs()
	host.fancyverbs_loaded = 1
	host.refreshvars()

/datum/fancyverbs/Topic(href, href_list)
	. = ..()
	if(href_list["fancyverbs_loaded"])
		show_fancyverbs()
	if(href_list["playuisound"])
		playuisound()