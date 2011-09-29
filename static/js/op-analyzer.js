function analyzeGET () {
    var queryData = new QueryData();
    if (queryData.hasOwnProperty("op")) {
	setNewUser(queryData.key);
    }
}