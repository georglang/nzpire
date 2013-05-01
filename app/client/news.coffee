# #News

# ## Model News
# Gets the 10 latest updated models the current user favourites    
# * return: cursor
getModelNews = ->
	#console.log "getModelNewsFunc"
	#profiles = Profiles.find({},{sort: {updatedAt: 1}).fetch()
	models = Models.find({_id: {$in: currentProfile().favourites}},{sort: {updatedAt:-1},limit: 10}).fetch()
	#jQuery.merge(profiles,models)
	return models

# ## Profile News
# Gets the 10 latest updated profiles the current user follows    
# * return: cursor
getProfileNews = ->
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
	jQuery.merge(result,result2)
	result.sort(sortArrayByTimestamp)
	return result

# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.news.rendered = ()->
	$('#newsTemplate').addClass('activeTemplate')

Template.news.destroyed = ()->
	$('#newsTemplate').removeClass('activeTemplate')