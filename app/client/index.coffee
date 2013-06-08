# # Landing_page

# Checks the Browserlanguage
language = window.navigator.userLanguage || window.navigator.language
if language.length > 2
	language = language.replace(/-/g,"_")
#console.log language
Meteor.setLocale(language);
#console.log "----------------- I18N ---------------------------"

#A message with placeholder
translatedMessage = __('someNamespace.optionalSubNamespace.yourMessage', {message: 'some placeholder content'})
#console.log translatedMessage
#A message without placeholder
anotherMessage = __('someNamespace.optionalSubNamespace.anUntranslatedMessage')
#console.log anotherMessage

Template.index.descriptionText = ->
	text = __('someNamespace.optionalSubNamespace.appDescription')
	return text

# ## Rendered and Destroyed
# Adds the activeTemplate Class (fade in effect) on rendering and removes it on destroy
Template.index.rendered = ()->
	$('#indexTemplate').addClass('activeTemplate')

Template.index.destroyed = ()->
	$('#indexTemplate').removeClass('activeTemplate')


Meteor.autorun ->
	$(".carousel").each ->
	  $(this).carousel
	    interval: 2000
	 
	if Meteor.user() && Session.get('template') == 'index'
		Workspace.news()

