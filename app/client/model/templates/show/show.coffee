Template.model.modelLoaded = ->
  return modelLoaded()

Template.model.handleModelPermission = ->
	permission = checkModelPermission(Session.get('modelId'),true)
	if permission <= Roles.none
    Workspace.index()


Template.model.rendered = ()->
	$('#modelTemplate').addClass('activeTemplate')
	THREEx.Screenshot.bindKey(renderer);

Template.model.destroyed = ()->
	$('#modelTemplate').removeClass('activeTemplate')