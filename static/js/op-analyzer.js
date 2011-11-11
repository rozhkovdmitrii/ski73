function analyzeGET () {
    var queryData = new QueryData();
    if (queryData.hasOwnProperty("op")) {
	var op = queryData.op;
	if (op == "video") {
	    getVideo();
	} else {
	    setNewUser(queryData.key);
	}
    }
}