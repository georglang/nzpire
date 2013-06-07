# #News

# ## Model News
# Gets the 10 latest updated models the current user favourites    
# * return: cursor
getModelNews = ->
	#console.log "getModelNewsFunc"
	#profiles = Profiles.find({},{sort: {updatedAt: 1}).fetch()
	if not currentProfile()?.favourites
		console.log "not currentProfile favourites"
		return null
	models = Models.find({_id: {$in: currentProfile().favourites}},{sort: {updatedAt:-1},limit: 10}).fetch()
	#jQuery.merge(profiles,models)
	return models

# ## Profile News
# Gets the 10 latest updated profiles the current user follows    
# * return: cursor
getProfileNews = ->
	if not currentProfile()?.following
		console.log "not currentProfile following"
		return null	
	#console.log "getProfileNewsFunc"
	profiles = Profiles.find({_id: {$in: currentProfile().following}},{sort: {updatedAt:-1},limit: 10}).fetch()
	return profiles

# ## Sort Function
# Sorts an array by timestamps    
# * params: object, object  (with .updatedAt)    
# * return: integer (-1,0,1)
sortArrayByTimestamp = (a,b)->
	return -1 if a.updatedAt > b.updatedAt
	return 1 if a.updatedAt < b.updatedAt
	return 0

# ## News
# Gets the model and profile news and merges them    
# * return: array () (models and profiles merged and sorted)
Template.news.getNews = ->
	#console.log "getNews"
	result = getModelNews()
	result2 = getProfileNews()
	if not result or not result2
		console.log "not result or not result 2"
		return null
	jQuery.merge(result,result2)
	result.sort(sortArrayByTimestamp)
	return result


Template.news.getRandomModels = ->
	allModels = Models.find({}).fetch()
	###
	models = []
	allModels.forEach (m)->
		permission = checkModelPermission m._id,true
		if permission > Roles.none	
			models.push m
	###

	#modelsShuffled = _.shuffle(models).slice(0,10)
	allModels = _.shuffle(allModels).slice(0,10)
	for model in allModels
		model.snapshotURL ?= '/img/dummyModel.jpg'
	return allModels


sortArrayByFavouritedCount = (a,b)->
	return -1 if a.favCounts > b.favCounts
	return 1 if a.favCounts < b.favCounts
	return 0

checkForFavourites = (_id)->
	if not currentProfile()?._id
		console.log "not currentProfile id"
		return null
	Profiles.find({
		favourites: _id
		}).fetch()

Template.news.getMostPopularModels = ->
	allModels = Models.find({}).fetch()
	allProfiles = Profiles.find({}).fetch()
	models = []
	allModels.forEach (m)->
		counter = 0
		modelFavourite = checkForFavourites m._id
		if modelFavourite.length > 0
			counter = modelFavourite.length
		m.favCounts = counter
		models.push m
	models.sort(sortArrayByFavouritedCount)
	return models

Template.news.events
	'click div.modelLink': (e)->
		Workspace.model e.target.title


# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.news.rendered = ()->
	$('#newsTemplate').addClass('activeTemplate')

Template.news.destroyed = ()->
	$('#newsTemplate').removeClass('activeTemplate')