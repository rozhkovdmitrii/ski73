$(document).ready(initManageCompetitions);

function initManageCompetitions() {
    $("#upload").ajaxForm({url: "/handlexls", success:onHandlexlsSuccess});
}

function onHandlexlsSuccess(response) {
    getCompetitions();
}
