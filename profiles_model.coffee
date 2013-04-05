Profiles = new Meteor.Collection 'profiles'

findOneProfileByOptions = (options)->
	return Profiles.findOne(options)