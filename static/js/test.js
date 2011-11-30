function handleNewsAdding(rawdata) {
    var data = eval( '(' + rawdata + ')');
    showNewsPieceApprove(data);
}

function pieceOfNewsView(pieceOfNews) {
    var directive = {
	".newsPieceTitle" : "title",
	".newsPieceMessage" : function (arg) { return $.url.decode(arg.context.message);},
	".newsPieceImageCell@style": function(arg) {
	    var display =  "display:" + (arg.context.image != null?"table-cell":"none");
	    return display;
	},
	".newsPieceImage@src" : function(arg) { return "static/tmp/" + arg.context.image; }
    };
    var template = $(window.newsPieceTpt);
    var tptFn = template.compile(directive);
    return tptFn(pieceOfNews);
}

function showNewsPieceApprove(newsPiece) {
    $("#news-piece").html(pieceOfNewsView(newsPiece));
    $("#approvePostDiv").show();
    $("#add-peace-of-news").hide();
}


function applyNewsPiece() {
   alert('apply piece of news');
}


function cancelNewsPieceApprove() {
    $("#approvePostDiv").hide();
    $("#add-peace-of-news").show();
}
