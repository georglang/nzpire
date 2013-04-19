Template.profile.userName = ->
	currentProfile().name

Template.profile.email = ->
	currentEmail()

Template.profile.www = ->
	currentProfile().www

Template.profile.pictureUrl = ->
	currentProfile().picture