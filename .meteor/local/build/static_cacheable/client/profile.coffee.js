(function(){ 
Template.profile.userName = function() {
  return currentProfile().name;
};

Template.profile.email = function() {
  return currentEmail();
};

Template.profile.www = function() {
  return currentProfile().www;
};

})();
