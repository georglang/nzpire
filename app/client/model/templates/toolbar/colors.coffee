Template.modelingColors.getModelColors = ->
	model = findOneModelByOptions({_id: Session.get('modelId')})
	if model == undefined
		return null
	return model.colors

Template.modelingColors.isCurrentColor = ()->
	if Session.get('modelingColor') == this.color
		return true
	else
		return false

Template.modelingColors.events
	'click .modelingColor': (e)->
		model = findOneModelByOptions({_id: Session.get 'modelId'})
		if model == undefined
			return null
		else
			Session.set 'modelingColor', model.colors[e.target.id].color
