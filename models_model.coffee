Cubes = new Meteor.Collection 'cubes'
Models = new Meteor.Collection 'models'


Meteor.methods
	createModel: (options)->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			return Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic})

	updateModelName: (options)->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			return Models.update({_id: options._id},{$set: {name: options.name}})

	updateModelIsPublic: (options)->
		isPublic = options.isPublic
		if options.isPublic == false
			isPublic = true
		else
			isPublic = false
		return Models.update({_id: options._id},{$set: {isPublic: isPublic}})

	updateModelTag: (options)->
		if options._id == undefined || options.tag == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		tagName = options.tag
		checkForAvailability = Models.findOne({_id: options._id, tags: tagName})
		if tagName.length < 3
			throw new Meteor.Error(497, "Tagname too short");
		else if checkForAvailability != undefined
			throw new Meteor.Error(498, "Tagname already added");
		else
			Models.update({_id: options._id},{$push: {tags: tagName}})

	updateModelInvite: (options)->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		if options.invite.length < 3
			throw new Meteor.Error(497, "Username too short");
		invitedProfile = Profiles.findOne({name: options.invite})

		if invitedProfile == undefined
			throw new Meteor.Error(496, "Username does not exist");
		else
			findObject = {userId: invitedProfile._id, role:".*"}
			checkAlreadyInvited = Models.findOne({_id: options._id,invited: findObject})	
		if checkAlreadyInvited == undefined
			updateObject = {userId: invitedProfile._id, role: options.role}
			Models.update({_id: options._id},{$push: {invited: updateObject}})				
		else
			throw new Meteor.Error(498, "User already invited")		

	removeModelTag: (options)->
		if options._id == undefined || options.tag == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			return Models.update({_id: options._id},{$pull: {tags: options.tag}})

	removeModelInvite: (options)->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			profile = findOneProfileByOptions({name: options.invite})
			if profile == undefined
				throw new Meteor.Error(496, "Username does not exist");
			else
				removeObject = {invited:{userId:profile._id}}
				return Models.update({_id: options._id},{$pull: removeObject})





findModelByName = (name)->
	return Models.findOne({name: name})

findOneModelByOptions = (options)->
	return Models.findOne(options)

checkModelEditPermission = (modelId)->
	console.log "in checkModelEditPermission"

	options = {_id: modelId}
	invitedArray = findOneModelByOptions(options).invited
	if invitedArray != undefined
		isInvited = $.grep(invitedArray,(e)->
			return e.userId == currentProfile()._id
			)
	isCreator = findOneModelByOptions({_id:modelId,creator: currentProfile()._id})
	console.log isCreator
	console.log isInvited
	if isInvited == undefined && isCreator == undefined
		console.log "return 0"
		Workspace.index()
		return 0
	else if isCreator
		console.log "return 1"
		return 1
	else if isInvited != undefined	
		if isInvited[0].role == "owner"
			console.log "return 1"
			return 1
		else if isInvited[0].role == "collaborator"
			console.log "return 2"
			return 2
		else if isInvited[0].role == "viewer"
			console.log "return 3"
			Workspace.model(Session.get('model'))
			return 3
		else
			console.log "return 0"
			Workspace.index()
			return 0
	else
		console.log "return 0"
		Workspace.index()
		return 0	
