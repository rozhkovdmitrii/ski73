function initAll() {
    getServerContext();
    window.TF = new TemplatesFactory();
}

function setUser(event) {
    document.cu = event.user;
}

function pushHistoryState(url) {
    history.pushState(null, null, url);
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
    window.now = parsed.now;
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
    var excludes = {"'" : "\\'", "\n" : "\\n", "\t" : "\\t", "\r" : "\\r"};

    var strId = new String();
    var plusByCode = function(el, index, arr) {
	var curCh = String.fromCharCode(el);
	var otherCh = "%" + el.toString(16);
	if (excludes.hasOwnProperty(curCh)) 
	    curCh = excludes[curCh];
	return strId += curCh;
    };
    mid.raw.forEach(plusByCode);
    return strId;
}

function mongoHexId(mid) {
    var strId = new String();
    var plusByCode = function(el, index, arr) {
	var curCh = String.fromCharCode(el);
	return strId += curCh;
    };
    mid.raw.forEach(plusByCode);
    return $.url.encode(strId);
}


/** Перевод строки из внутреннего представления таймстэмпа lisp в javascript */
function lispTimestampToJS(lispTS) {
    const secondsIn70years = 2209092480 - 172800;
    var jsTS = (lispTS - secondsIn70years) * 1000;
    var jsDate = new Date(jsTS);
    return jsDate;
}

/** Очень полезно когда что-то приходит как объект который надо преобразовать в массив
    , например, для сортировки при помощи sort */
function objectToArray(object) {
    var arr = new Array();
    for(var k in object) {
	arr.push(object[k]);
    }
    return arr;
}


const expandImg = "static/img/expand.png";
const collapseImg = "static/img/undo.png";

