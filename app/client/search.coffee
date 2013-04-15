searchForProfiles = (searchQuery)->
	Profiles.find
		name: eval(searchQuery)

	###
	Profiles.find( $or:[
			email: eval(searchQuery)
		,
			name: eval(searchQuery)
		])
	###

searchForModels = (searchQuery)->
	tmpResult = Models.find({name: eval(searchQuery)}).fetch()
	modelsResult = []
	tmpResult.forEach (i)->
		permission = checkModelPermission i._id
		if permission > Roles.none
			modelsResult.push i
	return modelsResult

checkForFollowing = (_id)->
	Profiles.find
		_id: currentProfile()._id
		following: _id

checkForFavourites = (_id)->
	Profiles.find
		_id: currentProfile()._id
		favourites: _id

order = (searchingFor,_id)->
	loggedIn = Meteor.userId()
	if searchingFor == "profileLink" && loggedIn != null
		if checkForFollowing(_id).fetch().length > 0
			return "unfollow"
		else
			return "follow"
	else if searchingFor == "modelLink" && loggedIn != null
		if checkForFavourites(_id).fetch().length > 0
			return "defavourite"
		else
			return "favourite"



Template.search.getResults = ->
	searchingFor = Session.get("searchQuery").charAt(0)
	if searchingFor == "@"
		searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i"
		result = searchForProfiles(searchQuery)
		i.searchingFor = "profileLink" for i in result
		i.order = order("profileLink",i._id) for i in result
	else if searchingFor == "#"
	  searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i"
	  result = searchForModels(searchQuery)
	  i.searchingFor = "modelLink" for i in result
	  i.order = order("modelLink",i._id) for i in result
	else
		searchQuery = "/" + Session.get("searchQuery") + "/i"
		result = searchForProfiles(searchQuery).fetch()
		result2 = searchForModels(searchQuery)
		i.searchingFor = "profileLink" for i in result
		i.order = order("profileLink", i._id) for i in result
		i.searchingFor = "modelLink" for i in result2
		i.order = order("modelLink",i._id) for i in result2
		jQuery.merge(result,result2)

	return result

Template.search.events
	'click div.profileLink': (e)->
		Workspace.profile e.target.id

	'click div.modelLink': (e)->
		Workspace.model e.target.id

	'click div.follow': (e)->
		Profiles.update {_id: currentProfile()._id},{$push: {following: e.target.id}}

	'click div.favourite': (e)->
		Profiles.update {_id: currentProfile()._id},{$push: {favourites: e.target.id}}

	'click div.defavourite': (e) ->
		Profiles.update {_id: currentProfile()._id},{$pull:{favourites: e.target.id}}

	'click div.unfollow': (e) ->
		Profiles.update {_id: currentProfile()._id},{$pull:{following: e.target.id}}