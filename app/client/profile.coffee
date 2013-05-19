Meteor.startup ->
  filepicker.setKey "AgE9nNiTnRKy1s8bU4zbuz"
  filepicker.constructWidget document.getElementById("attachment")

Template.profile.userName = ->
	Profiles.findOne(_id: Session.get("profileId")).name

Template.profile.email = ->
	Profiles.findOne(_id: Session.get("profileId")).email

Template.profile.www = ->
	Profiles.findOne(_id: Session.get("profileId")).www

Template.profile.rendered = ->
	filepicker.constructWidget document.getElementById('uploadWidget')

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

Template.profile.pictureUrl = ->
	currentProfile().picture