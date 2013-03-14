Template.search.getResults = ->
	console.log "getResults"
	console.log Session.get "searchQuery"

	searchQuery = "/" + Session.get("searchQuery")+ "/"
	console.log searchQuery
	result = Profiles.find(
		email: eval(searchQuery)).fetch()		

	console.log "result"
	console.log result
	return result
