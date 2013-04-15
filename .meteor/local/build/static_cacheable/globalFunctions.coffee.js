(function(){ 
this.currentProfile = function() {
  return Profiles.find({
    email: currentEmail()
  }).fetch()[0];
};

this.currentEmail = function() {
  return Meteor.user().mail[0];
};

this.checkLoginProtection = function() {
  var currentTemplateInArray, currentTemplateSession;
  if (Meteor.user() === null) {
    currentTemplateSession = Session.get('template');
    currentTemplateInArray = $.inArray(currentTemplateSession, loginProtectionArray);
    if (currentTemplateInArray >= 0) {
      return Workspace.index();
    }
  }
};

this.loginProtectionArray = ["modelEdit", "news", "profile", "edit"];

})();
