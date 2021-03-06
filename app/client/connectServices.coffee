###
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
###

# # Connect various Accounts

loginFunctions =
	'facebook': Meteor.loginWithFacebook 
	'google': Meteor.loginWithGoogle
	'twitter': Meteor.loginWithTwitter

# ## Connect Profiles
# Saves the new mail into a tmp variable und reloggs the user.
# In the relogInCallback the mail is saved to the profile
# After the function the created Profile gets removed
# * params: string (oldAccounts email), function (i.e. Meteor.loginWithFacebook)    
# * return:    
connectProfiles = (tmpEmail,tmpService)->
	tmpProfile = Profiles.findOne
		email: tmpEmail

	newProfile = Profiles.findOne
		email: currentEmail()

	service = Object.keys(Meteor.user().services)[0]
	service_id = Meteor.user().services[service].id
	updateObject =
		services: {}
	updateObject.services[service] = service_id

	loginFunctions[tmpService]
		requestOfflineToken: [true]
	, ->
		relogInCallback(updateObject, newProfile.email[0], tmpProfile, newProfile)

	Profiles.remove {_id: newProfile._id}

relogInCallback = (updateObject, email, tmpProfile, newProfile)->
	# Adds the service and the email
	Profiles.update {_id: tmpProfile._id},{$push: updateObject}
	Profiles.update {_id: tmpProfile._id},{$push: {email: email}}
	Profiles.update {_id: tmpProfile._id},{$set: {updatedAt: new Date()}}
	# Removes the created Profile
	#Profiles.remove {_id: newProfile._id}


# ## Connect Buttons
# Checks out which Services the User has already connected and Returns the rest    
# * params:    
# * return: array (i.e. ["Facebook","Twitter"])    
Template.connectServices.connectButtons = ->
	# ### Provides Services
	services = ["Facebook","Twitter","Google"];

	tmpProfile = Profiles.find(
		email: currentEmail()
		).fetch()[0]
	# Array of Services the User has already connected    
	serviceArray = tmpProfile?.services

	i = 0
	# Compares the User Services with the Provided services and slices the matches out of the provided    
	if serviceArray != undefined
		console.log "in if"
		while i < serviceArray.length
		  element = serviceArray[i]
		  service = Object.keys(element)[0].charAt(0).toUpperCase() + Object.keys(element)[0].slice(1)
		  inArray = $.inArray(service, services)
		  if inArray != -1
		  	services.splice inArray,1
		  ++i	  
	return services	

# ## Connect Button Events
# Connect Buttons Onclick login with the service and on callback calls the function connectProfiles    
Template.connectServices.events
	'click img#connectWithFacebook': ->
		tmpEmail = currentEmail()
		tmpService = service = Object.keys(Meteor.user().services)[0]
		Meteor.loginWithFacebook
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,tmpService)
		return true

	'click img#connectWithGithub': ->
		tmpEmail = currentEmail()
		tmpService = service = Object.keys(Meteor.user().services)[0]
		Meteor.loginWithGithub
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,tmpService)
		return true

	'click img#connectWithGoogle': ->
		tmpEmail = currentEmail()
		tmpService = service = Object.keys(Meteor.user().services)[0]
		Meteor.loginWithGoogle
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,tmpService)
		return true

	'click img#connectWithTwitter': ->
		tmpEmail = currentEmail()
		tmpService = service = Object.keys(Meteor.user().services)[0]
		Meteor.loginWithTwitter
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,tmpService)
		return true