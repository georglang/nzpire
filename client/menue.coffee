Template.menue.events
	'click input#help': ->
		console.log "clicked help"
		Workspace.help()

	'click input#index': ->
		console.log "clicked index"
		Workspace.index()

	'click input#search': ->
		console.log "clicked search"
		Workspace.search()

	'click input#modelingspace': ->
		console.log "clicked modelingspace"
		Workspace.modelingspace()