@Cubes = new Meteor.Collection 'cubes'
@Models = new Meteor.Collection 'models'


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
			checkAlreadyInvited = Models.findOne({'invited.userId':invitedProfile._id})
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





@findModelByName = (name)->
	return Models.findOne({name: name})

@findOneModelByOptions = (options)->
	return Models.findOne(options)

@checkModelPermission = (modelId) ->
	#console.log "checkModelPermission"
	options = {_id: modelId}
	model = findOneModelByOptions(options)
	isCreator = findOneModelByOptions({_id:modelId,creator: currentProfile()._id})
	if model.invited != undefined
		isInvited = $.grep(model.invited,(e)->
			return e.userId == currentProfile()._id
		)
		if isInvited.length > 0
			if isInvited[0].role == "owner"
				#console.log "owner"
				return Roles.owner
			else if isInvited[0].role == "collaborator"
				#console.log "collaborator"
				return Roles.collaborator
			else if isInvited[0].role == "viewer"
				#console.log "viewer"
				return Roles.viewer
	if isCreator
		#console.log "creator"
		return Roles.creator
	else
		if model.isPublic == true
			#console.log "isPublic true"
			return Roles.viewer
		else
			return Roles.none	

@Roles =
	none: 0,
	viewer: 1,
	collaborator: 2,
	creator: 3,
	owner: 3
  
  