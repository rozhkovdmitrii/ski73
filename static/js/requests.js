
var cmpttList = new Array();

/** Запрашиваем главную страничку */
function getMain() {
    $('#mainframe').load("static/main.html");
}

/** Запрашиваем меню */
function getMenu() {
    $('#dock-menu').load("static/doc-menu.html", getCurrentUser);
}

/** Запрашиваем админку */
function getAdminPage(query) {
    $('#mainframe').load('static/admin.html?op=manage-news');
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
    $('#mainframe').load("static/competitions-list-view.html");
};

/** Запрашиваем соревнование по его идентификатору */
function getCompetition(id) {
    $.ajax({
	type: "POST",
	data: { "id" : $.url.decode(id) },
	url: "competition-info",
	success: processCompetition,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    });
}

/** Принимаем и обрабатываем данные по конкретному соревнованию */
function processCompetition(data, textStatus) {
    var rounds = eval ("(" + data + ")");
    $('#mainframe').html(roundsView(rounds));
    
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

function getVideo() {
    $("#mainframe").load("static/video.html");
}