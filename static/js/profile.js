function resetProfileFormTools() {
    $("#edit-profile-form").ajaxForm({url: "/apply-profile", type:"POST", success:profileHandler});
    createUploader();
}


function handleUserChangedInProfile(event) {
    if (event.hasOwnProperty("user"))
    	fillEditProfileForm(event.user);
    resetProfileFormTools();
 }

function fillEditProfileForm(user) {
    if (!user) return;
    var directive = {
	'#email' : function(arg) {
	    return "Профиль - " + arg.context.email;
	},
	'#surname@value' : 'surname',
	'#patronimic@value' : 'patronimic',
	'#name@value' : 'name',
	'#birthDate@value' : 'birthDate',
	'#moder@checked' : 'moderRqst',
	'#city@value' : 'city',
	'#info' : 'info'
    };
    $('#editprofile').render(user, directive);
    $('#rank').val(user.rank);
    $('#club').val(user.club);
    if (user.hasOwnProperty("photo"))
	$('#user-photo').attr("src", "static/photo/" + user.photo + "?" + (new Date()).getTime());
   
}

function createUploader(){            
    var uploader = new qq.FileUploader({
	    element: document.getElementById('file-uploader-demo1'),
	    action: 'set-photo-with-valums',
	    debug: true,

	    // validation    
	    // ex. ['jpg', 'jpeg', 'png', 'gif'] or []
	    allowedExtensions: ['jpg', 'jpeg', 'png'],        
	    // each file size limit in bytes
	    // this option isn't supported in all browsers
	    sizeLimit: 1000000, // max size   
	    minSizeLimit: 0, // min size

	    // set to true to output server response to console
	    //debug: false,

	    // events         
	    // you can return false to abort submit
	    onSubmit: function(id, fileName){
	    },
	    onProgress: function(id, fileName, loaded, total){ },
	    onComplete: function(id, fileName, responseJSON){ 
		handleUserChangedInProfile({user : responseJSON.user});
		//$('#edit-profile-form').trigger({type : 'userchanged', user : responseJSON.user});
	    },
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

function profileHandler(rawdata) {
    var resp = eval("(" + rawdata + ")");
    $("#prfl-event-source").trigger({type : "userchanged", user : resp});
}