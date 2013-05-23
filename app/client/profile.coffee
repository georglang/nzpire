Meteor.startup ->
  filepicker.setKey "AgE9nNiTnRKy1s8bU4zbuz"
  filepicker.constructWidget document.getElementById("attachment")


Template.profile.userName = ->
	Profiles.findOne(_id: Session.get("profileId")).name

Template.profile.email = ->
	Profiles.findOne(_id: Session.get("profileId")).email

Template.profile.www = ->
	Profiles.findOne(_id: Session.get("profileId")).www

Template.profile.pictureUrl = ->
	Profiles.findOne(_id: Session.get("profileId")).picture

Template.profile.rendered = ->
	filepicker.constructWidget document.getElementById('uploadWidget')

Template.profile.id = ->
	Session.get("profileId")

Template.profile.show = ->
  profileId = Session.get("profileId")
  getFollowingStatus(profileId)

checkForFollowing = (profile_id)->
	Profiles.find
		_id: currentProfile()._id
		following: profile_id

getFollowingStatus = (_id)->
	loggedIn = Meteor.userId()
	if (loggedIn != null) && (_id != currentProfile()._id)
		if checkForFollowing(_id).fetch().length > 0
			return "unfollow"
		else
			return "follow"


Template.profile.events

	'click span.editable': (e) ->
		target = $(e.currentTarget)
		attrValue = target.text()
		attrName = target.attr('id')
		console.log attrName
		input = $("<input id='"+attrName+"' rel='Your e-mail here' class='editable' type='text' value='"+attrValue+"'>")
		target.replaceWith(input)
		input.focus()

	'blur input': (e) ->
		target = $(e.currentTarget)
		attrValue = target.val()
		attrName = target.attr('id')
		target.replaceWith("<span id='"+attrName+"' class='editable' type='text'>"+attrValue+"")
		updateObject = {$set: {}}
		updateObject.$set[attrName] = attrValue #define variable for db query
		console.log updateObject
		Profiles.update({_id : currentProfile()._id}, updateObject)

	'click div.follow': (e)->
		Profiles.update {_id: currentProfile()._id},{$push: {following: e.target.id}}

	'click div.unfollow': (e) ->
		Profiles.update {_id: currentProfile()._id},{$pull:{following: e.target.id}}



# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.profile.rendered = ()->
	$('#profileTemplate').addClass('activeTemplate')

Template.profile.destroyed = ()->
	$('#profileTemplate').removeClass('activeTemplate')