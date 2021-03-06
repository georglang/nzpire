###
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
###

# # Model

@Models = new Meteor.Collection 'models'
@ModelObjects = new Meteor.Collection 'modelObjects'

# ## Chat Collection: _id, modelId, publisherId, message, timestamp
@ModelChat = new Meteor.Collection 'modelChat'

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

markModelAsUpdated = (options) ->
	Models.update {_id: options.modelId},
		$set:
			updatedAt: new Date()

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
				throw new Meteor.Error 490, 'No size passed to specifics object for type voxel (options.specifics.object.size) of model action addObject!'
			validSize = false
			for voxelSize in DefaultVoxelSizes
				if voxelSize.size == options.specifics.object.size
					validSize = true
					break
			if not validSize
				throw new Meteor.Error 490, 'Invalid voxel size ' + options.specifics.object.size + ' passed to specifics object for type voxel (options.specifics.object.size) of model action addObject!'
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

# ## Methods

Meteor.methods
	# ### Do model action
	doModelAction: (options) ->
		if userHasAtLeastRole options?.modelId, Roles.collaborator
			ActionConstructor = ModelActionConstructors[options?.type]
			if ActionConstructor
				action = new ActionConstructor options
				action.do()
				setModelActionIds
					modelId: action.modelId
					undoActionId: action._id
					redoActionId: null
				markModelAsUpdated modelId: options.modelId
		else
			throw new Meteor.Error 490, 'Model action ' + options?.type + ' does not exist!'

	# ### Undo model action
	undoModelAction: (options) ->
		if userHasAtLeastRole options?.modelId, Roles.owner
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
					markModelAsUpdated modelId: options.modelId

	# ### Redo model action
	redoModelAction: (options) ->
		if userHasAtLeastRole options?.modelId, Roles.owner
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
					markModelAsUpdated modelId: options.modelId

	# ### Create model
	createModel: (options) ->
		if not currentProfile()?._id
			throw new Meteor.Error(499, "You need to be logged in to create a Model")
			
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else if not options.name and not options.creator and not options.predecessor and not options.isPublic
			throw new Meteor.Error(499, "Paramters not defined");
		else
			modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic,colors:DefaultModelColors})
			Profiles.update {_id: currentProfile()._id},{$push: {favourites: modelId}}
			return modelId

	# ### Clone model
	cloneModel: (options) ->
		if userHasAtLeastRole options?.predecessor, Roles.viewer
			checkNameAvailability = findModelByName options.name
			if checkNameAvailability
				throw new Meteor.Error(499, "Modelname already taken");
			else
				predecessorModel = findOneModelByOptions({_id:options.predecessor})
				modelId = Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic,colors:predecessorModel.colors})
				predecessorModelObjects = ModelObjects.find({modelId:options.predecessor}).fetch()
				for predecessorModelObject in predecessorModelObjects
					delete predecessorModelObject._id
					predecessorModelObject.modelId = modelId
					ModelObjects.insert predecessorModelObject
				Profiles.update {_id: currentProfile()._id},{$push: {favourites: modelId}}
				return modelId

	# ### Update model name
	updateModelName: (options) ->
		if userHasAtLeastRole options?._id, Roles.owner
			checkNameAvailability = findModelByName options.name
			optionsFind = {_id: options._id}
			currentModel = findOneModelByOptions(optionsFind)
			if checkNameAvailability && options.name != currentModel.name
				throw new Meteor.Error(499, "Modelname already taken");
			else
				markModelAsUpdated modelId: options._id
				return Models.update({_id: options._id},{$set: {name: options.name}})

	# ### Update model's public state
	updateModelIsPublic: (options) ->
		if userHasAtLeastRole options?._id, Roles.owner
			isPublic = options.isPublic
			if options.isPublic == false
				isPublic = true
			else
				isPublic = false
			markModelAsUpdated modelId: options._id
			return Models.update({_id: options._id},{$set: {isPublic: isPublic}})

	# ### Update model tag
	updateModelTag: (options) ->
		if userHasAtLeastRole options?._id, Roles.collaborator
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

	# ### Update model invite
	updateModelInvite: (options) ->
		if userHasAtLeastRole options?._id, Roles.owner
			if options._id == undefined || options.invite == undefined
				throw new Meteor.Error(490, "Undefined Parameter");
			if options.invite.length < 3
				throw new Meteor.Error(497, "Username too short");
			invitedProfile = Profiles.findOne({name: options.invite})

			if invitedProfile == undefined
				throw new Meteor.Error(496, "Username does not exist");
			else if currentProfile()?.name == invitedProfile.name
				throw new Meteor.Error(490, "You cant invite yourself");
			else
				checkAlreadyInvited = Models.findOne({_id: options._id,'invited.userId':invitedProfile._id})
			if checkAlreadyInvited == undefined
				updateObject = {userId: invitedProfile._id, role: options.role}
				Models.update({_id: options._id},{$push: {invited: updateObject}})				
			else
				throw new Meteor.Error(498, "User already invited")		

	# ### Remove model tag
	removeModelTag: (options) ->
		if userHasAtLeastRole options?._id, Roles.collaborator
			if options._id == undefined || options.tag == undefined
				throw new Meteor.Error(490, "Undefined Parameter");
			else
				return Models.update({_id: options._id},{$pull: {tags: options.tag}})

	# ### Remove model invite
	removeModelInvite: (options) ->
		if userHasAtLeastRole options?._id, Roles.owner
			if options._id == undefined || options.invite == undefined
				throw new Meteor.Error(490, "Undefined Parameter");
			else
				profile = findOneProfileByOptions({name: options.invite})
				if profile == undefined
					throw new Meteor.Error(496, "Username does not exist");
				else
					removeObject = {invited:{userId:profile._id}}
					return Models.update({_id: options._id},{$pull: removeObject})

	# ### Remove model
	removeModel: (options)->
		if userHasAtLeastRole options?._id, Roles.owner
			if options._id == undefined || options.invite == undefined
				throw new Meteor.Error(490, "Undefined Parameter");
			ModelObjects.remove modelId: options._id
			ModelActions.remove modelId: options._id
			Models.remove options

	createMessage: (options)->
		if userHasAtLeastRole options?.modelId, Roles.viewer
			if options.modelId == undefined || options.publisher == undefined || options.message == undefined || options.color == undefined
				throw new Meteor.Error(490, "Undefined Parameter")
			ModelChat.insert({
				modelId: options.modelId,
				publisherId: options.publisher,
				message: options.message,
				timestamp: new Date(),
				msgcolor: options.color
			})

	# ### create an obj file and the corresponding mtl file
	saveModelToObjectFile: (options) ->
		if userHasAtLeastRole options?.id, Roles.viewer
			counter = 0
			verticesCounter = 0
			objFile = "# www.nzpire.me\nmtllib model.mtl\n"
			mtlFile = "# www.nzpire.me\n"
			
			model = ModelObjects.find(modelId:options.id).fetch()
			for o in model
				# save obj data of mesh, color and verticesOffset for faces in tmp
				tmp = convertMeshToObjAndColor(meshForObject(o), verticesCounter)
				
				verticesCounter = tmp.verticesCounter
				mtlResult = addColorToMtlFile tmp.color, mtlFile
				mtlFile = mtlResult.file
				
				objFile += "o Cube" + counter + "\n"
				objFile += "usemtl " + mtlResult.colorName + "\n"
				objFile += tmp.obj

				++counter
			
			files =
				obj: objFile
				mtl: mtlFile
			
			return files

