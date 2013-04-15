Template.edit.userName = ->
	currentProfile().name

Template.edit.email = ->
	currentEmail()

Template.edit.www = ->
	currentProfile().www

Template.edit.events
	'click div#submitEdit': ->
		editUsername = $("#editUsername").val();
		editWww = $("#editWww").val(); 
		
		Profiles.update({_id: currentProfile()._id}, {$set: {name: editUsername}});
		Profiles.update({_id: currentProfile()._id}, {$set: {www: editWww}});