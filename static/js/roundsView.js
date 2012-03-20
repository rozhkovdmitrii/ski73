
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
		     + "<div class='group-toggle' collapsed=true><div></div>"
		     + "<a class='remove-link' style='margin-left:30px;font-size:10pt;'>Удалить</a></div>"
		     + "<table class='round-table'>"
		       + "<tr class='capRow'><th></th></tr>"
		       + "<tr class='dataRow'></tr>"
		     + "</table>"
		     + "</div> ");
    var directive = {
	'+.pageTitle': 'title',
	'#rounds-print-help@title' : function (arg) { return roundsHelp;},
	'#expandAllImg@title' : function (arg) { return expandHelp;},
	'#collapseAllImg@title' : function (arg) { return collapseHelp; },
	 '.round': {
	     'round<-rounds':{
	 	 '+.group-toggle': function (arg) { return arg.round.group + " - " + arg.round["round-type"];},
	 	 '.group-toggle@id': function (arg) { return "tgl" + arg.pos;},
	 	 '.group-toggle@onClick' : function (arg) { return "toggleRound(" + arg.pos + ");"; },
		 'table.round-table@id' : function (arg) { return "rnd" + arg.pos;},
		 '.remove-link@onClick' :
			function (arg) {
				return "removeRound('" + mongoHexId(arg.context._id) + "', '" + arg.item.group + "', '"
				+ arg.item.utime + "', event);"; },
		 '.remove-link@style+' : function (arg) { return (document.cu && document.cu.type < 3)?";display:block-inline":";display:none"},
		 
		 'tr.capRow' : roundCaptions,
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


function roundCaptions(pureArg) {
    var captions = pureArg.item.captions;
    var result = new String();
    for (var k in captions) {
	result += "<th>" + captions[k] + "</th>"; 
    }
    return result;
}

function toggleRound (pos) {
    var tgl = $("#tgl" + pos);
    tgl.attr("collapsed", tgl.attr("collapsed") != "true");
}

function rowFromResult(result) {
    var res = "";
    for (var i in result) {
	res += "<td>" + result[i] + "</td>";
    }
    return res;
}

function expandAll() {
    $(".group-toggle").attr("collapsed", false);
}

function collapseAll() {
    $(".group-toggle").attr("collapsed", true);
}

function removeRound(compId, group, utime, event) {
   var options = {
	type: "POST",
	url: "remove-round",
	data: { id : $.url.decode(compId),
		group : group,
		utime: utime },
       	success: function (data) {
	   data = eval('(' + data + ')');
	   getCompetition(compId);
       } ,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(options);
    event.stopPropagation();
}
