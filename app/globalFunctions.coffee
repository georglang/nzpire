# # Global_Functions

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