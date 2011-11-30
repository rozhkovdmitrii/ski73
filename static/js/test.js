function handleNewsAdding(rawdata) {
    var data = eval( '(' + rawdata + ')');
    var cbConf = {
	html : peaceOfNewsView({ ggbb : "bbgg"}) ,
	title : "Предварительный просмотр новостного поста",
	width : "80%",
	height : "80%"
    };
    $.colorbox(cbConf);
}

function peaceOfNewsView(peaceOfNews) {
    var directive = {"#ggbb" : "title"};
    var template = $("<div><div id='ggbb'></div></div>");
    var tptFn = template.compile(directive);
    return tptFn({title : "Вот такая вот виговина"});
}
