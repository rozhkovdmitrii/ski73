
$("head").append($("<link type='text/css' rel='stylesheet' href='static/css/rounds.css'/>"));

var roundsHelp = "На странице реализована интеллектуальная печать. Распечатаны будут только развернутые группы";
var expandHelp = "Развернуть все";
var collapseHelp = "Свернуть все";

function roundsView(rounds) {
    var template = $('<div>'
		     + "<table style='width:100%'><tr><td class='pageTitle'></td>"
			+"<td class='notPrint'>"
				+ "<img class='tool-img' id='expandAllImg' src='static/img/expand_all.png' onClick='expandAll()'/>"
				+ "<img class='tool-img' id='collapseAllImg' src='static/img/collapse_all.png' onClick='collapseAll()'/>"
				+ "<img class='tool-img' id='rounds-print-help' src='static/img/question.png' >"
		     + "</td></tr></table>"
		     + "<div class='round toggle-group-container'>"
		     + "<div class='group-toggle notPrint'><img src='static/img/expand.png'></div>"
		     + "<table class='round-table' style='display:none'>"
		       + "<tr class='capRow'><th></th></tr>"
		       + "<tr class='dataRow'></tr>"
		     + "</table>"
		     + "<div class='page-break'></div>"
		     + "</div> ");
    var directive = {
	'+.pageTitle': 'title',
	'#rounds-print-help@title' : function (arg) { return roundsHelp;},
	'#expandAllImg@title' : function (arg) { return expandHelp;},
	'#collapseAllImg@title' : function (arg) { return collapseHelp; },
	 '.round': {
	     'round<-rounds':{
	 	 '+.group-toggle':'round.group',
	 	 '.group-toggle@id': function (arg) { return "tgl" + arg.pos;},
	 	 '.group-toggle@onClick' : function (arg) { return "toggleRound(" + arg.pos + ");"; },
		 'table.round-table@id' : function (arg) { return "rnd" + arg.pos;},
		 
		 
		 'th' : {
		     "caption<-captions" : {
			 '.':'caption'
		     }
		 },
		 'tr.dataRow': {
	 	     "result<-round.results": {
	 		 '.' : function(arg) { return rowFromResult(arg.item); }
        	     }
	 	 }
		 
	     }
	}
	 
    };
    var rfn = template.compile(directive);
    var html = rfn(rounds);
    return html;
}

function toggleRound (pos) {
    var tbl = $("#rnd" + pos);
    if (tbl.css("display") == "none") 
	expandByIndex(pos);
    else 
	collapseByIndex(pos);
	
}

function expandByIndex(pos) {
    var tbl = $("#rnd" + pos);
    var tglImg = $("#tgl" + pos + "> img");
    tbl.show();
    tglImg.attr("src", collapseImg);
    $("#tgl" + pos).removeClass("notPrint");

}

function collapseByIndex(pos) {
    var tbl = $("#rnd" + pos);
    var tglImg = $("#tgl" + pos + "> img");
    tbl.hide();
    tglImg.attr("src", expandImg);
    $("#tgl" + pos).addClass("notPrint");

}
function rowFromResult(result) {
    var res = "";
    for (var i in result) {
	res += "<td>" + result[i] + "</td>";
    }
    return res;
}
function roundView(round) {
    var template
}

function expandAll() {
    $(".group-toggle").each(
			    function(index, element) {
				expandByIndex(index);
			    });
    //toggles.foreach(function(gg) {alert(gg);});
}

function collapseAll() {
    $(".group-toggle").each(
			    function(index, element) {
				collapseByIndex(index);
			    });
}
