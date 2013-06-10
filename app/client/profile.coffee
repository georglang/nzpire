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

# #Profile 

# Get informations about the profile: name, email, www, picture
Template.profile.userName = ->
	Profiles.findOne(_id: Session.get("profileId")).name

Template.profile.email = ->
	Profiles.findOne(_id: Session.get("profileId")).email

Template.profile.www = ->
	Profiles.findOne(_id: Session.get("profileId")).www

Template.profile.pictureUrl = ->
	Profiles.findOne(_id: Session.get("profileId")).picture

Template.profile.id = ->
	Session.get("profileId")

Template.profile.show = ->
  profileId = Session.get("profileId")
  getFollowingStatus(profileId)

# Checks the following status 
checkForFollowing = (profile_id)->
	Profiles.find
		_id: currentProfile()._id
		following: profile_id

# Get the following status of viewed profile
getFollowingStatus = (_id)->
	loggedIn = Meteor.userId()
	if (loggedIn != null) && (_id != currentProfile()._id)
		if checkForFollowing(_id).fetch().length > 0
			return "unfollow"
		else
			return "follow"
# Returns profiles that current profile is following
Template.profile.currentProfileFollowProfiles = ->
	currentUser = Profiles.findOne(_id : Session.get("profileId"))
	profiles = Profiles.find({_id: {$in: currentUser.following}})
	return profiles

# Returns profiles that follow the current profile
Template.profile.getProfilesThatFollowCurrentProfile = ->
	currentUser = Profiles.findOne(_id : Session.get("profileId"))
	profiles = Profiles.find({ following : currentUser._id})
	return profiles

# Returns how much profiles the current profile is following
Template.profile.getFollowingLength = ->
	Profiles.findOne(_id: Session.get("profileId")).following.length

# Returns how much profiles follow the current profile
Template.profile.getFollowerLength = ->
	currentUser = Profiles.findOne(_id : Session.get("profileId"))
	profiles = Profiles.find({ following : currentUser._id}).fetch()
	return profiles.length

# Determin follow status and return class for follow button
Template.profile.followBtn = ->
	profileId = Session.get("profileId")
	followingStatus = getFollowingStatus(profileId)
	console.log "FOLLOWING Status", followingStatus
	if followingStatus == "follow"
		return "btn-primary"
	else
		return "btn-danger"

# Check if viewed profile is own profile
Template.profile.notOwnProfile = ->
	loggedIn = Meteor.userId()
	return (loggedIn != null) && (Session.get("profileId") != currentProfile()._id)


## Events
Template.profile.events
# changes clicked span to input field 
	'click span.editable': (e) ->
		target = $(e.currentTarget)
		attrValue = target.text()
		attrName = target.attr('id')
		console.log attrName
		input = $("<input id='"+attrName+"' rel='Your e-mail here' class='editable' type='text' value='"+attrValue+"'>")
		target.replaceWith(input)
		input.focus()

# changes in input field will be changed in database
	'blur input': (e) ->
		target = $(e.currentTarget)
		attrValue = target.val()
		attrName = target.attr('id')
		updateObject = {$set: {}}
		updateObject.$set[attrName] = attrValue #define variable for db query
		console.log updateObject
		console.log 'currentProfile id', currentProfile()._id
		Profiles.update({_id : currentProfile()._id}, updateObject)
		target.replaceWith("<span id='"+attrName+"' class='editable' type='text'>"+attrValue+"")
		
# changes following status to follow# #changes following status to follow
	'click div.follow': (e)->
		Profiles.update {_id: currentProfile()._id},{$push: {following: e.target.id}}

# changes following status to unfollow
	'click div.unfollow': (e) ->
		Profiles.update {_id: currentProfile()._id},{$pull:{following: e.target.id}}

# link to profiles that current profile is following and profiles that follow current profile
	'click div.linkToOtherProfile' : (e)->
		Workspace.profile $(e.currentTarget).data("id")
		console.log "Target", e.currentTarget

# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.profile.rendered = ()->
	$('#profileTemplate').addClass('activeTemplate')

Template.profile.destroyed = ()->
	$('#profileTemplate').removeClass('activeTemplate')
