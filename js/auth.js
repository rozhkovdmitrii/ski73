
$(document).ready(function() {
	$("#auth-form").ajaxForm({url: "/process-auth", type:"POST", success:handleAuth});
    });

/** Функция обработчик, результата авторизации */
function handleAuth(data) {
    alert(data);return;
    document.currentUser =  eval ('(' + data + ')');
    processCurrentUser();

}


function processCurrentUser() {
    if (!document.currentUser)
	return;
    var cu = document.currentUser;
    alert(cu.name + ' ' + cu.password);
    $("#adminMenuItem").css("display", cu.type <= 2?"list-item":"none");
}