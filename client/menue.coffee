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
		if $('#errorNewModel')[0] != undefined
			$('#errorNewModel').remove()

		options = {name: modelName, predecessor: "", creator: currentProfile()._id,isPublic: false}
		Meteor.call 'createModel',options, (error,result)->
			if error
				$('#createNewModel').after("<div id='errorNewModel'>"+error.reason+"</div>")
			else
				$('#newModel')[0].remove()
				Workspace.model(result)
		
				

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

	'click #login-buttons-logout': ()->
		console.log "logout"
		Workspace.index()
