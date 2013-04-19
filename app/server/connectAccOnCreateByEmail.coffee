Meteor.startup ->
  # code to run on server at startup

Accounts.onCreateUser( (options,user)->
	# Email and Services are Arrays in the Profile Collections
	# Function to check if the Email is already in our Profile Collection

	checkForEmail = (email)->
		console.log "++++ checkForEmail ++++"
		console.log email[0]
		
		result =  Profiles.find(
			email: email[0]
		).fetch()
		console.log result
		return result

	# Get the service in string the user uses to log in AND the username and the serviceid
	service = Object.keys(user.services)[0]

	if service == "password"
		service = twitterEmail
		emails = []
		emails.push(options.email)
		pictureUrl = "dummyPic.jpg"
		checkedEmail = checkForEmail(emails)

	# Different handling for different services
	else if service == "github"	
		username = user.services[service].username
		options.profile.name = username
		service_id = user.services[service].id	

		# options.profile.email is an array with emails
		options.profile.email = Meteor.http.get('https://api.github.com/user/emails?access_token=' + user.services[service].accessToken).data
		emails = options.profile.email
		githubUser = Meteor.http.get('https://api.github.com/user?access_token=' + user.services[service].accessToken)		
		pictureUrl = githubUser.data.avatar_url
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	else if service == "twitter"
		username = options.profile.name
		service_id = user.services[service].id				
		emails = []
		emails.push(user.services[service].screenName + "@" + twitterEmail + ".at")
		pictureUrl = "dummyPic.jpg"
		checkedEmail = checkForEmail(emails)

	else if service == "facebook"
		username = options.profile.name
		service_id = user.services[service].id				
		emails = []
		emails.push(user.services[service].email)
		pictureUrl = "http://graph.facebook.com/#{service_id}/picture?type=large"
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	else if service == "google"
		username = options.profile.name
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