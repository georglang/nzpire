# # Global_Functions

# ## Current Profile
# * return: object
@currentProfile = ->
	Profiles.find(
		email: currentEmail()
	).fetch()[0]	

# ## Current Users Email
# * return: string
@currentEmail = ->
	Meteor.user().mail[0]

# ## Check Login Protection
# Redirects to Index if the User is not logged in
@checkLoginProtection = ->
	if Meteor.user() == null
		currentTemplateSession = Session.get 'template'
		currentTemplateInArray = $.inArray(currentTemplateSession,loginProtectionArray)

		if currentTemplateInArray >= 0
			Workspace.index()

# ## Login Protected Sites
@loginProtectionArray = [
	"modelEdit"
	"news"
	"profile"
	"edit"
	]