# adds a new color to a mtl file if not already available and returns it
# returns the updated file and the color name for the obj file
@addColorToMtlFile = (color, file) ->
	name = ""
	colorCounter = 0
	isInFile = false

	lines = file.split("\n")
	lines.splice 0, 1
	for line in lines
		if line.match("Kd") != null
			rgb = line.substring(3, line.length).split(" ")
			
			# determine if color is already in the mtl file
			if(rgb[0] == color.r.toString() && rgb[1] == color.g.toString() && rgb[2] == color.b.toString())
				isInFile = true
				break
		else if line.match("newmtl") != null
			name = "color" + line.substring(line.length - 1, line.length)
			++colorCounter

	if !isInFile
		name = "color" + colorCounter
		file += "newmtl " + name + "\n"
		# only diffuse color is relevant online
		# to add specular color or ambient color add a line with Ks or Ka
		file += "Kd " + color.r + " " + color.g + " " + color.b + "\n"

	result =
		file: file
		colorName: name

	return result

# converts three js mesh data into the wavefront format
# returns data which contains the obj data of the mesh, the color in rgb, and the vertices offset for faces
@convertMeshToObjAndColor = (mesh, verticesOffset) ->
  mesh.updateMatrixWorld()
  geo = mesh.geometry
  num = geo.vertices.length
  obj = ""
  
  i = 0
  while i < geo.vertices.length
    vector = new THREE.Vector3(geo.vertices[i].x, geo.vertices[i].y, geo.vertices[i].z)
    vector.applyMatrix4(mesh.matrixWorld)
    obj += "v " + (vector.x) + " " + vector.y + " " + vector.z + "\n"
    i++
  
  i = 0
  while i < geo.faces.length
   	obj += "f " + (geo.faces[i].a + 1 + verticesOffset) + " " + (geo.faces[i].b + 1 + verticesOffset) + " " + (geo.faces[i].c + 1 + verticesOffset)
    obj += " " + (geo.faces[i].d + 1 + verticesOffset)  if geo.faces[i].d isnt `undefined`
    obj += "\n"
    i++

  data = 
  	obj: obj
  	color: mesh.material.color
  	verticesCounter: (verticesOffset + geo.vertices.length)

  return data


@modelLoaded = ->
	model = Models.findOne({})
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
				return Roles.owner
			else if isInvited[0].role == "collaborator"
				return Roles.collaborator
			else if isInvited[0].role == "viewer"
				return Roles.viewer
	if isCreator
		return Roles.creator
	else
		if model.isPublic == true && useIsPublic == true
			return Roles.viewer
		else
			return Roles.none

@userHasAtLeastRole = (modelId, role) ->
	modelPermission = checkModelPermission modelId, true
	mayDoAction = modelPermission >= role
	if mayDoAction
		return true
	throw new Meteor.Error 490, 'You don\'t have the permission to do this operation!'

@Roles =
	none: 0,
	viewer: 1,
	collaborator: 2,
	owner: 3,
	creator: 4

@DefaultModelColors = [
	{index: 0, color: "FF0000", shortcut: "1"}
	{index: 1, color: "FF00D9", shortcut: "2"}
	{index: 2, color: "2600FF", shortcut: "3"}
	{index: 3, color: "00E1FF", shortcut: "4"}
	{index: 4, color: "00FF2F", shortcut: "5"}
	{index: 5, color: "EAFF00", shortcut: "6"}
	{index: 6, color: "FFCC99", shortcut: "7"}
	{index: 7, color: "FF3C00", shortcut: "8"}
	{index: 8, color: "ffffff", shortcut: "9"}
	{index: 9, color: "000000", shortcut: "0"}
]

@DefaultVoxelSizes = [
	{index: 0, name: 1, size: 1}
	{index: 1, name: 2, size: 2}
	{index: 2, name: 3, size: 4}
	{index: 3, name: 4, size: 8}
	{index: 4, name: 5, size: 16}
]

