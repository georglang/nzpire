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
			$('#model').after("<li id='newModel'><input id='modelName' type='text' placeholder='Modelname'><a href='#' id='createNewModel'>Create</a></li>")
		false

	'click #createNewModel': ->
		modelName = $('#modelName').val()
		if $('#modelNameAlreadyTaken')[0] != undefined
			$('#modelNameAlreadyTaken').remove()

		if modelName != ""
			checkForAvailability = Models.findOne
				name: modelName
			console.log checkForAvailability
			if checkForAvailability == undefined
				console.log currentProfile().name
				newModelId = Models.insert({name: modelName,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:currentProfile()._id,invited:[],predecessor:"",isPublic:false})
				$('#newModel')[0].remove()
				Workspace.model(newModelId)
			else
				console.log "else"
				$('#createNewModel').after("<div id='modelNameAlreadyTaken'>Modelname not available</div>")

	'click #profile': ->
		console.log "clicked profile"
		Workspace.profile(currentProfile()._id)
		false

	'click #edit': ->
		console.log "clicked edit"
		Workspace.edit()

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
