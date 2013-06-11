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

# # Model_Chat

# ## Model Messages
# * return: array
Template.chat.messages = ->
	messages = ModelChat.find({modelId: Session.get('modelId')}).fetch()

# ## Message Publisher
# * return: string
Template.message.publisher = ->
	publisher = Profiles.findOne({_id:this.publisherId})
	return publisher?.name

# ## Message Timestamp
# * return: object (.minutes, .hours)
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

Template.chat.rendered = ->
	#$('.scroller').scrollTop($('.scroller')[0]?.scrollHeight);

# ## Events
# ### Submit entered Message
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
				Meteor.call 'createMessage', options, (err,result)->
					if err
						console.log err.reason