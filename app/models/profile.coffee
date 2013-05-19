# # Profile

@Profiles = new Meteor.Collection 'profiles'

@findOneProfileByOptions = (options)->
	return Profiles.findOne(options)

Meteor.methods
	createProfile: (insertObject)->
		Profiles.insert insertObject

	addServiceToProfile: (profileId,updateObject)->
		Profiles.update {_id: profileId},{$push: updateObject}			
		Profiles.update {_id: profileId},{$set: {updatedAt: new Date()}}