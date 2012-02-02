function initCompetitionsView() {
    var options = {
	type: "POST",
	url: "competitions-list",
	success: processCompetitionsList,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(options);
}

function toggleYear(year) {

    var id = $("#year" + year);
    var tbl = $("#cmptts" + year);
    var tglImg = $("#tgl" + year + " > img");

    var proc = tbl.css("display") == "none"?expandYear:collapseYear;
    proc(tbl, tglImg, year);
}

function expandYear(tbl, tglImg, year) {
    tbl.show();
    tglImg.attr("src", collapseImg);
    $("#tgl" + year).removeClass("notPrint");

}

function collapseYear(tbl, tglImg, year) {
    tbl.hide();
    tglImg.attr("src", expandImg);
    $("#tgl" + year).addClass("notPrint");

}
