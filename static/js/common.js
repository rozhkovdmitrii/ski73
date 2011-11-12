function setUser(event) {
    document.cu = event.user;
}

function pushHistoryState(url) {
    //    if (window.history.hasOwnProperty('pushState'))
	history.pushState(null,null, url);
}