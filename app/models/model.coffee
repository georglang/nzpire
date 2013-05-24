# # Model

@Models = new Meteor.Collection 'models'
@ModelObjects = new Meteor.Collection 'modelObjects'

# ## Model Action

@ModelActions = new Meteor.Collection 'modelActions'

ModelActionConstructors = {}
ModelObjectTypes = [
	'voxel'
]

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
		if not options.specifics.object.type
			throw new Meteor.Error 490, 'No type passed to specifics object (options.specifics.object.type) of model action addObject!'
		if ModelObjectTypes.indexOf(options.specifics.object.type) is -1
			throw new Meteor.Error 490, 'Invalid type ' + options.specifics.object.type + ' passed to specifics object (options.specifics.object.type) of model action addObject. Valid object types are: ' + ModelObjectTypes.join ', '
		if not options.specifics.object.position
			throw new Meteor.Error 490, 'No position passed to specifics object (options.specifics.object.position) of model action addObject!'
		if not options.specifics.object.position.x
			throw new Meteor.Error 490, 'No x value passed to specifics object\'s position (options.specifics.object.position.x) of model action addObject!'
		if not options.specifics.object.position.y
			throw new Meteor.Error 490, 'No y value passed to specifics object\'s position (options.specifics.object.position.y) of model action addObject!'
		if not options.specifics.object.position.z
			throw new Meteor.Error 490, 'No z value passed to specifics object\'s position (options.specifics.object.position.z) of model action addObject!'
		if not options.specifics.object.color
			throw new Meteor.Error 490, 'No color passed to specifics object (options.specifics.object.color) of model action addObject!'
		colorAsInteger = parseInt options.specifics.object.color, 16
		if isNaN(colorAsInteger) or colorAsInteger < 0 or colorAsInteger > 16777215
			throw new Meteor.Error 490, 'Invalid color passed to specifics object (options.specifics.object.color) of model action addObject. Valid color values are hexadecimal strings from 000000 to FFFFFF.'
		# Specifics for type 'voxel':
		# * size
		if options.specifics.object.type == 'voxel'
			if not options.specifics.object.size
				throw new Meteor.Error 490, 'No size passed to specifics object for type voxel (options.specifics.object.size) of model action addModel!'
		options.specifics.object.modelId = options.modelId
	do: ->
		if @specifics.objectId
			@specifics.object._id = @specifics.objectId
			ModelObjects.insert @specifics.object
		else
			@specifics.objectId = ModelObjects.insert @specifics.object
			@update $set: 'specifics.objectId': @specifics.objectId
	undo: ->
		ModelObjects.remove _id: @specifics.objectId

ModelActionConstructors.addObject = ModelActionAddObject

class ModelActionRemoveObject extends ModelAction
	validateSpecifics: (options) ->
		if not options.specifics.objectId
			throw new Meteor.Error 490, 'No object id passed to specifics (options.specifics.objectId) of model action removeObject!'
		if not options._id
			options.specifics.object = ModelObjects.findOne _id: options.specifics.objectId
			if not options.specifics.object
				throw new Meteor.Error 490, 'Invalid object id ' + options.specifics.objectId + ' passed to specifics (options.specifics.objectId) of model action removeObject!'
	do: ->
		ModelObjects.remove _id: @specifics.objectId
	undo: ->
		ModelObjects.insert @specifics.object

ModelActionConstructors.removeObject = ModelActionRemoveObject


###################################################################################################
################################### METHODS #######################################################
###################################################################################################

Meteor.methods
	doModelAction: (options) ->
		modelPermission = checkModelPermission options.modelId, true
		mayDoAction = modelPermission >= Roles.collaborator
		if mayDoAction
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
		modelPermission = checkModelPermission options.modelId, true
		mayDoAction = modelPermission >= Roles.owner
		if mayDoAction
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
		modelPermission = checkModelPermission options.modelId, true
		mayDoAction = modelPermission >= Roles.owner
		if mayDoAction
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
			modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic,colors:DefaultModelColors})
			return modelId

	cloneModel: (options) ->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			predecessorModel = findOneModelByOptions({_id:options.predecessor})
			modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic,colors:predecessorModel.colors})
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
		isInvited = []
		for invitation in model.invited
			if invitation.userId == currentProfile()._id
				isInvited.push invitation
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
	owner: 3,
	creator: 4


@DefaultModelColors = [
	{index: 0, color: "FF0000"}
	{index: 1, color: "FF00D9"}
	{index: 2, color: "2600FF"}
	{index: 3, color: "00E1FF"}
	{index: 4, color: "00FF2F"}
	{index: 5, color: "EAFF00"}
	{index: 6, color: "FF9D00"}
	{index: 7, color: "FF3C00"}
	{index: 8, color: "ffffff"}
	{index: 9, color: "000000"}
	]

@DefaultVoxelSizes = [
	{index: 0, size: 1}
	{index: 1, size: 2}
	{index: 2, size: 3}
	{index: 3, size: 4}
	{index: 4, size: 5}
	]