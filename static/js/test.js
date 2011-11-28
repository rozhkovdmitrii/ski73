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
	&& (files[0].size > 500000
	    || !files[0].type.match(/image\/\(jpg|jpeg|png|gif\)/) )) {
	$("#title-image-label").addClass("ui-state-error");
	alert("Разрешены форматы jpeg, gif, png. Размер файла не должен превышать 500кБ");
	res = false;
    }

    return res;
}


