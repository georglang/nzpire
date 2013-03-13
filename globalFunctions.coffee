currentProfile = ->
	Profiles.find(
		email: Meteor.user().emails[0]
	).fetch()[0]	