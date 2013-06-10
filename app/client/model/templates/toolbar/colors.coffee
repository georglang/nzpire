# # Model_Colors

# ## Model Color
# * return: array
Template.modelingColors.getModelColors = ->
	model = findOneModelByOptions({_id: Session.get('modelId')})
	if model == undefined
		return null
	return model.colors

# ## Is Current Color
# * return: bool
Template.modelingColors.isCurrentColor = ()->
	if Session.get('modelingColor') == this.color
		return true
	else
		return false

# ## Events
# ### Sets the Session modelingColor to the clicked color
Template.modelingColors.events
	'click .modelingColor': (e)->
		model = findOneModelByOptions({_id: Session.get 'modelId'})
		if model == undefined
			return null
		else
			Session.set 'modelingColor', model.colors[$(e.target).data('index')].color
