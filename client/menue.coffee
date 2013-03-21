Template.menue.events
	'click #news': ->
		console.log "clicked news"
		Workspace.news()
		false

	'click #home': ->
		console.log "clicked home"
		Workspace.index()
		false

	'click #search': ->
		console.log "clicked search"
		Workspace.search encodeURIComponent(document.getElementById("searchQuery").value)
		false

	'click #modeling': ->
		console.log "clicked modeling"
		Workspace.modeling()
		false

	'click #profile': ->
		console.log "clicked profile"
		Workspace.profile(currentProfile()._id)
		false

	'click #edit': ->
		console.log "clicked edit"
		Workspace.edit()

	'keydown #searchQuery': (e)->
		Meteor.defer ->
			console.log "onchange search"
			searchQuery = document.getElementById("searchQuery").value
			if searchQuery.length > 2 || e.keyCode == 13
				console.log encodeURIComponent(searchQuery)
				Workspace.search encodeURIComponent(searchQuery)
			else if searchQuery.length <= 2
				$('#searchresult').empty()
				Workspace.search " "
