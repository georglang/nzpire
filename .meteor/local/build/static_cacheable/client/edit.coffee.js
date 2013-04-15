(function(){ 
Template.edit.userName = function() {
  return currentProfile().name;
};

Template.edit.email = function() {
  return currentEmail();
};

Template.edit.www = function() {
  return currentProfile().www;
};

Template.edit.events({
  'click div#submitEdit': function() {
    var editUsername, editWww;
    editUsername = $("#editUsername").val();
    editWww = $("#editWww").val();
    Profiles.update({
      _id: currentProfile()._id
    }, {
      $set: {
        name: editUsername
      }
    });
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $set: {
        www: editWww
      }
    });
  }
});

})();
