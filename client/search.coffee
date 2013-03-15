searchForProfiles = (searchQuery)->
	Profiles.find( $or:[
			email: eval(searchQuery)
		,
			name: eval(searchQuery)
		])	

searchForModels = (searchQuery)->
	Models.find
		name: eval(searchQuery)

Template.search.getResults = ->
	searchingFor = Session.get("searchQuery").charAt(0)

	if searchingFor == "@"
		searchQuery = "/" + Session.get("searchQuery").slice(1) + "/"
		result = searchForProfiles(searchQuery)
	else if searchingFor == "#"
	  searchQuery = "/" + Session.get("searchQuery").slice(1) + "/"
	  result = searchForModels(searchQuery)
	else
		searchQuery = "/" + Session.get("searchQuery") + "/"
		result = searchForProfiles(searchQuery).fetch()
		result2 = searchForModels(searchQuery).fetch()
		jQuery.merge(result,result2)

	return result
