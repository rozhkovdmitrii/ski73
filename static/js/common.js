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

/** Получаем строку из в которой хранятся 12 байт mongo id-шника для передачи в запросе */
function mongoId(mid) {
    var strId = new String();
    var plusByCode = function(el, index, arr) {
	return strId += String.fromCharCode(el);
    };
    mid.raw.forEach(plusByCode);
    return strId;
}


/** Перевод строки из внутреннего представления таймстэмпа lisp в javascript */
function lispTimestampToJS(lispTS) {
    const secondsIn70years = 2209092480 - 86400;
    var jsTS = (lispTS - secondsIn70years) * 1000;
    var jsDate = new Date(jsTS);
    return jsDate.toDateString();
}

function evaluate(item) {
    var ggbb = 0;
    var bbgg = 1;
    return "asdf";
}