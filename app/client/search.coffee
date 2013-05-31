# #Search

# ## Profilesearch
# Gets the profiles where the evaluated searchQuery matches without the current User  
# params: string (i.e. "/max_mustermann/i")    
# return: cursor
searchForProfiles = (searchQuery)->
	if Meteor.user()?.services
		Profiles.find({$and:[{name:eval(searchQuery)},{_id: {$ne: currentProfile()._id}}]}).fetch()
	else
		Profiles.find({name:eval(searchQuery)}).fetch()	

# ## Modelsearch
# Gets the models where the evaluated searchQuery matches    
# Checks if the user has permissions to get the model returned    
# params: string (i.e. "/my_model/i")    
# return: cursor
searchForModels = (searchQuery)->
  tmpResult = Models.find({$or: [{name: eval(searchQuery)},tags: eval(searchQuery)]}).fetch()

# ## Check Follow
# Checks if the currentUser follows the given profile(_id)    
# params: _id    
# return: cursor
checkForFollowing = (_id)->
	Profiles.find
		_id: currentProfile()._id
		following: _id

# ## Check Favourite
# Checks if the currentUser favourites the given model(_id)    
# params: _id    
# return: cursor
checkForFavourites = (_id)->
	Profiles.find
		_id: currentProfile()._id
		favourites: _id

# ## Follow/Favourite
# Handles the result of checkForFollowing and checkForFavourite    
# params: string ("profileLink" || modelLink) , _id    
# return: string ("unfollow"/"follow" || "defavourite"/"favourite")
order = (searchingFor,_id)->
	loggedIn = Meteor.userId()
	if (searchingFor == "profileLink" && loggedIn != null) && (_id != currentProfile()._id)
		if checkForFollowing(_id).fetch().length > 0
			return "unfollow"
		else
			return "follow"
	else if searchingFor == "modelLink" && loggedIn != null
		if checkForFavourites(_id).fetch().length > 0
			return "defavourite"
		else
			return "favourite"



buttonDesign = (link,id)->
	tmp = order(link,id)
	if tmp == "follow" || tmp == "favourite"
		return "btn btn-small btn-primary"
	else
		return "btn btn-small btn-danger"


# ## Search Result
# Checks if the first char of the search query is "@" (profiles) or "#" (models) else (profiles && models)    
# Creates the searchQuery with "/query/i" to enable that the search query has not to match exactly and is case insensitive    
# Calls the order function to check if the user follows/favourites  profiles/models    
# If # and @ not given the function gets models and profiles and merges them    
# params:    
# return: array (with #models or @profiles or both) (+ .searchingFor" and .order)

Template.search.getResults = ->
	searchingFor = Session.get("searchQuery").charAt(0)
	if searchingFor == "@"
		searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i"
		result = searchForProfiles(searchQuery)
		i.searchingFor = "profileLink" for i in result
		i.order = order("profileLink",i._id) for i in result
		i.button = buttonDesign("profileLink",i._id) for i in result
	else if searchingFor == "#"
	  searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i"
	  result = searchForModels(searchQuery)
	  i.searchingFor = "modelLink" for i in result
	  i.order = order("modelLink",i._id) for i in result
	  i.button = buttonDesign("modelLink",i._id) for i in result
	else
		searchQuery = "/" + Session.get("searchQuery") + "/i"
		result = searchForProfiles(searchQuery)
		result2 = searchForModels(searchQuery)
		i.searchingFor = "profileLink" for i in result
		i.order = order("profileLink", i._id) for i in result
		i.button = buttonDesign("profileLink",i._id) for i in result
		i.searchingFor = "modelLink" for i in result2
		i.order = order("modelLink",i._id) for i in result2
		i.button = buttonDesign("modelLink",i._id) for i in result2
		jQuery.merge(result,result2)

	return result

# ## Events
# Search click events to redirect to models or profiles or to update Profiles with follow/favourite
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