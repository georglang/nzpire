Template.chat.messages = ->
	messages = ModelChat.find({modelId: Session.get('modelId')}).fetch()
	return messages

Template.message.publisher = ->
	publisher = Profiles.findOne({_id:this.publisherId})
	return publisher?.name

Template.message.timestamp = ->
	minutes = this.timestamp.getMinutes()
	hours = this.timestamp.getHours()

	if this.timestamp.getMinutes() < 10
		minutes = '0' + this.timestamp.getMinutes()
	if this.timestamp.getHours < 10
		hours = '0' + this.timestamp.getHours()

	time = 
		hours: this.timestamp.getHours()
		minutes: minutes
	return time

Template.message.rendered = ->
	console.log "rendered"
	$('.chatBox>div:last').focus()
	$('#newMessage').focus()

Template.chat.events
	'keydown': (e) ->
		if e.keyCode == 13
			message = $('#newMessage').val()
			if message.length > 0
				$('#newMessage').val('')
				options = 
					modelId: Session.get 'modelId'
					message: message
					publisher: currentProfile()._id
				Meteor.call 'createMessage', options, (result,err)->
					if err
						console.log err.reason