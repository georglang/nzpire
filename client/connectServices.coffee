
# Inserts the new Mail into the old Account and Deletes the created User and reloggs the User
connectProfiles = (tmpEmail,loginFunction)->
	tmpProfile = Profiles.findOne
		email: tmpEmail

	oldProfile = Profiles.findOne
		email: Meteor.user().emails[0]

	Profiles.update {_id: tmpProfile._id},{$push: {email: Meteor.user().emails[0]}}
	#Profiles.remove {_id: oldProfile._id}
	Meteor.users.remove({_id: Meteor.userId()})

	loginFunction
		requestOfflineToken: [true]		

# Checks out which Services the User has already connected and Returns the rest
Template.index.connectButtons = ->
	Session.set("email", Meteor.user().emails[0])
	#Meteor.subscribe "usersProfile", Session.get "email"
	# Provides Services
	services = ["Facebook","Twitter","Google","Github"];

	console.log Session.get "email"
	tmpProfile = Profiles.find(
		email: Session.get "email"
		).fetch()[0]
	console.log tmpProfile

	
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
		tmpEmail = Meteor.user().emails[0]
		Meteor.loginWithFacebook
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithFacebook)
		return true

	'click input#connectWithGithub': ->
		tmpEmail = Meteor.user().emails[0]
		Meteor.loginWithGithub
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithGithub)
		return true

	'click input#connectWithGoogle': ->
		tmpEmail = Meteor.user().emails[0]
		Meteor.loginWithGoogle
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithGoogle)
		return true

	'click input#connectWithTwitter': ->
		tmpEmail = Meteor.user().emails[0]
		Meteor.loginWithTwitter
			requestOfflineToken: [true]
		, ->
			connectProfiles(tmpEmail,Meteor.loginWithTwitter)
		return true				


	

Meteor.autorun ->
	Meteor.subscribe "userData"
	Meteor.subscribe "allProfiles"
	
		


