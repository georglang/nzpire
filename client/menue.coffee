Template.menue.events
	'click input#help': ->
		console.log "clicked help"
		Workspace.help()

	'click input#home': ->
		console.log "clicked home"
		Workspace.index()

	'click input#search': ->
		console.log "clicked search"
		Workspace.search document.getElementById("searchQuery").value

	'click input#modelingspaceButton': ->
		console.log "clicked modelingspace"
		Workspace.modelingspace()