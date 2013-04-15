(function(){ var connectProfiles;

connectProfiles = function(tmpEmail, loginFunction) {
  var newProfile, service, service_id, tmpProfile, updateObject;
  tmpProfile = Profiles.findOne({
    email: tmpEmail
  });
  newProfile = Profiles.findOne({
    email: currentEmail()
  });
  service = Object.keys(Meteor.user().services)[0];
  service_id = Meteor.user().services[service].id;
  updateObject = {
    services: {}
  };
  updateObject.services[service] = service_id;
  Profiles.update({
    _id: tmpProfile._id
  }, {
    $push: updateObject
  });
  Profiles.update({
    _id: tmpProfile._id
  }, {
    $push: {
      email: currentEmail()
    }
  });
  Profiles.update({
    _id: tmpProfile._id
  }, {
    $set: {
      updatedAt: new Date()
    }
  });
  return Profiles.remove({
    _id: newProfile._id
  });
};

Template.index.redirectToNewsIfLoggedIn = function() {
  if (Meteor.user() !== null) {
    return Workspace.news();
  }
};

Template.index.connectButtons = function() {
  var element, i, inArray, service, serviceArray, services, tmpProfile;
  services = ["Facebook", "Twitter", "Google", "Github"];
  tmpProfile = Profiles.find({
    email: currentEmail()
  }).fetch()[0];
  serviceArray = tmpProfile.services;
  i = 0;
  while (i < serviceArray.length) {
    element = serviceArray[i];
    service = Object.keys(element)[0].charAt(0).toUpperCase() + Object.keys(element)[0].slice(1);
    inArray = $.inArray(service, services);
    if (inArray !== -1) {
      services.splice(inArray, 1);
    }
    ++i;
  }
  return services;
};

Template.index.events({
  'click input#connectWithFacebook': function() {
    var tmpEmail;
    tmpEmail = currentEmail();
    Meteor.loginWithFacebook({
      requestOfflineToken: [true]
    }, function() {
      return connectProfiles(tmpEmail, Meteor.loginWithFacebook);
    });
    return true;
  },
  'click input#connectWithGithub': function() {
    var tmpEmail;
    tmpEmail = currentEmail();
    Meteor.loginWithGithub({
      requestOfflineToken: [true]
    }, function() {
      return connectProfiles(tmpEmail, Meteor.loginWithGithub);
    });
    return true;
  },
  'click input#connectWithGoogle': function() {
    var tmpEmail;
    tmpEmail = currentEmail();
    Meteor.loginWithGoogle({
      requestOfflineToken: [true]
    }, function() {
      return connectProfiles(tmpEmail, Meteor.loginWithGoogle);
    });
    return true;
  },
  'click input#connectWithTwitter': function() {
    var tmpEmail;
    tmpEmail = currentEmail();
    Meteor.loginWithTwitter({
      requestOfflineToken: [true]
    }, function() {
      return connectProfiles(tmpEmail, Meteor.loginWithTwitter);
    });
    return true;
  }
});

Meteor.autorun(function() {
  Meteor.subscribe("userData");
  Meteor.subscribe("allProfiles");
  Meteor.subscribe("allCubes");
  return Meteor.subscribe("allModels");
});

Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
});

})();
