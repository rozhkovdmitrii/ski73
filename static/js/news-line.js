function initNewsLine() {
    const secondsIn70years = 2209092480 - 86400;
    var secondsFrom1_1_1970 = window.now - secondsIn70years;
    var now = new Date(secondsFrom1_1_1970 * 1000);
    var monthAgo = new Date(now);
    monthAgo.addMonths(-1);
    var nowstamp = now.valueOf();
    var monthAgoStamp = monthAgo.valueOf();
    getNews(monthAgoStamp, nowstamp);
}

function getNews(from, to) {
    var newsBunchOptions = {
	type: "POST",
	data: { "from" : from,
		"to" : to},
	url: "news-banch",
	success: handleInitialNewsBanch,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(newsBunchOptions);
}


function handleInitialNewsBanch(data, textStatus, jqXHR) {
    var parsed = eval('(' + data + ')');
    var arr = objectToArray(parsed);
    arr = arr.sort(function(a, b) { return a.date < b.date; });
    $( "#news-line-tpt" ).tmpl( arr ).appendTo( "#news-render-target" );
}

