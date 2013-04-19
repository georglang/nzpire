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

Template.index.redirectToNewsIfLoggedIn = ->
	if Meteor.user() != null
		Workspace.news()