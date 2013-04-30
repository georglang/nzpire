Template.model.modelLoaded = ->
  return modelLoaded()

Template.model.handleModelPermission = ->
	permission = checkModelPermission(Session.get('modelId'),true)
	if permission <= Roles.none
    Workspace.index()
