
function initCompetitionsView() {
    var options = {
	type: "POST",
	url: "competitions-list",
	success: processCompetitionsList,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(options);
}

/** Принимаем и обрабатываем список соревнований в виде троек [_id, title, date] */
function processCompetitionsList(data, textStatus) {
    data = eval("({competitions:" + data + "})");
    $("#competitionsList").html("");
    if (data.competitions == null) {
	return ;
    }
    data.competitions = data.competitions.sort(function(a, b) { return a.date < b.date; });
    var yearRanged = new Object();
    for (var key in data.competitions) {
    	var comp = data.competitions[key];
    	var compDate = lispTimestampToJS(comp.date);
    	var year = compDate.getFullYear();
    	if (!yearRanged.hasOwnProperty(year))
    	    yearRanged[year] = {year : year, competitions : []};
    	yearRanged[year].competitions.push(comp);
       
    }
    yearRanged = objectToArray(yearRanged).sort(function(a, b) { return a.year < b.year; });
    $( "#competitions-list-tpt" ).tmpl(  yearRanged ).prependTo("#competitionsList");
    $(".group-toggle:first").attr("collapsed", false);
}


function toggleYear(year) {
    var tgl = $("#tgl" + year);
    tgl.attr("collapsed", tgl.attr("collapsed") != "true");
}

function removeCompetition(id) {
    var options = {
	type: "POST",
	url: "remove-competition",
	data: { id : $.url.decode(id)},
	success: handleCompRemoving,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(options);

}

function handleCompRemoving(data, textStatus) {
    getCompetitions();
}