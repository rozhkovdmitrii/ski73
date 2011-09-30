
/** Дизяблит форму регистрации туда и обратно */
function toggleRegForm(jqXHR, settings) {
    var elements = $("#submitReg, #email, #pwdinput, #confirminput");
    var disabled = elements.attr("disabled");
    $("#regwait").css("display", disabled?"none":"block");
    $("#regstatic").css("display", disabled?"block":"none");
    elements.attr("disabled", !disabled);
}

/** Запрос на создание нового юзера по ключу */
function setNewUser(key) {
    $.ajax({
	type: "POST",
	data: { "key" : key },
	url: "registration-approve",
	success: processRegistrationResult,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    });
}

/** Обработка ответа на запрос создания юзера */
function processRegistrationResult(data, textStatus) {
    var data = eval("(" + data + ")");
    alert(data.status == 'error'?"Ошибка регистрации: " + data.error:"Регистрация прошла успешно\nПриветствуем вас на нашем сайте!");
}


function handleFirstReg(data) {
    toggleRegForm();
    data = eval ( '(' + data + ')' );
    alert (data.status == "done"?data.message:"Регистрация не прошла. " + data.error);
}

function checkRegForm(){
    var pwdInput = $('#pwdinput');//document.getElementById('pwdInput');
    var confirmInput = $('#confirminput');//document.getElementById('confirmInput');
    var email = $('#email');
    var goodColor = "#66cc66";
    var badColor = "#ff6666";
    var pwdmatch = pwdInput.attr("value").length >= 5 && pwdInput.attr("value") == confirmInput.attr("value");
    var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;  

    var emlmatch = emailPattern.test(email.attr("value"));
    confirmInput.css("backgroundColor", pwdmatch?goodColor:badColor);
    $('#emailConfirmation').html(emlmatch?"":"Введеный email некорректен").css("color", emlmatch?goodColor:badColor);
    $('#emlConfirmImg').attr("src", emlmatch?"static/img/mailMatch.png":"static/img/mailDismatch.png")
	.css("visibility", "visible");
    $('#confirmMessage').css("color", pwdmatch?goodColor:badColor).html(pwdmatch?"":"Пароли должны совпадать и быть не короче 5 символов");
    
    var allRight = pwdmatch && emlmatch;


    $('#submitReg').attr('disabled', !allRight);
    
}


