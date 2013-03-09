Meteor.startup ->
  # code to run on server at startup

# Allows to remove Users from the Meteor.users collection on the client
Meteor.users.allow
	remove: ->
		true

