
# Inserts the new Mail into the old Account and Deletes the created User and reloggs the User
connectProfiles = (tmpEmail,loginFunction)->
	tmpProfile = Profiles.findOne
		email: tmpEmail

	newProfile = Profiles.findOne
		email: currentEmail()

	service = Object.keys(Meteor.user().services)[0]
	service_id = Meteor.user().services[service].id
	updateObject =
		services: {}
	updateObject.services[service] = service_id

	# Adds the service and the email
	Profiles.update {_id: tmpProfile._id},{$push: updateObject}
	Profiles.update {_id: tmpProfile._id},{$push: {email: currentEmail()}}
	# Removes the created Profile
	Profiles.remove {_id: newProfile._id}

# Checks out which Services the User has already connected and Returns the rest
Template.index.connectButtons = ->
	# Provides Services
	services = ["Facebook","Twitter","Google","Github"];

	tmpProfile = Profiles.find(
		email: currentEmail()
		).fetch()[0]
	# Array of Services the User has already connected
	serviceArray = tmpProfile.services

	i = 0
	# Compares the User Services with the Provided services and slices the matches out of the provided
	while i < serviceArray.length
	  element = serviceArray[i]
	  service = Object.keys(element)[0].charAt(0).toUpperCase() + Object.keys(element)[0].slice(1)
	  inArray = $.inArray(service, services)
	  if inArray != -1
	  	services.splice inArray,1
	  ++i	  
	return services
	

# Connect Buttons Onclick login with the service and on callback calls the function connectProfiles
Template.index.events
	'click input#connectWithFacebook': ->
		tmpEmail = currentEmail()
		Meteor.loginWithFacebook
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithFacebook)
		return true

	'click input#connectWithGithub': ->
		tmpEmail = currentEmail()
		Meteor.loginWithGithub
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithGithub)
		return true

	'click input#connectWithGoogle': ->
		tmpEmail = currentEmail()
		Meteor.loginWithGoogle
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithGoogle)
		return true

	'click input#connectWithTwitter': ->
		tmpEmail = currentEmail()
		Meteor.loginWithTwitter
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithTwitter)
		return true				


	

Meteor.autorun ->
	Meteor.subscribe "userData"
	Meteor.subscribe "allProfiles"
	Meteor.subscribe "allCubes"
	
		

