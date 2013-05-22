Template.colors.getModelColors = ->
	model = findOneModelByOptions({_id: Session.get('modelId')})
	if model == undefined
		return null
	return model.colors
Template.colors.isCurrentColor = ()->
	if Session.get('modelColor') == this.color
		return true
	else
		return false

Template.colors.events
	'click .modelColor': (e)->
		model = findOneModelByOptions({_id: Session.get 'modelId'})
		if model == undefined
			return null
		else
			Session.set 'modelColor', model.colors[e.target.id].color
