Template.menue.events
	'click input#news': ->
		console.log "clicked news"
		Workspace.news()

	'click input#home': ->
		console.log "clicked home"
		Workspace.index()

	'click input#search': ->
		console.log "clicked search"
		Workspace.search document.getElementById("searchQuery").value

	'click input#modelingspaceButton': ->
		console.log "clicked modelingspace"
		Workspace.modelingspace()

	'keydown input#searchQuery': (e)->
		Meteor.defer ->
			console.log "onchange search"
			searchQuery = document.getElementById("searchQuery").value
			if searchQuery.length > 2 || e.keyCode == 13
				console.log encodeURIComponent(searchQuery)
				Workspace.search encodeURIComponent(searchQuery)
			else if searchQuery.length <= 2
				$('#searchresult').empty()
				Workspace.search ""