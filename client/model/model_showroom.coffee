Template.model.modelLoaded = ->
	return modelLoaded()

Template.model.handleModelPermission = ->
	permission = checkModelPermission(Session.get('model'))
	if permission <= Roles.none
		Workspace.index()

Template.modelSidebar.isOwner = ->
	if Meteor.user() == null
		return false
	else
		if currentProfile()._id == findOneModelByOptions({_id: Session.get('model')}).creator
			return true
		else
			return false

Template.modelSidebar.modelname = ->
	model = findOneModelByOptions({_id: Session.get('model')})
	if model == undefined
		return null
	else
		name = model.name
		if name != undefined
			return name
		else
			return null

Template.modelSidebar.updatedAt = ->
	updatedAt = findOneModelByOptions({_id: Session.get('model')}).updatedAt
	if updatedAt != undefined
		d = new Date(updatedAt)
		return d.toUTCString()
	else
		return null

Template.modelSidebar.tags = ->
	tags = findOneModelByOptions({_id: Session.get('model')}).tags

	if tags != undefined
		if Template.modelSidebar.isOwner()		
			tags.push ""
		return tags
	else
		return null

Template.modelSidebar.creator = ->
	creatorId = findOneModelByOptions({_id: Session.get('model')}).creator
	if creatorId != ""
		name = findOneProfileByOptions({_id: creatorId}).name
		return name
	else
		return null

Template.modelSidebar.invited = ->
	names = []
	invitedPeople = findOneModelByOptions({_id: Session.get('model')}).invited
	if invitedPeople != undefined
		names.push({name: findOneProfileByOptions({_id: i.userId}).name,role: i.role}) for i in invitedPeople
		if Template.modelSidebar.isOwner()
			names.push {name:"",role:""}
		return names
	else
		return null

Template.modelSidebar.predecessor = ->
	predecessorId = findOneModelByOptions({_id: Session.get('model')}).predecessor
	if predecessorId != ""
		name = findOneModelByOptions({_id:predecessorId}).name
		return name
	else
		return null
	
Template.modelSidebar.isPublic = ->
	isPublic = findOneModelByOptions({_id: Session.get('model')}).isPublic
	if isPublic != undefined
		return isPublic
	else
		return null

Template.modelSidebar.events
	'click #slideContainerListItems>li>ul>li': (e)->
		if Template.modelSidebar.isOwner()
			className = e.target.className
			if className == 'modelname'
				$(e.target).replaceWith("<input autofocus='autofocus' id='editModelName' type='text' value='"+Template.modelSidebar.modelname()+"'>")
			else if className == 'tags'
				tagName = $(e.target).html()
				if tagName.length == 0
					$(e.target).replaceWith("<input autofocus='autofocus' id='addTag' type='text' placeholder='Tagname'>")
				else
					options = {_id: Session.get('model'),tag: tagName}
					Meteor.call 'removeModelTag', options, (error,result)->
						if error
							console.log error.reason
			else if className == 'invited'
				invitedName = $(e.target).html()
				#console.log invitedName
				if invitedName.length == 0
					$(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'><select id='invitedRole'><option value='owner'>Owner</option><option value='collaborator'>Collaborator</option><option value='viewer'>Viewer</option></select>")
				else
					options = {_id: Session.get('model'),invite: invitedName}
					Meteor.call 'removeModelInvite', options, (error,result)->
						if error
							console.log error.reason
			else if className == 'isPublic'
				options = {_id: Session.get('model'),isPublic: Template.modelSidebar.isPublic()}
				Meteor.call 'updateModelIsPublic',options, (error,result)->
					if error
						console.log error.reason

	'blur #editModelName': (e)->
		modelName = e.target.value
		if modelName.length > 3
			if $('#errorUpdateModelName')[0] != undefined
				$('#errorUpdateModelName').remove()	

			options = {_id:Session.get('model'),name: modelName}
			Meteor.call 'updateModelName', options, (error,result) ->
				if error
					$('#editModelName').after("<div id='errorUpdateModelName'>"+error.reason+"</div>")


	'keydown #editModelName': (e)->
		if e.keyCode == 13
			$('#editModelName').blur()

	'blur #addTag': (e)->
		if $('#errorUpdateTag')[0] != undefined
			$('#errorUpdateTag').remove()			
		options = {_id: Session.get('model'),tag: e.target.value}
		Meteor.call 'updateModelTag', options, (error,result)->
			if error
				$('#addTag').after("<div id='errorUpdateTag'>"+error.reason+"</div>")			

	'keydown #addTag': (e)->
		if e.keyCode == 13
			$('#addTag').blur()

	'blur #addInvite': (e)->
		if $('#errorUpdateInvite')[0] != undefined
			$('#errorUpdateInvite').remove()				
		role = $('#invitedRole').val()
		options = {_id: Session.get('model'),invite: e.target.value,role:role}
		Meteor.call 'updateModelInvite',options, (error,result)->
			if error
				$('#addInvite').after("<div id='errorUpdateInvite'>"+error.reason+"</div>")		

	'keydown #addInvite': (e)->
		if e.keyCode == 13
			$('#addInvite').blur()			

	'click #favourite': ->
		Profiles.update {_id: currentProfile()._id},{$push: {favourites: Session.get('model')}}

	'click #defavourite': ->
		Profiles.update {_id: currentProfile()._id},{$pull:{favourites: Session.get('model')}}

	'click #clone': (e)->
		if $('#cloneModelName')[0] != undefined
			$('#cloneModelName').remove()
			$('#createCloneModel').remove()
		$(e.target).after("<input type='text' id='cloneModelName' placeholder='Enter Modelname'><input type='button' id='createCloneModel' value='Create Clone'>")

	'click #createCloneModel': ->
		modelName = $('#cloneModelName').val()
		if $('#errorCloneModel')[0] != undefined
			$('#errorCloneModel').remove()

		options = {name: modelName, predecessor: Session.get('model'), creator: currentProfile()._id,isPublic: false}
		Meteor.call 'createModel',options, (error,result)->
			if error
				$('#createNewModel').after("<div id='errorCloneModel'>"+error.reason+"</div>")
			else
				Workspace.model(result)

Template.modelSidebar.profilesList = ->
	return Profiles.find({})

Template.modelSidebar.isFavourited = ->
	if Meteor.user() == null
		return false
	else
		favourited = findOneProfileByOptions({_id: currentProfile()._id,favourites: Session.get('model')})
		if favourited == undefined
			return true
		else
			return false


Template.modelEdit.handleModelPermission = ->
	#console.log "handleModelPermission"
	#console.log checkModelPermission(Session.get('model'))
	permission = checkModelPermission(Session.get('model'))
	if permission < Roles.viewer
		Workspace.model('index')
	else if permission < Roles.collaborator
		Workspace.model(Session.get('model'))
