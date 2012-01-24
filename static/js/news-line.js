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

function objectToArray(object) {
    var arr = new Array();
    for(var k in object) {
	arr.push(object[k]);
    }
    return arr;

}

function handleInitialNewsBanch(data, textStatus, jqXHR) {
    var parsed = eval('(' + data + ')');
    var arr = objectToArray(parsed);
    arr = arr.sort(function(a, b) { return a.date < b.date; });
    $( "#news-line-tpt" ).tmpl( parsed ).appendTo( "#news-render-target" );
}

function newsPieceView(piece) {
    var template = $(window.TF.get("news-piece"));
    var directive = {
	".newsPieceTitle" : "title",
	".newsPieceMessage" : function (arg) { return $.url.decode(arg.context.message);},
	".newsPieceImageCell@style": function(arg) {
	    var display =  "width:200px;display:" + (arg.context.image != null?"table-cell":"none");
	    return display;
	},
	".newsPieceImage@src" : function(arg) { return "static/tmp/" + arg.context.image; }
    };
    var compiled = template.compile(directive);
    return compiled(piece);
}