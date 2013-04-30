# #News

getModelNews = ->
	#console.log "getModelNewsFunc"
	#profiles = Profiles.find({},{sort: {updatedAt: 1}).fetch()
	models = Models.find({_id: {$in: currentProfile().favourites}},{sort: {updatedAt:-1},limit: 10}).fetch()
	#jQuery.merge(profiles,models)
	return models

getProfileNews = ->
	#console.log "getProfileNewsFunc"
	profiles = Profiles.find({_id: {$in: currentProfile().following}},{sort: {updatedAt:-1},limit: 10}).fetch()
	return profiles

sortArrayByTimestamp = (a,b)->
	return -1 if a.updatedAt > b.updatedAt
	return 1 if a.updatedAt < b.updatedAt
	return 0


Template.news.getNews = ->
	#console.log "getNews"
	result = getModelNews()
	result2 = getProfileNews()
	jQuery.merge(result,result2)
	result.sort(sortArrayByTimestamp)
	return result



Template.news.rendered = ()->
	$('#newsTemplate').addClass('activeTemplate')

Template.news.destroyed = ()->
	$('#newsTemplate').removeClass('activeTemplate')