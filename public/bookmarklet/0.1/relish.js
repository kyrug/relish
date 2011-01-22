(function(){
 	var relish_url = "http://localhost:3000/bookmarks/new";
	var title = document.title;
	var url = document.location.href;
	document.location.href = relish_url + "?title=" + escape(title) +
	                                      "&url=" + escape(url) +
					      "&goback=1";
})()
