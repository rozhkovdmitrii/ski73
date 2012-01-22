function TemplatesFactory () {
    
    this.storage = new Object();

    this.test = function() {
    	alert("test");
    };


    this.getFromServer = function(name, callback) {

	if ('undefined' == typeof(callback)) callback = null;
    	var options = {
	    context : this,
    	    type: "POST",
    	    url: "static/tpt/" + name + ".html",
    	    error:function (XMLHttpRequest, textStatus, errorThrown) {alert(textStatus);}
    	};
    	if (null == callback)
    	    options.async = false;
    	options.success = function (data, textStatus, jqXHR) {
    	    this.storage[name] = data;
    	    if (callback) {
    		callback(data);
	    }
    	};
    	$.ajax(options);
    	return this.storage[name];
    };
    
    this.get = function(name) {
	return this.storage.hasOwnProperty(name)?this.storage[name]:this.getFromServer(name);
    };

    this.doWithTemplate = function(name, callback) {
    	if (storage.hasOwnProperty(name)) {
    	    callback(storage[name]);
    	}
    };
    
}