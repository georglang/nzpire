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

Template.model.handleModelPermission = ->
	permission = checkModelPermission(Session.get('modelId'),true)
	if permission <= Roles.none
    Workspace.index()

Template.model.isAtLeastCollaborator = ->
  permission = checkModelPermission(Session.get('modelId'),true)
  return permission >= Roles.collaborator

Template.model.rendered = ()->
	$('#modelTemplate').addClass('activeTemplate')

Template.model.created = ->
  Modeling.scene.setup()
  Meteor.defer Modeling.scene.update
  Modeling.interaction.mouseBindings.setup()

Template.model.destroyed = ()->
	$('#modelTemplate').removeClass('activeTemplate')
	$('footer').removeClass('activeModeling')
	$('.navbar').removeClass('activeNavModeling')
	Modeling.scene.shutdown();