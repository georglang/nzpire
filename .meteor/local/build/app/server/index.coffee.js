
Meteor.startup(function() {});

Meteor.publish("userData", function() {
  return Meteor.users.find({
    _id: this.userId
  }, {
    fields: {
      'services': 1,
      'mail': 1
    }
  });
});

Meteor.publish("allProfiles", function() {
  return Profiles.find({});
});

Meteor.publish("allCubes", function() {
  return Cubes.find({});
});

Meteor.publish("allModels", function() {
  return Models.find({});
});
