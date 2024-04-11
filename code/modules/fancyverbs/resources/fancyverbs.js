var escaper = encodeURIComponent || escape;
var currentTab = "STATUS";
var statusTab = "<h1>Loading...</h1>";
var MCTab = "";

var verbs = {};

function runByond(url) {
	window.location = url;
}

function byondDecode(message) {
	// Basically we url_encode twice server side so we can manually read the encoded version and actually do UTF-8.
	// The replace for + is because FOR SOME REASON, BYOND replaces spaces with a + instead of %20, and a plus with %2b.
	// Marvelous.
	message = message.replace(/\+/g, "%20");
	try {
		// This is a workaround for the above not always working when BYOND's shitty url encoding breaks. (byond bug id:2399401)
		if (decodeURIComponent) {
			message = decodeURIComponent(message);
		} else {
			throw new Error("FA")
		}
	} catch (err) {
		message = unescape(message);
	}
	return message;
}

function setStatusTab(message){
	if(!message){
		message = "";
	}
	message = byondDecode(message).trim();
	if(message == statusTab){
		return
	}
	statusTab = message;
	redrawCategories();
	redrawVerbs("STATUS")
}

function setMCTab(message){
	if(!message){
		message = "";
	}
	message = byondDecode(message).trim();
	if(message == MCTab){
		return
	}
	MCTab = message;
	redrawCategories();
	redrawVerbs("MC")
}

function BYONDRedrawVerbs(json){
	verbs = JSON.parse(json)
	redrawCategories();
	redrawVerbs(currentTab);
}

function redrawCategories(){
	var box = document.getElementById("selectCategory");
	box.innerHTML = ""
	for(var category in verbs){
		if(!Object.keys(verbs[category]).length && category != "STATUS" && category != "MC"){
			continue
		}
		if(category == "MC"){
			if(!MCTab)
				continue
		}
		var entry = document.createElement("img")
		$(entry).attr('onClick', 'changeTab("'+category+'");');
		$(entry).addClass('category');
		$(entry).attr('src', category + '.png')
		box.appendChild(entry)
	}
}

function changeTab(category){
	if(currentTab == category){
		return
	}
	runByond('?_src_=fancyverbs&playuisound=1');
	currentTab = category;
	redrawVerbs(category)
}

function setCustomHTML(contents){
	var box = document.getElementById("verbs");
	var new_div = document.createElement('div');
	$(new_div).attr('class', 'customHTML');
	new_div.innerHTML = contents;
	box.innerHTML = ""
	box.appendChild(new_div)
}

function redrawVerbs(category){
	var alternate = true;
	var box = document.getElementById("verbs");
	if(currentTab != category)
		return
	box.innerHTML = "";
	if(currentTab == "STATUS"){
		setCustomHTML(statusTab);
		return
	}
	if(currentTab == "MC"){
		setCustomHTML(MCTab);
		return
	}
	for(var verb in verbs[currentTab]){

		var name = verb;
		var link = verbs[currentTab][verb];

		var dive = document.createElement('div');
		var ae = document.createElement('a');

		ae.innerHTML = name
		alternate = !alternate

		$(ae).attr("href", link)

		if(alternate) {
			$(ae).addClass("alt");
		}
		else {
			$(ae).addClass("default");
		}

		dive.appendChild(ae);
		$(dive).addClass("verb");
		box.appendChild(dive);
	}
}

function doneloading(){
	runByond('?_src_=fancyverbs&fancyverbs_loaded=1');
}


// open hyperlinks in browser, but byond links in byond
document.onclick = function (e) {
	e = e ||	window.event;
	var element = e.target || e.srcElement;

	if (element.tagName == 'A') {
		var href = $(element).attr("href");
		$(element).addClass("visited")
		if (href[0] == '?' || (href.length >= 8 && href.substring(0,8) == 'byond://')) {
			runByond(href);
		} else {
			href = escaper(href);
			runByond('?action=openLink&link='+href);
		}
		return false; // prevent default action and stop event propagation
	}
};

window.onerror = function(msg, url, linenumber) {
    alert('Error message: '+msg+'\nURL: '+url+'\nLine Number: '+linenumber);
    return true;
}

doneloading();