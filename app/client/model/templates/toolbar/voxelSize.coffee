Template.voxelSizes.getVoxelSizes = ()->
	return DefaultVoxelSizes

Template.voxelSizes.isCurrentVoxelSize = ()->
	if Session.get('voxelSize') == this.size
		return true
	else
		return false

Template.voxelSizes.getSize = ->
	return this.size*10+10

Template.voxelSizes.getBottom = ->
	return DefaultVoxelSizes[DefaultVoxelSizes.length-1].size * 10 - this.size * 10

Template.voxelSizes.getBackground = ->
	return Session.get 'voxelColor'

Template.voxelSizes.events
	'click .voxelSize': (e)->
		Session.set 'voxelSize', DefaultVoxelSizes[e.target.id].size