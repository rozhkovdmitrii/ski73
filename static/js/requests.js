
var cmpttList = new Array();


/** Получаем строку из в которой хранятся 12 байт mongo id-шника для передачи в запросе */
function mongoId(mid) {
    var strId = new String();
    var plusByCode = function(el, index, arr) {
	return strId += String.fromCharCode(el);
    };
    mid.raw.forEach(plusByCode);
    return strId;
}

/** Запрашиваем главную страничку */
function getMain() {
    $('#mainframe').load("static/main.html");
}

/** Запрашиваем меню */
function getMenu() {
    $('#dock-menu').load("static/doc-menu.html", getCurrentUser);
}

/** Запрашиваем админку */
function getAdminPage() {
    $('#mainframe').load('static/competitionUpload.html');
}

/** Запрос формы регистрации */
function getRegistrationForm() {
    $("#mainframe").load("static/registration-form.html");
}

/**Запрос формы профиля*/
function getProfile() {
    $("#mainframe").load("static/edit-profile.html");
}

/** Запрашиваем список соревнований */
function getCompetitions() {
    $.ajax({
	type: "GET",
	url: "competitions-list",
	success: processCompetitionsList,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    });
};

/** Принимаем и обрабатываем список соревнований в виде троек [_id, title, date] */
function processCompetitionsList(data, textStatus) {
    data = eval("({competitions:" + data + "})");
    var d1 = {
	'li':{
	   "curr<-competitions": {
	      'a':"curr.title"
	       ,'a@onClick':function(arg) { cmpttList[arg.pos] = arg.item; return "getCompetition(" + arg.pos + ");" }
	    }
     	}
    };
    var rfn = $('<ul><li><a style="cursor: pointer;" class="competitionLink"></a></li></ul>').compile(d1);
    $('#mainframe').html("<div id='competitions-list'></div>");
    $('#competitions-list').render(data, rfn);

    
}
/** Запрашиваем соревнование по его идентификатору */
function getCompetition(id) {
    $.ajax({
	type: "POST",
	data: { "id" : mongoId(cmpttList[id]._id) },
	url: "competition-info",
	success: processCompetition,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    });
}

/** Принимаем и обрабатываем данные по конкретному соревнованию */
function processCompetition(data, textStatus) {
    var rounds = eval ("(" + data + ")");
    $('#mainframe').html(roundsView(rounds));
    $('.tool-img').simpletooltip();
    
}

function getClubs(callback) {
    $.ajax({
	type: "POST",
	data: { "id" : mongoId(cmpttList[id]._id) },
	url: "club-list",
	success: callback,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    });
}