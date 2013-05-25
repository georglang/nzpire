# # Navigation Events

Template.menue.events
	# ## News
	'click #news': ->
		console.log "clicked news"
		Workspace.news()
		false

	# ## Index
	'click #home': ->
		console.log "clicked home"
		Workspace.index()
		false

	# ## Model
	# Replaces the navigation Elemente with an input field where a new model can be created
	'click #model': ->
		console.log "clicked model"
		if $('#newModel')[0] == undefined
			$('#model').replaceWith("<li id='newModel'><input autofocus='autofocus' id='modelName' type='text' placeholder='Modelname'><input type='button' id='createNewModel' value='Create'></li>")
		false

	# ## Create Model
	# Checks if the input field is empty and tries to create a new model and handels the callback
	'click #createNewModel': ->
		modelName = $('#modelName').val()
		if $('#errorNewModel')[0] != undefined
			$('#errorNewModel').remove()

		options = {name: modelName, predecessor: "", creator: currentProfile()._id,isPublic: false}
		Meteor.call 'createModel',options, (error,modelId)->
			if error
				$('#createNewModel').after("<div id='errorNewModel'>"+error.reason+"</div>")
			else
				$('#newModel').replaceWith("<a href='#' id='model'>Create new Model</a>")
				Workspace.model(modelId)

	# Triggers a click Event on #createNewModel if the input key == Enter button 
	'keydown #modelName': (e)->
		Meteor.defer ->
			if e.keyCode == 13
				$('#createNewModel').click()
			else if e.keyCode == 27
				$('#newModel').replaceWith("<a href='#' id='model'>Create new Model</a>")

	# ## Profile
	'click #profile': ->
		console.log "clicked profile"
		Workspace.profile(currentProfile()._id)
		false

	# ## Search
	'click #search': ->
		console.log "clicked search"
		Workspace.search encodeURIComponent(document.getElementById("searchQuery").value)
		false

	# Triggers a search if the query length > 2 or keydown == Enter button
	'keydown #searchQuery': (e)->
		Meteor.defer ->
			searchQuery = document.getElementById("searchQuery").value
			if searchQuery.length > 2 || e.keyCode == 13
				Workspace.search encodeURIComponent(searchQuery)
			else if searchQuery.length <= 2
				$('#searchresult').empty()
				Workspace.search ""
		# the keydown event must not propagate further,
		# because this might evoke shortcuts (like undo / redo)
		# in the 3D scene!
		e.stopImmediatePropagation()

	# ## Model Showroom
	'click #modelShowroom': ()->
		Workspace.modelShowroom()

	# Redirects to Index on logout
	'click #login-buttons-logout': ()->
		Workspace.index()
