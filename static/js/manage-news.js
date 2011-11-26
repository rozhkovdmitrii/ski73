function handleNewsAdding(rawdata) {
    alert("handle news adding\n" + rawdata);
}


$(document).ready(function() {

	$('#send').click(function(){   uploader._onInputChange(file_input);}); 


	$("#add-peace-of-news").ajaxForm({
		url: "add-peace-of-news",
		    type:"POST",
		    success:handleNewsAdding,
		    beforeSubmit:checkNewsAddForm});

	$('#sms-flag, #itscomp').change(function() {
		$("#sms-text-cont").css("display", $("#sms-flag").attr("checked") != "checked"?"none":"block");
		$("#online-reg-cont").css("display", $("#itscomp").attr("checked") != "checked"?"none":"inline-block");
	    });

	var cleditorconfig = {
	    width : 620,
	    controls: 	    "bold italic underline strikethrough subscript superscript | font size " +
	    "style | color highlight removeformat | bullets numbering | outdent " +
	    "indent | alignleft center alignright justify | undo redo | " +
	    "rule image link unlink | cut copy paste pastetext | print source"

	}
	$("#message").cleditor(
		cleditorconfig
	    );
    });


