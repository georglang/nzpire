findModelById = (_id)->
	Models.findOne
		_id: _id	

findProfileById = (_id)->
	Profiles.findOne
		_id: _id



Template.model.isOwner = ->
	if currentProfile()._id == findModelById(Session.get 'model').creator
		return true
	else
		return false

Template.model.modelname = ->
	name = findModelById(Session.get 'model').name
	if name != undefined
		return name
	else
		return null

Template.model.updatedAt = ->
	updatedAt = findModelById(Session.get 'model').updatedAt
	if updatedAt != undefined
		d = new Date(updatedAt)
		return d.toUTCString()
	else
		return null

Template.model.tags = ->
	tags = findModelById(Session.get 'model').tags

	if tags != undefined
		if Template.model.isOwner()		
			tags.push ""
		return tags
	else
		return null

Template.model.creator = ->
	creatorId = findModelById(Session.get 'model').creator
	if creatorId != ""
		name = findProfileById(creatorId).name
		return name
	else
		return null

Template.model.invited = ->
	names = []
	invitedPeople = findModelById(Session.get 'model').invited
	if invitedPeople != undefined
		names.push(findProfileById(i.userId).name) for i in invitedPeople
		if Template.model.isOwner()
			names.push ""
		return names
	else
		return null

Template.model.predecessor = ->
	predecessorId = findModelById(Session.get 'model').predecessor
	if predecessorId != ""
		name = findModelById(predecessorId).name
		return name
	else
		return null
	
Template.model.isPublic = ->
	isPublic = findModelById(Session.get 'model').isPublic
	if isPublic != undefined
		return isPublic
	else
		return null

Template.model.events
	'click #slideContainerListItems>li>ul>li': (e)->
		if Template.model.isOwner()
			className = e.target.className
			if className == 'modelname'
				$(e.target).replaceWith("<input autofocus='autofocus' id='editModelName' type='text' value='"+Template.model.modelname()+"'>")
			else if className == 'tags'
				tagName = $(e.target).html()
				if tagName.length > 0
					Models.update({_id: Session.get 'model'},{$pull: {tags: tagName}})
				else if tagName.length == 0
					$(e.target).replaceWith("<input autofocus='autofocus' id='addTag' type='text' placeholder='Tagname'>")
			else if className == 'invited'
				invitedName = $(e.target).html()
				if invitedName.length > 0
					Models.update({_id: Session.get 'model'},{$pull: {invited: invitedName}})
				else if invitedName.length == 0
					$(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'>")				
			else if className == 'isPublic'
				if Template.model.isPublic() == false
					isPublic = true
				else
					isPublic = false
				Models.update({_id: Session.get('model')},{$set: {isPublic: isPublic}})


	'blur #editModelName': (e)->
		if e.target.value.length > 3
	 		checkForAvailability = Models.findOne({name: e.target.value})
			if $('#modelNameAlreadyTaken')[0] != undefined
				$('#modelNameAlreadyTaken').remove()			
			if checkForAvailability == undefined
				Models.update({_id: Session.get('model')},{$set: {name: e.target.value}})
			else
				$('#editModelName').after("<div id='modelNameAlreadyTaken'>Modelname not available</div>")

	'keydown #editModelName': (e)->
		if e.keyCode == 13
			$('#editModelName').blur()

	'blur #addTag': (e)->
		if e.target.value.length > 3
			checkForAvailability = Models.findOne({tags: e.target.value})
			if $('#tagAlreadyTaken')[0] != undefined
				$('#tagAlreadyTaken').remove()			
			if checkForAvailability == undefined
				Models.update({_id: Session.get('model')},{$push: {tags: e.target.value}})
			else
				$('#addTag').after("<div id='tagAlreadyTaken'>Tag already defined</div>")

	'keydown #addTag': (e)->
		if e.keyCode == 13
			$('#addTag').blur()

	'blur #addInvite': (e)->
		if e.target.value.length > 3
			checkForAvailability = Profiles.findOne({name: e.target.value})

			if checkForAvailability != undefined
				invitedProfileId = checkForAvailability._id
				findObject = {userId: invitedProfileId}
				checkAlreadyInvited = Models.findOne({_id: Session.get('model'),invited: findObject})

			if $('#errorInvited')[0] != undefined
				$('#errorInvited').remove()							

			if checkForAvailability == undefined
				$('#addInvite').after("<div id='errorInvited'>Username does not exist</div>")
			else if checkAlreadyInvited != undefined
				$('#addInvite').after("<div id='errorInvited'>User already invited</div>")
			else
				updateObject = {userId: invitedProfileId}
				Models.update({_id: Session.get('model')},{$push: {invited: updateObject}})			

	'keydown #addInvite': (e)->
		if e.keyCode == 13
			$('#addInvite').blur()			

	'click #favourite': ->
		Profiles.update {_id: currentProfile()._id},{$push: {favourites: Session.get('model')}}

	'click #defavourite': ->
		Profiles.update {_id: currentProfile()._id},{$pull:{favourites: Session.get('model')}}

	'click #clone': (e)->
		$(e.target).after("<input type='text' id='cloneModelName' placeholder='Enter Modelname'><input type='button' id='createCloneModel' value='Create Clone'>")

	'click #createCloneModel': ->
		modelName = $('#cloneModelName').val()
		if $('#modelNameAlreadyTaken')[0] != undefined
			$('#modelNameAlreadyTaken').remove()

		if modelName != ""
			checkForAvailability = Models.findOne
				name: modelName
			if checkForAvailability == undefined
				newModelId = Models.insert({name: modelName,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:currentProfile()._id,invited:[],predecessor:Session.get('model'),isPublic:false})
				Workspace.model(newModelId)
			else
				$('#createCloneModel').after("<div id='modelNameAlreadyTaken'>Modelname not available</div>")

Template.model.profilesList = ->
	Profiles.find({})

Template.model.isFavourited = ->
	favourited = Profiles.findOne({_id: currentProfile()._id,favourites: Session.get('model')})
	if favourited == undefined
		return true
	else
		return false
