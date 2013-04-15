
Meteor.startup(function() {
  return Profiles.allow({
    update: function(userId, doc, fields, modifier) {
      return true;
    }
  });
});
