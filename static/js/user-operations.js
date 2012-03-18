function refreshAuthPanel(cu) {
    if (!cu)
	$("#topPanelContent").load("static/auth-form.html");
    else {
	$("#topPanelContent").html("<span id='email'>" + cu.email + "</span><span style='width:40px'></span>"
				   + "<a id='logoutlink' onclick='logout()' style='margin-left:50px'>Выйти</a>");
	
    }
    
}


function getCurrentUser() {
    $.ajax({
	    url : "current-user",
	    type : "POST",
	    success: function(data) {
		var cu = eval("(" + data + ")");
		// $(document).trigger({type : "userchanged", user : cu});
		document.cu = cu;
		refreshUserDependencies(cu);
	    },
            async: false,
	    error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
	});

}

function revertUser() {
    $.ajax({
	    url : "revert-user",
		type : "POST",
		success: function(data) {
		var cu = eval("(" + data + ")");
		document.cu = cu;
		$(document).trigger({type : 'userchanged', user : cu});
		refreshUserDependencies(cu); },
		error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
	});
}

function refreshUserDependencies(user) {
    $("#adminMenuItem").css("display", (user && user.type <= 2)?"list-item":"none");
    $("#profileMenuItem").css("display", user != null?"list-item":"none");
    $("#admin-dock").css("visibility", (user && user.type <= 2)?"visible":"hidden");
    $("#manage-moders").css("display", (user && 1 == user.type)?"list-item":"none");

    refreshAuthPanel(user);
}

/** Запрос панельки авторизации */
function getAuthPanel() {
    getCurrentUser();
}

/** Функция обработчик, результата авторизации */
function handleAuth(data) {
    //alert(data);return;
    var data = eval ('(' + data + ')');
    if (data.status == "done") {
	document.cu = data.user;
	refreshUserDependencies(data.user);
    } else {
	alert(data.error);
    }

}

/** Обработка юзера после авторизации */
function processUser(cu) {
    refreshAuthPanel();
}

function logout() {
    $.ajax({
	    url : "logout-from-site",
	    type : "POST",
	    success: function(data) {
		getCurrentUser();
	    },
	    error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
	});
}

