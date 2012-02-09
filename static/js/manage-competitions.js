$(document).ready(initManageCompetitions);

function initManageCompetitions() {
    var options = {
	url: "/handlexls"
	, success:onHandlexlsSuccess};
    $("#upload").ajaxForm(options);
}

function onHandlexlsSuccess(response) {
    getCompetitions();
}
