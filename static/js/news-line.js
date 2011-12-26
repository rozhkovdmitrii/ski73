function initNewsLine() {
    const secondsIn70years = 2209092480 - 86400;
    var secondsFrom1_1_1970 = window.context.now - secondsIn70years;
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

function newsLineView(initialBunch) {

    var template = $(window.TF.get("news-line"));
    var directive = {
	".news-bunch" : function (arg) {
	    return newsBunchView({"news" : arg.context});
	}
    };
    var compiled = template.compile(directive);
    return compiled(initialBunch);

}


function newsBunchView(bunch) {
    var template = $(window.TF.get("news-bunch"));
    var directive = {
    	"." :  {
	    "newsPiece<-news" : {
		".news-piece" : function(arg) {
		    var content = newsPieceView(arg.item);
		    return content;
		}
	    }
	}
    };
    var compiled = template.compile(directive);
    return compiled(bunch);
}

function handleInitialNewsBanch(data, textStatus, jqXHR) {
    var parsed = eval('(' + data + ')');
    var newsContainer = $("#news");
    var size = Object.keys(parsed).length;
    newsContainer.html(newsLineView(parsed));
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