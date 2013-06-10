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

# # Configuration

# Subscribe all necessary Collections
Meteor.autorun ->
	Meteor.subscribe "userData"
	Meteor.subscribe "allProfiles"
	Meteor.subscribe "allCubes"
	Meteor.subscribe "allModels"


# Configures the account creation to use Email and Username
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
});