
Meteor.startup(function() {});

Accounts.onCreateUser(function(options, user) {
  var checkForEmail, checkedEmail, emails, insertObject, service, serviceObject, service_id, updateObject, username;
  checkForEmail = function(email) {
    return Profiles.find({
      email: email[0]
    }).fetch();
  };
  service = Object.keys(user.services)[0];
  if (service === "password") {
    service = twitterEmail;
    emails = [];
    emails.push(options.email);
    if (checkForEmail(options.email).length > 0) {
      updateObject = {
        services: {}
      };
      updateObject.services[service] = service_id;
      Profiles.update({
        _id: checkedEmail[0]._id
      }, {
        $push: updateObject
      });
      Profiles.update({
        _id: checkedEmail[0]._id
      }, {
        $set: {
          updatedAt: new Date()
        }
      });
    } else {
      insertObject = {
        name: options.username,
        email: emails,
        services: []
      };
      serviceObject = {};
      serviceObject[service] = service_id;
      insertObject.services.push(serviceObject);
      Profiles.insert(insertObject);
    }
  } else {
    username = options.profile.name;
    service_id = user.services[service].id;
    if (service === "github") {
      username = user.services[service].username;
      options.profile.name = username;
      options.profile.email = Meteor.http.get('https://api.github.com/user/emails?access_token=' + user.services[service].accessToken).data;
      emails = options.profile.email;
      checkedEmail = checkForEmail(emails);
    } else if (service === "twitter") {
      emails = [];
      emails.push(user.services[service].screenName + "@" + twitterEmail + ".at");
      checkedEmail = checkForEmail(emails);
    } else {
      emails = [];
      emails.push(user.services[service].email);
      checkedEmail = checkForEmail(emails);
    }
    if (checkedEmail.length > 0) {
      updateObject = {
        services: {}
      };
      updateObject.services[service] = service_id;
      Profiles.update({
        _id: checkedEmail[0]._id
      }, {
        $push: updateObject
      });
      Profiles.update({
        _id: checkedEmail[0]._id
      }, {
        $set: {
          updatedAt: new Date()
        }
      });
    } else {
      insertObject = {
        name: username,
        email: emails,
        following: [],
        favourites: [],
        updatedAt: new Date(),
        services: [],
        www: ""
      };
      serviceObject = {};
      serviceObject[service] = service_id;
      insertObject.services.push(serviceObject);
      Profiles.insert(insertObject);
    }
    user.emails = emails;
  }
  user.profile = options.profile;
  user.mail = emails;
  return user;
});
