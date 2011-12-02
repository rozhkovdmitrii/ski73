function handleNewsAdding(rawdata) {
    var data = eval( '(' + rawdata + ')');
    showNewsPieceApprove(data);
}

function pieceOfNewsView(pieceOfNews) {
    var directive = {
	".newsPieceTitle" : "title",
	".newsPieceMessage" : function (arg) { return $.url.decode(arg.context.message);},
	".newsPieceImageCell@style": function(arg) {
	    var display =  "width:200px;display:" + (arg.context.image != null?"table-cell":"none");
	    return display;
	},
	".newsPieceImage@src" : function(arg) { return "static/tmp/" + arg.context.image; }
    };
    var template = $(window.newsPieceTpt);
    var tptFn = template.compile(directive);
    return tptFn(pieceOfNews);
}

function visibleClass(propName) {
    return function(arg) {
	var c = arg.context[propName]?"block":"none";
	return c;
    }
}

function newsPiecePropsView(pieceOfNews) {
    var directive = {
	"#sms@class": visibleClass("sms-flag"),
	"#sms-text": "sms",
	"#site-post@class" : visibleClass("site-post-flag"),
	"#email@class": visibleClass("email-flag")
    };
    var template = $(window.newsPiecePropsTpt);
    var tptFn = template.compile(directive);
    return tptFn(pieceOfNews);
}

function showNewsPieceApprove(newsPiece) {
    $("#news-piece").html(pieceOfNewsView(newsPiece));
    $("#news-piece-props").html(newsPiecePropsView(newsPiece));
    $("#approvePostDiv").show();
    $("#add-piece-of-news").hide();
}


function applyNewsPiece() {
    var applySubmitConfig = {
	url: "approve-piece-of-news",
	type:"post",
	data: {
	    "approved": "on"
	},
	success:function(responseText, statusText) { alert("Пост проведен" + responseText); }
    };
    $("#add-piece-of-news").ajaxSubmit(applySubmitConfig);
}


function cancelNewsPieceApprove() {
    $("#approvePostDiv").hide();
    $("#add-piece-of-news").show();
}

function checkNewsAddForm(formData, jqForm, options) {
    $("#title-label, #sms-label, #message-label, #title-image-label").removeClass("ui-state-error");
    var res = true;
    var message = $("#message").val().trim();
    if ( message ==  "<br>" || message == "") {
	$("#message-label").addClass("ui-state-error");
	res = false;
    }

    if ($("#title").val().trim() == "") {
	$("#title-label").addClass("ui-state-error");
	res = false;
    }

    if ($("#sms-flag").attr("checked") == "checked" && $("#short-message").val().trim() == "") {
	$("#sms-label").addClass("ui-state-error");
	res = false;
    }
    var files = $("#title-image").get()[0].files;
    if (files.length != 0
	&& (files[0].size > 500000 || files[0].size < 100000
	    || !files[0].type.match(/image\/\(jpg|jpeg|png|gif\)/) )) {
	$("#title-image-label").addClass("ui-state-error");
	alert("Разрешены форматы jpeg, gif, png. Размер файла не должен превышать 500кБ и быть меньше 100кБ");
	res = false;
    }

    return res;
}



