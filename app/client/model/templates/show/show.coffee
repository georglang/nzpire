Template.model.modelLoaded = ->
  return modelLoaded()

Template.model.handleModelPermission = ->
	permission = checkModelPermission(Session.get('modelId'),true)
	if permission <= Roles.none
    Workspace.index()


Template.model.rendered = ()->
	$('#modelTemplate').addClass('activeTemplate')
	$('footer').addClass('activeModeling')
	$('.navbar').addClass('activeNavModeling')

Template.model.destroyed = ()->
	$('#modelTemplate').removeClass('activeTemplate')
	$('footer').removeClass('activeModeling')
	$('.navbar').removeClass('activeNavModeling')