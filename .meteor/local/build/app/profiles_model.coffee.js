
this.Profiles = new Meteor.Collection('profiles');

this.findOneProfileByOptions = function(options) {
  return Profiles.findOne(options);
};
