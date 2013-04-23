Template.model.modelLoaded = ->
  return modelLoaded()

Template.model.handleModelPermission = ->
  permission = checkModelPermission(Session.get('modelId'))
  if permission <= Roles.none
    Workspace.index()
