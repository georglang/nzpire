Meteor.startup ->
  # code to run on server at startup

Accounts.onCreateUser( (options,user)->
	# Email and Services are Arrays in the Profile Collections
	# Function to check if the Email is already in our Profile Collection

	checkForEmail = (email)->
		#console.log "++++ checkForEmail ++++"
		#console.log email[0]
		
		result =  Profiles.find(
			email: email[0]
		).fetch()
		#console.log result
		return result

	# checks if the username is already in the profiles collection
	checkUsernameUniqueness = (username)->
		options = {name: username}
		findOneProfileByOptions(options)

	# Adds a random number to the username if the username is already in the profiles collection
	preserveUsernameUniqueness = (username)->
		if checkUsernameUniqueness(username) == undefined
			return username
		else
			preserveUsernameUniqueness(username + Math.floor(Math.random()*100000))

	# Get the service in string the user uses to log in AND the username and the serviceid
	service = Object.keys(user.services)[0]

	if service == "password"
		username = preserveUsernameUniqueness(options.username)
		service = twitterEmail
		emails = []
		emails.push(user.emails[0].address)
		pictureUrl = "/img/dummyPic.jpg"
		checkedEmail = checkForEmail(emails)

	# Different handling for different services
	else if service == "github"	
		username = preserveUsernameUniqueness(user.services[service].username)
		options.profile.name = username
		service_id = user.services[service].id	

		# options.profile.email is an array with emails
		options.profile.email = Meteor.http.get('https://api.github.com/user/emails?access_token=' + user.services[service].accessToken).data
		if options.profile.email.message == 'Not Found'
			options.profile.email = [username + "@" + twitterEmail + ".at"]
			emails = []
			emails.push options.profile.email
		else
			emails = options.profile.email
		githubUser = Meteor.http.get('https://api.github.com/user?access_token=' + user.services[service].accessToken)		
		pictureUrl = githubUser.data.avatar_url
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	else if service == "twitter"
		username = preserveUsernameUniqueness(options.profile.name)
		service_id = user.services[service].id				
		emails = []
		emails.push(user.services[service].screenName + "@" + twitterEmail + ".at")
		pictureUrl = "/img/dummyPic.jpg"
		checkedEmail = checkForEmail(emails)

	else if service == "facebook"
		username = preserveUsernameUniqueness(options.profile.name)
		service_id = user.services[service].id				
		emails = []
		emails.push(user.services[service].email)
		pictureUrl = "http://graph.facebook.com/#{service_id}/picture?type=large"
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	else if service == "google"
		username = preserveUsernameUniqueness(options.profile.name)
		service_id = user.services[service].id				
		emails = []
		emails.push(user.services[service].email)
		googleUser = Meteor.http.get("https://www.googleapis.com/plus/v1/people/#{service_id}?key=AIzaSyD68GWWS0wgHMljgpbrKNyQqlQxaVqIwGo")
		pictureUrl = googleUser.data.image.url
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)		

	# If the Email is already in our Collection adds the service
	if checkedEmail.length > 0
		updateObject =
			services: {}
		updateObject.services[service] = service_id

		Meteor.call 'addServiceToProfile',checkedEmail[0]._id, updateObject, (error,result)->
			if error
				console.log error.reason		

	else
		insertObject =
			name: username
			email: emails
			following: []
			favourites: []
			updatedAt: new Date()
			services: []
			www: ""
			picture: pictureUrl
		serviceObject = {}
		serviceObject[service] = service_id
		insertObject.services.push(serviceObject)

		# Creates a new Entry in our Profile Collection
		Meteor.call 'createProfile', insertObject, (error,result)->
			if error
				console.log error.reason	

	user.emails = emails
	user.profile = options.profile
	user.mail = emails

	return user
)