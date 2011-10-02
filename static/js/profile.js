function fillEditProfileForm(user) {
    if (!user) return;
    user.moder = 'true';
    user.club = 'sdfa3';
    user.city = 'Ульяновск';
    user.info = 'stuff stuff';
    var directive = {
	'#email+' : 'email',
	'#surname' : 'surname',
	'#patronimic' : 'patrinimic',
	'#name' : 'name',
	'#birthdate@value' : 'birthdate',
	'#moder@checked' : 'moder',
	'#city@value' : 'city',
	'#userInfo' : 'info'
    };
    $('#editprofile').render(user, directive);
    $('#rank').val(user.rank);
    $('#club').val(user.club);
   
}