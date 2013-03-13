Meteor.startup ->
  # code to run on server at startup

Accounts.onCreateUser( (options,user)->
	# Email and Services are Arrays in the Profile Collections

	# Function to check if the Email is already in our Profile Collection
	checkForEmail = (email)->
		Profiles.find(
			email: email[0]
		).fetch()

	# Get the service in string the user uses to log in AND the username and the serviceid
	service = Object.keys(user.services)[0]
	username = options.profile.name
	service_id = user.services[service].id

	# Different handling for different services
	if service == "github"
		username = user.services[service].username
		options.profile.name = username

		# options.profile.email is an array with emails
		options.profile.email = Meteor.http.get('https://api.github.com/user/emails?access_token=' + user.services[service].accessToken).data
		emails = options.profile.email

		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	else if service == "twitter"
		emails = []
		emails.push(user.services[service].screenName + "@" + twitterEmail + ".at")
		checkedEmail = checkForEmail(emails)

	else
		emails = []
		emails.push(user.services[service].email)
		#Is this email already in our collection
		checkedEmail = checkForEmail(emails)

	# If the Email is already in our Collection adds the service
	if checkedEmail.length > 0
		updateObject =
			services: {}
		updateObject.services[service] = service_id

		# Adds the service
		Profiles.update {_id: checkedEmail[0]._id},{$push: updateObject}

	else
		insertObject =
			name: username
			email: emails
			services: []
		serviceObject = {}
		serviceObject[service] = service_id
		insertObject.services.push(serviceObject)

		# Creates a new Entry in our Profile Collection
		Profiles.insert insertObject

	user.emails = emails

	user.profile = options.profile

	return user
)