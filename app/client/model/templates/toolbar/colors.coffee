Template.voxelColors.getModelColors = ->
	model = findOneModelByOptions({_id: Session.get('modelId')})
	if model == undefined
		return null
	return model.colors

Template.voxelColors.isCurrentColor = ()->
	if Session.get('voxelColor') == this.color
		return true
	else
		return false

Template.voxelColors.events
	'click .voxelColor': (e)->
		model = findOneModelByOptions({_id: Session.get 'modelId'})
		if model == undefined
			return null
		else
			Session.set 'voxelColor', model.colors[e.target.id].color
