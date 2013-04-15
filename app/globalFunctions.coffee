@currentProfile = ->
	Profiles.find(
		email: currentEmail()
	).fetch()[0]	

@currentEmail = ->
	Meteor.user().mail[0]

@checkLoginProtection = ->
	if Meteor.user() == null
		currentTemplateSession = Session.get 'template'
		currentTemplateInArray = $.inArray(currentTemplateSession,loginProtectionArray)

		if currentTemplateInArray >= 0
			Workspace.index()


@loginProtectionArray = [
	"modelEdit"
	"news"
	"profile"
	"edit"
	]