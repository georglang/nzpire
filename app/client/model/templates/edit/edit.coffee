Template.modelEdit.handleModelPermission = ->
  #console.log "handleModelPermission"
  #console.log checkModelPermission(Session.get('modelId'))
  permission = checkModelPermission(Session.get('modelId'))
  if permission < Roles.viewer
    Workspace.model('index')
  else if permission < Roles.collaborator
    Workspace.model(Session.get('modelId'))