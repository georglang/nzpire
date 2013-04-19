Meteor.autorun ->
	Meteor.subscribe "userData"
	Meteor.subscribe "allProfiles"
	Meteor.subscribe "allCubes"
	Meteor.subscribe "allModels"

Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
});