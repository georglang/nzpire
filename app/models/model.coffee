# # Model

@Models = new Meteor.Collection 'models'
@ModelObjects = new Meteor.Collection 'modelObjects'

# ## Model Action

@ModelActions = new Meteor.Collection 'modelActions'

ModelActionConstructors = {}

getModelActionToUndo = (modelId) ->
	model = Models.findOne _id: modelId
	actionId = model?.actionIds?.undo
	if not actionId
		return null
	else
		return ModelActions.findOne _id: actionId

getModelActionToRedo = (modelId) ->
	model = Models.findOne _id: modelId
	actionId = model?.actionIds?.redo
	if not actionId
		return null
	else
		return ModelActions.findOne actionId

setModelActionIds = (options) ->
	Models.update {_id: options.modelId},
		$set:
			actionIds:
				undo: options.undoActionId
				redo: options.redoActionId

class ModelAction
	constructor: (options) ->
		@validateBasicOptions options
		@validateSpecifics options

		@modelId = options.modelId
		@doneAt = Date.now()
		@type = options.type
		@specifics = options.specifics
		if options._id
			@_id = options._id
		else
			@save()

	validateBasicOptions: (options) ->
		if not options
			throw new Meteor.Error 490, 'No options passed to model action!'
		if not options.modelId
			throw new Meteor.Error 490, 'No model ID (options.modelId) passed to model action!'
		if not Models.findOne options.modelId
			throw new Meteor.Error 490, 'Model ID ' + options.modelId + ', passed to model action, does not exist!'
		if not options.type
			throw new Meteor.Error 490, 'No type (options.type) passed to model action!'
		if not ModelActionConstructors[options.type]
			throw new Meteor.Error 490, 'Type ' + options.type + ', passed to model action, does not exist!'
		if not options.specifics
			throw new Meteor.Error 490, 'No specifics (options.specifics) passed to model action!'

	validateSpecifics: (specifics) ->
		throw new Meteor.Error 490, 'ModelAction.validateSpecifics() not implemented!'

	do: ->
		throw new Meteor.Error 490, 'ModelAction.do() not implemented!'

	undo: ->
		throw new Meteor.Error 490, 'ModelAction.undo() not implemented!'

	getDatabaseObject: ->
		return this

	save: ->
		databaseObject = @getDatabaseObject()
		actionToUndo = getModelActionToUndo @modelId
		actionToRedo = getModelActionToRedo @modelId

		if actionToRedo
			actionToDelete = actionToRedo
			while actionToDelete
				ModelActions.remove _id: actionToDelete._id
				if actionToDelete.nextActionId
					actionToDelete = ModelActions.findOne _id: actionToDelete.nextActionId
				else
					actionToDelete = null

		if actionToUndo
			databaseObject.previousActionId = actionToUndo._id
			@_id = ModelActions.insert databaseObject
			ModelActions.update {_id: actionToUndo._id}, {$set: {nextActionId: @_id}}
		else
			@_id = ModelActions.insert databaseObject

	update: (updateOptions) ->
		ModelActions.update {_id: @_id}, updateOptions

class ModelActionAddObject extends ModelAction
	validateSpecifics: (options) ->
		if not options.specifics.object
			throw new Meteor.Error 490, 'No object passed to specifics (options.specifics.object) of model action addObject!'
		if not options.specifics.object.position
			throw new Meteor.Error 490, 'No position passed to specifics object (options.specifics.object.position) of model action addObject!'
		if not options.specifics.object.position.x
			throw new Meteor.Error 490, 'No x value passed to specifics object\'s position (options.specifics.object.position.x) of model action addObject!'
		if not options.specifics.object.position.y
			throw new Meteor.Error 490, 'No y value passed to specifics object\'s position (options.specifics.object.position.y) of model action addObject!'
		if not options.specifics.object.position.z
			throw new Meteor.Error 490, 'No z value passed to specifics object\'s position (options.specifics.object.position.z) of model action addObject!'
		if not options.specifics.object.modelId
			throw new Meteor.Error 490, 'No model id passed to specifics object (options.specifics.object.modelId) of model action addObject!'
		if options.specifics.object.modelId isnt options.modelId
			throw new Meteor.Error 490, 'Incorrect model id passed to specifics object (options.specifics.object.modelId) of model action addObject. Must be the same as options.modelId!'
	do: ->
		@specifics.objectId = ModelObjects.insert @specifics.object
		@update $set: 'specifics.objectId': @specifics.objectId

	undo: ->
		ModelObjects.remove _id: @specifics.objectId

