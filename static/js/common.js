function initAll() {
    getServerContext();
    window.TF = new TemplatesFactory();
}

function setUser(event) {
    document.cu = event.user;
}


function pushHistoryState(url) {
    history.pushState(null,null, url);
}

function getServerContext() {
    var options = {
	type: "POST",
	url: "context",
	async : false,
	success: handleServerContext,
	error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    };
    $.ajax(options);
}

function handleServerContext(data, textStatus, jqXHR) {
    var parsed = eval("(" + data + ")");
    window.context = parsed;
}

function createFileUploader(id, action, conf){
    if (!conf) conf = {};
    var uploader = new qq.FileUploader({
	    element: document.getElementById(id),
	    action: action,
	    debug: false,
	    allowedExtensions: ['jpg', 'jpeg', 'png'],        
	    sizeLimit: conf.hasOwnProperty("sizeLimit")?conf.sizeLimit:1000000, // max size   
	    minSizeLimit: 0, // min size

	    onSubmit: function(id, fileName){ },
	    onProgress: function(id, fileName, loaded, total){ },
	    onComplete: conf.hasOwnProperty("onComplete")
		?conf.onComplete: function(id, fileName, responseJSON){ alert("Default fileUploader success handler"); }, 
	    onCancel: function(id, fileName){ },

	    messages: {
		typeError: "{file} Имеет неправильный тип. Допустимы типы {extensions}.",
		sizeError: "Размер файла {file} не должен превышать {sizeLimit}.",
		minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
		emptyError: "{file} is empty, please select files again without it.",
		onLeave: "The files are being uploaded, if you leave now the upload will be cancelled."            
		// error messages, see qq.FileUploaderBasic for content            
	    }
        });           
}
