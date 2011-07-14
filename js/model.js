document.write('<link rel="stylesheet" type="text/css" href="scripts/model/model.css"/>');
//URL к php-скрипту для обработки фотографий
scriptURL = "core/imageResize.php";
if (document.URL.indexOf("mode=local") != -1)
    {
	scriptURL = "http://proxy.mercury/imageResize.php";
    }
function PhotoViewer(images, modelName) {
    this.minWidth = 500;
    this.minThumbWidth = 85;
    this.minWidthStr = this.minWidth.toString() + "px";
    this.rowCellWidth = 60;
    this.rowCellWidthStr = this.rowCellWidth.toString() + "px";
    this.tableWidth = this.minWidth + this.rowCellWidth;
    this.tableWidthstr = (this.minWidth + this.rowCellWidth).toString() + "px";
    this.currentPhotoFileName = 'photoIsAbsent.jpg';
    this.images = images;
    this.current = 0
	modelName = 'Стиральная машина';
    this.modelName = modelName;
    this.setNext = function() {
	this.current = this.current + 1;
	this.update();
    };
    this.setPrev = function() {
	this.current = this.current -1;
	this.update();
    };
    window.photoViewer = this;
    this.reinit = function(imagesSet, modelName) {
	this.images = imagesSet;
	this.current = 0;
	this.modelName = modelName;
	this.update();
	return this;
    }
    this.update = function() {
	$('#photosViewerTable #currentPhoto').attr('src', scriptURL + '?file=upload/'
						   + this.images[this.current].file_name + '&hLimit=500&vLimit=450');
	$('#photosViewerTable #prevLnkBtn').attr('disabled', !this.current);
	$('#nextLnkBtn').attr('disabled', this.current >= this.images.length -1);
	return this;
    }
    this.getImagePath = function(imageIndex) {
	return scriptURL + '?file=upload/'
	+ this.images[imageIndex].file_name + '&hLimit='+this.minThumbWidth+'&vLimit=85';
    }
    this.getImagePathBig = function(imageIndex) {
	return scriptURL + '?file=upload/'
	+ this.images[imageIndex].file_name + '&hLimit='+this.minWidth+'&vLimit=450';
    }
    this.getAbsoluteImagePath = function(imageIndex) {
	return 'upload/' + this.images[imageIndex].file_name;
    }
    this.panel = function() {
	var tpl;
	var directive;
	if (this.images.length > 1) {
	    tpl =
		"<div id='gallery' class='content'>"
		+ "<div id='controls' class='controls'></div>"
		+ "<div class='slideshow-container'>"
		+ "<div id='loading' class='loader'></div>"
		+ "<div id='slideshow' class='slideshow'></div>"
		+ "</div>"
		+ "<div id='caption' class='caption-container'></div>"
		+ "</div>"
		+ "</div>"
		+ "<div id='thumbs' class='navigation'>"
		+ "<ul class='thumbs noscript'>";
	    for(var i = 0; i < this.images.length; i++) {
		tpl += "<li>"
		    + "<a class='thumb' name='leaf' href='"
		    + this.getImagePathBig(i)
		    + "' title='"+this.modelName+"'>"
		    + "<img src='"
		    + this.getImagePath(i)
		    + "' alt='"+this.modelName+"'/>"
		    + "</a>"
		    + "<div class='caption'>"
		    + "<div class='download'>"
		    + "<a target='_blank' href='"
		    + this.getAbsoluteImagePath(i)
		    + "'>Скачать оригинал</a>"
		    + "</div>"
		    + "<div class='image-title'>Изображение "+ (i+1) +" из "+this.images.length+"</div>"
		    + "</div>"
		    + "</li>";
	    }
	    tpl += "</ul></div>";
	    tpl += "<div class='colorPanel'><table width='100%' border='0' cellpadding='0' cellspacing='5' height='45px'>"
		+ "<thead>"
		+ "<tr><td colspan='5' class='colorCellHeader'>Цвет фона</td></tr>"
		+ "</thead>"
		+ "<tr>"
		+ "<td class='colorCell' style='background-color:#FFF;'>&nbsp;</td>"
		+ "<td class='colorCell' style='background-color:#000;'>&nbsp;</td>"
		+ "<td class='colorCell' style='background-color:#82B4ED;'>&nbsp;</td>"
		+ "<td class='colorCell' style='background-color:#F28D8D;'>&nbsp;</td>"
		+ "<td class='colorCell' style='background-color:#CCCCCC;'>&nbsp;</td>"
		+ "</tr></table></div>";
	} else {
	    tpl =
	    "<div id='gallery' class='content'>"
	    + "<div class='slideshow-container'>"
	    + "<div id='loading' class='loader'></div>"
	    + "<div id='slideshow' class='slideshow'></div>"
	    + "</div>"
	    + "<div id='caption' class='caption-container'></div>"
	    + "</div>"
	    + "</div>"
	    + "<div id='thumbs' class='navigation'>"
	    + "<ul class='thumbs noscript'>";
	    for(var i = 0; i < this.images.length; i++) {
		tpl += "<li>"
		    + "<a class='thumb' name='leaf' href='"
		    + this.getImagePathBig(i)
		    + "' title='"+this.modelName+"'>"
		    + "<img src='"
		    + this.getImagePath(i)
		    + "' alt='"+this.modelName+"'/>"
		    + "</a>"
		    + "<div class='caption'>"
		    + "<div class='download'>"
		    + "<a target='_blank' href='"
		    + this.getAbsoluteImagePath(i)
		    + "'>Скачать оригинал</a>"
		    + "</div>"
		    + "<div class='image-title'>Изображение "+ (i+1) +" из "+this.images.length+"</div>"
		    + "</div>"
		    + "</li>";
	    }
	    tpl += "</ul></div>";
	    tpl += "<div class='colorPanel'><table width='100%' border='0' cellpadding='0' cellspacing='5' height='45px'>"
	    + "<thead>"
	    + "<tr><td colspan='5' class='colorCellHeader'>Цвет фона</td></tr>"
	    + "</thead>"
	    + "<tr>"
	    + "<td class='colorCell' style='background-color:#FFF;'>&nbsp;</td>"
	    + "<td class='colorCell' style='background-color:#000;'>&nbsp;</td>"
	    + "<td class='colorCell' style='background-color:#82B4ED;'>&nbsp;</td>"
	    + "<td class='colorCell' style='background-color:#F28D8D;'>&nbsp;</td>"
	    + "<td class='colorCell' style='background-color:#CCCCCC;'>&nbsp;</td>"
	    + "</tr></table></div>";
	}
	var content = tpl;
	var pvbf = new BaseFunctions();
	pvbf.message(content, 'Фотографии модели: \'' + this.modelName + "'. Количество фотографий: " + this.images.length, '80%');
	return this;
    };
}
function Model(struct) {
    this.struct = struct;
    this.message = function() {
	alert('message');
    }
    this.struct.photos = 0;
    eval('window.model' + this.struct.id + " = this;");
    this.photosPanel = function() {
	var modelName = this.struct.name;
	$.ajax({
		type:'post',
		    url:'core/class/rdsClasses/models/Photos.php',
		    data: [{name:'func', value:'getPhotos'}, {name:'mid', value:this.struct.id}],
		    timeout:4000,
		    success: function(data) {
		    var datastr = eval('(' + data + ')');
		    if (datastr.state == 'exception') {
			bf.message(data.message);
		    } else if (datastr.state == 'ok') {
			if (!datastr.photos.length)
			    return false;
			window.photoViewer.reinit(datastr.photos, modelName).panel();
		    }
		},
		    error: function() {
		    alert('Ошибка загрузки фотографий модели');
		}
	    });
    }
    var rowTemplate = "<div class='modelRowDiv'><table cellspacing='10' class='modelRow'>"+
	"<tr>"+
	"<td colspan=2 class='modelLabelHeader'></td>"+
	"</tr>"+
	"<tr>"+
	"<td class='photoCell link'><a><img class='photo'>"
	+'<p class="allPhotosLink">Просмотреть все фотографии</p>'
	+"</a></td>"+
	"<td style='padding-left:40px;width:100%;'>"+
	"<div class='description'><span class='smallCaption'></span><p class='modelDescription'></p></div>"+