ModelActionConstructors.addObject = ModelActionAddObject

Meteor.methods
	doModelAction: (options) ->
		ActionConstructor = ModelActionConstructors[options?.type]
		if ActionConstructor
			action = new ActionConstructor options
			action.do()
			setModelActionIds
				modelId: action.modelId
				undoActionId: action._id
				redoActionId: null
		else
			throw new Meteor.Error 490, 'Model action ' + options?.type + ' does not exist!'

	undoModelAction: (options) ->
		actionObject = getModelActionToUndo options?.modelId
		if actionObject
			ActionConstructor = ModelActionConstructors[actionObject.type]
			if ActionConstructor
				action = new ActionConstructor actionObject
				action.undo()
				previousActionId = actionObject.previousActionId ? null
				setModelActionIds
					modelId: action.modelId
					undoActionId: previousActionId
					redoActionId: action._id

	redoModelAction: (options) ->
		actionObject = getModelActionToRedo options?.modelId
		if actionObject
			ActionConstructor = ModelActionConstructors[actionObject.type]
			if ActionConstructor
				action = new ActionConstructor actionObject
				action.do()
				nextActionId = actionObject.nextActionId ? null
				setModelActionIds
					modelId: action.modelId
					undoActionId: action._id
					redoActionId: nextActionId

	createModel: (options) ->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic})
			return modelId

	cloneModel: (options) ->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			transactionManager.commit()
			modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic})
			predecessorModelObjects = ModelObjects.find({modelId:options.predecessor}).fetch()
			ModelObjects.insert({position: i.position, modelId: modelId}) for i in predecessorModelObjects
			return modelId		

	updateModelName: (options) ->
		checkNameAvailability = findModelByName options.name
		optionsFind = {_id: options._id}
		currentModel = findOneModelByOptions(optionsFind)
		if checkNameAvailability && options.name != currentModel.name
			throw new Meteor.Error(499, "Modelname already taken");
		else
			return Models.update({_id: options._id},{$set: {name: options.name}})

	updateModelIsPublic: (options) ->
		isPublic = options.isPublic
		if options.isPublic == false
			isPublic = true
		else
			isPublic = false
		return Models.update({_id: options._id},{$set: {isPublic: isPublic}})

	updateModelTag: (options) ->
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

	updateModelInvite: (options) ->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		if options.invite.length < 3
			throw new Meteor.Error(497, "Username too short");
		invitedProfile = Profiles.findOne({name: options.invite})

		if invitedProfile == undefined
			throw new Meteor.Error(496, "Username does not exist");
		else
			checkAlreadyInvited = Models.findOne({_id: options._id,'invited.userId':invitedProfile._id})
		if checkAlreadyInvited == undefined
			updateObject = {userId: invitedProfile._id, role: options.role}
			Models.update({_id: options._id},{$push: {invited: updateObject}})				
		else
			throw new Meteor.Error(498, "User already invited")		

	removeModelTag: (options) ->
		if options._id == undefined || options.tag == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			return Models.update({_id: options._id},{$pull: {tags: options.tag}})

	removeModelInvite: (options) ->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			profile = findOneProfileByOptions({name: options.invite})
			if profile == undefined
				throw new Meteor.Error(496, "Username does not exist");
			else
				removeObject = {invited:{userId:profile._id}}
				return Models.update({_id: options._id},{$pull: removeObject})

	removeModel: (options)->
		#console.log options
		return Models.remove(options)

@modelLoaded = ->
	#console.log "modelLoaded"
	model = Models.findOne({})
	#console.log model
	if model == undefined
		return false
	else
		return true

@findModelByName = (name)->
	return Models.findOne({name: name})

@findOneModelByOptions = (options) ->
	return Models.findOne(options)

# Gets the Modelid and a boolean (if isPublic should be used) as parameter
# Returns the Users Role for the specified Model
@checkModelPermission = (modelId, useIsPublic) ->
	options = {_id: modelId}
	model = findOneModelByOptions(options)
	if model == undefined
		return Roles.none

	if Meteor.userId() == null
		if model.isPublic == true && useIsPublic == true
			return Roles.viewer
		else
			return Roles.none

	isCreator = findOneModelByOptions({_id:modelId,creator: currentProfile()._id})
	if model.invited != undefined
		isInvited = $.grep(model.invited, (e) ->
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
		if model.isPublic == true && useIsPublic == true
			#console.log "isPublic true"
			return Roles.viewer
		else
			return Roles.none	

@Roles =
	none: 0,
	viewer: 1,
	collaborator: 2,
	creator: 3,
	owner: 4
