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

	'click #model': ->
		console.log "clicked model"
		if $('#newModel')[0] == undefined
			$('#model').replaceWith("<li id='newModel'><input autofocus='autofocus' id='modelName' type='text' placeholder='Modelname'><input type='button' id='createNewModel' value='Create'></li>")
		false

	'click #createNewModel': ->
		modelName = $('#modelName').val()
		if $('#errorNewModel')[0] != undefined
			$('#errorNewModel').remove()

		options = {name: modelName, predecessor: "", creator: currentProfile()._id,isPublic: false}
		Meteor.call 'createModel',options, (error,modelId)->
			if error
				$('#createNewModel').after("<div id='errorNewModel'>"+error.reason+"</div>")
			else
				$('#newModel')[0].remove()
				Workspace.model(modelId)

	'keydown #modelName': (e)->
		Meteor.defer ->
			if e.keyCode == 13
				console.log "test"
				$('#createNewModel').click()
			else if e.keyCode == 27
				$('#newModel').replaceWith("<a href='#' id='model'>Create new Model</a>")

	'click #profile': ->
		console.log "clicked profile"
		Workspace.profile(currentProfile()._id)
		false

	'keydown #searchQuery': (e)->
		Meteor.defer ->
			#console.log "onchange search"
			searchQuery = document.getElementById("searchQuery").value
			if searchQuery.length > 2 || e.keyCode == 13
				#console.log encodeURIComponent(searchQuery)
				Workspace.search encodeURIComponent(searchQuery)
			else if searchQuery.length <= 2
				$('#searchresult').empty()
				Workspace.search ""

	'click #login-buttons-logout': ()->
		#console.log "logout"
		Workspace.index()

	'click #modelShowroom': ()->
		Workspace.modelShowroom()
