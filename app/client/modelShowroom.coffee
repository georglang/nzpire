# #Model_Showroom

# Function takes a Roles as parameter and returns all Models where the User has the expected Role
userInvitedModels = (role)->
	tmpResult = Models.find({}).fetch()
	modelsResult = []
	tmpResult.forEach (i)->
		permission = checkModelPermission i._id,false
		if permission == role
			modelsResult.push i
	return modelsResult

# Template Method that returns all Models where the Users Role is Owner
Template.modelShowroom.Owner = ()->
	userInvitedModels(Roles.owner)

# Template Method that returns all Models where the Users Role is Creator
Template.modelShowroom.Creator = ()->
	userInvitedModels(Roles.creator)

# Template Method that returns all Models where the Users Role is Collaborator
Template.modelShowroom.Collaborator = ()->
	userInvitedModels(Roles.collaborator)

# Template Method that returns all Models where the Users Role is Viewer
Template.modelShowroom.Viewer = ()->
	userInvitedModels(Roles.viewer)

# Model_Showroom events: click event for redirecting to the specified Model
Template.modelShowroom.events
	'click div.modelLink': (e)->
		Workspace.model e.target.id