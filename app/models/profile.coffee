# # Profile

@Profiles = new Meteor.Collection 'profiles'

@findOneProfileByOptions = (options)->
	return Profiles.findOne(options)

@checkEditingOwnProfile = (profileId)->
	if currentProfile()._id != profileId
		throw new Meteor.Error(490, "Permission denied");
	return true

Meteor.methods
	createProfile: (insertObject)->
		Profiles.insert insertObject

	addServiceToProfile: (profileId,updateObject)->
		checkEditingOwnProfile(profileId)
		Profiles.update {_id: profileId},{$push: updateObject}			
		Profiles.update {_id: profileId},{$set: {updatedAt: new Date()}}