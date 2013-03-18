currentProfile = ->
	Profiles.find(
		email: currentEmail()
	).fetch()[0]	

currentEmail = ->
	Meteor.user().mail[0]