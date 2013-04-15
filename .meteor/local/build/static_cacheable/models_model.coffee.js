(function(){ 
this.Cubes = new Meteor.Collection('cubes');

this.Models = new Meteor.Collection('models');

Meteor.methods({
  createModel: function(options) {
    var checkNameAvailability;
    checkNameAvailability = findModelByName(options.name);
    if (checkNameAvailability) {
      throw new Meteor.Error(499, "Modelname already taken");
    } else {
      return Models.insert({
        name: options.name,
        createdAt: new Date(),
        updatedAt: new Date(),
        tags: [],
        creator: options.creator,
        invited: [],
        predecessor: options.predecessor,
        isPublic: options.isPublic
      });
    }
  },
  updateModelName: function(options) {
    var checkNameAvailability, currentModel, optionsFind;
    checkNameAvailability = findModelByName(options.name);
    optionsFind = {
      _id: options._id
    };
    currentModel = findOneModelByOptions(optionsFind);
    if (checkNameAvailability && options.name !== currentModel.name) {
      throw new Meteor.Error(499, "Modelname already taken");
    } else {
      return Models.update({
        _id: options._id
      }, {
        $set: {
          name: options.name
        }
      });
    }
  },
  updateModelIsPublic: function(options) {
    var isPublic;
    isPublic = options.isPublic;
    if (options.isPublic === false) {
      isPublic = true;
    } else {
      isPublic = false;
    }
    return Models.update({
      _id: options._id
    }, {
      $set: {
        isPublic: isPublic
      }
    });
  },
  updateModelTag: function(options) {
    var checkForAvailability, tagName;
    if (options._id === void 0 || options.tag === void 0) {
      throw new Meteor.Error(490, "Undefined Parameter");
    }
    tagName = options.tag;
    checkForAvailability = Models.findOne({
      _id: options._id,
      tags: tagName
    });
    if (tagName.length < 3) {
      throw new Meteor.Error(497, "Tagname too short");
    } else if (checkForAvailability !== void 0) {
      throw new Meteor.Error(498, "Tagname already added");
    } else {
      return Models.update({
        _id: options._id
      }, {
        $push: {
          tags: tagName
        }
      });
    }
  },
  updateModelInvite: function(options) {
    var checkAlreadyInvited, invitedProfile, updateObject;
    if (options._id === void 0 || options.invite === void 0) {
      throw new Meteor.Error(490, "Undefined Parameter");
    }
    if (options.invite.length < 3) {
      throw new Meteor.Error(497, "Username too short");
    }
    invitedProfile = Profiles.findOne({
      name: options.invite
    });
    if (invitedProfile === void 0) {
      throw new Meteor.Error(496, "Username does not exist");
    } else {
      checkAlreadyInvited = Models.findOne({
        _id: options._id,
        'invited.userId': invitedProfile._id
      });
    }
    if (checkAlreadyInvited === void 0) {
      updateObject = {
        userId: invitedProfile._id,
        role: options.role
      };
      return Models.update({
        _id: options._id
      }, {
        $push: {
          invited: updateObject
        }
      });
    } else {
      throw new Meteor.Error(498, "User already invited");
    }
  },
  removeModelTag: function(options) {
    if (options._id === void 0 || options.tag === void 0) {
      throw new Meteor.Error(490, "Undefined Parameter");
    } else {
      return Models.update({
        _id: options._id
      }, {
        $pull: {
          tags: options.tag
        }
      });
    }
  },
  removeModelInvite: function(options) {
    var profile, removeObject;
    if (options._id === void 0 || options.invite === void 0) {
      throw new Meteor.Error(490, "Undefined Parameter");
    } else {
      profile = findOneProfileByOptions({
        name: options.invite
      });
      if (profile === void 0) {
        throw new Meteor.Error(496, "Username does not exist");
      } else {
        removeObject = {
          invited: {
            userId: profile._id
          }
        };
        return Models.update({
          _id: options._id
        }, {
          $pull: removeObject
        });
      }
    }
  }
});

this.modelLoaded = function() {
  var model;
  model = Models.findOne({});
  if (model === void 0) {
    return false;
  } else {
    return true;
  }
};

this.findModelByName = function(name) {
  return Models.findOne({
    name: name
  });
};

this.findOneModelByOptions = function(options) {
  return Models.findOne(options);
};

this.checkModelPermission = function(modelId) {
  var isCreator, isInvited, model, options;
  options = {
    _id: modelId
  };
  model = findOneModelByOptions(options);
  if (model === void 0) {
    return Roles.none;
  }
  if (Meteor.userId() === null) {
    if (model.isPublic === true) {
      return Roles.viewer;
    } else {
      return Roles.none;
    }
  }
  isCreator = findOneModelByOptions({
    _id: modelId,
    creator: currentProfile()._id
  });
  if (model.invited !== void 0) {
    isInvited = $.grep(model.invited, function(e) {
      return e.userId === currentProfile()._id;
    });
    if (isInvited.length > 0) {
      if (isInvited[0].role === "owner") {
        return Roles.owner;
      } else if (isInvited[0].role === "collaborator") {
        return Roles.collaborator;
      } else if (isInvited[0].role === "viewer") {
        return Roles.viewer;
      }
    }
  }
  if (isCreator) {
    return Roles.creator;
  } else {
    if (model.isPublic === true) {
      return Roles.viewer;
    } else {
      return Roles.none;
    }
  }
};

this.Roles = {
  none: 0,
  viewer: 1,
  collaborator: 2,
  creator: 3,
  owner: 3
};

})();
