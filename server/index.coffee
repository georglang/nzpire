Meteor.startup ->
  # code to run on server at startup

Meteor.publish "userData", ->
  return Meteor.users.find {_id: this.userId},
    fields:
      'services': 1
      'mail': 1

Meteor.publish "allProfiles", ->
	Profiles.find({})

Meteor.publish "allCubes", ->
	Cubes.find({})