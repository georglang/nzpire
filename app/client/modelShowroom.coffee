# #Model_Showroom

# Gets all Models where the User has the expected Role    
# * params: Roles    
# * return: Array (models)   
userInvitedModels = (role)->
	tmpResult = Models.find({}).fetch()
	modelsResult = []
	tmpResult.forEach (i)->
		permission = checkModelPermission i._id,false
		if permission == role
			modelsResult.push i
		for model in modelsResult
			model.snapshotURL ?= '/img/dummyModel.jpg'
	return modelsResult

# ## Owner
# Template Method that returns all Models where the Users Role is Owner    
# * return: array (models)    
Template.modelShowroom.Owner = ()->
	userInvitedModels(Roles.owner)

# ## Creator
# Template Method that returns all Models where the Users Role is Creator    
# * return: array (models)    
Template.modelShowroom.Creator = ()->
	userInvitedModels(Roles.creator)

# ## Collaborator
# Template Method that returns all Models where the Users Role is Collaborator    
# * return: array (models)    
Template.modelShowroom.Collaborator = ()->
	userInvitedModels(Roles.collaborator)

# ## Viewer
# Template Method that returns all Models where the Users Role is Viewer    
# * return: array (models)    
Template.modelShowroom.Viewer = ()->
	userInvitedModels(Roles.viewer)

# ## Events
# Model_Showroom events: click event for redirecting to the specified Model
Template.modelShowroom.events
	'click div.modelLink': (e)->
		Workspace.model $(e.currentTarget).data("id")


# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.modelShowroom.rendered = ()->
	$('#modelShowroomTemplate').addClass('activeTemplate')

Template.modelShowroom.destroyed = ()->
	$('#modelShowroomTemplate').removeClass('activeTemplate')