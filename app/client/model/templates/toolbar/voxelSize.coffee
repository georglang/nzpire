# # Model_Voxelsize

# ## Voxel Sizes
# * return: array
Template.voxelSizes.getVoxelSizes = ()->
	return DefaultVoxelSizes

# ## Is Current Voxel Size
# * return: bool
Template.voxelSizes.isCurrentVoxelSize = ()->
	if Session.get('voxelSize') == this.size
		return true
	else
		return false

# ## CSS Style Calculations
Template.voxelSizes.getSize = ->
	return this.name*10+10

Template.voxelSizes.getBottom = ->
	return DefaultVoxelSizes[DefaultVoxelSizes.length-1].name * 10 - this.name * 10

Template.voxelSizes.getBackground = ->
	return Session.get 'modelingColor'


# ## Events
# ### Sets the Session voxelSize to the clicked size
Template.voxelSizes.events
	'click .voxelSize': (e)->
		Session.set 'voxelSize', DefaultVoxelSizes[$(e.target).data('index')].size