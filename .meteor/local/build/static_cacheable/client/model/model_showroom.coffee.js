(function(){ 
Template.model.modelLoaded = function() {
  return modelLoaded();
};

Template.model.handleModelPermission = function() {
  var permission;
  permission = checkModelPermission(Session.get('model'));
  if (permission <= Roles.none) {
    return Workspace.index();
  }
};

Template.modelSidebar.isOwner = function() {
  if (Meteor.user() === null) {
    return false;
  } else {
    if (currentProfile()._id === findOneModelByOptions({
      _id: Session.get('model')
    }).creator) {
      return true;
    } else {
      return false;
    }
  }
};

Template.modelSidebar.modelname = function() {
  var model, name;
  model = findOneModelByOptions({
    _id: Session.get('model')
  });
  if (model === void 0) {
    return null;
  } else {
    name = model.name;
    if (name !== void 0) {
      return name;
    } else {
      return null;
    }
  }
};

Template.modelSidebar.updatedAt = function() {
  var d, updatedAt;
  updatedAt = findOneModelByOptions({
    _id: Session.get('model')
  }).updatedAt;
  if (updatedAt !== void 0) {
    d = new Date(updatedAt);
    return d.toUTCString();
  } else {
    return null;
  }
};

Template.modelSidebar.tags = function() {
  var tags;
  tags = findOneModelByOptions({
    _id: Session.get('model')
  }).tags;
  if (tags !== void 0) {
    if (Template.modelSidebar.isOwner()) {
      tags.push("");
    }
    return tags;
  } else {
    return null;
  }
};

Template.modelSidebar.creator = function() {
  var creatorId, name;
  creatorId = findOneModelByOptions({
    _id: Session.get('model')
  }).creator;
  if (creatorId !== "") {
    name = findOneProfileByOptions({
      _id: creatorId
    }).name;
    return name;
  } else {
    return null;
  }
};

Template.modelSidebar.invited = function() {
  var i, invitedPeople, names, _i, _len;
  names = [];
  invitedPeople = findOneModelByOptions({
    _id: Session.get('model')
  }).invited;
  if (invitedPeople !== void 0) {
    for (_i = 0, _len = invitedPeople.length; _i < _len; _i++) {
      i = invitedPeople[_i];
      names.push({
        name: findOneProfileByOptions({
          _id: i.userId
        }).name,
        role: i.role
      });
    }
    if (Template.modelSidebar.isOwner()) {
      names.push({
        name: "",
        role: ""
      });
    }
    return names;
  } else {
    return null;
  }
};

Template.modelSidebar.predecessor = function() {
  var name, predecessorId;
  predecessorId = findOneModelByOptions({
    _id: Session.get('model')
  }).predecessor;
  if (predecessorId !== "") {
    name = findOneModelByOptions({
      _id: predecessorId
    }).name;
    return name;
  } else {
    return null;
  }
};

Template.modelSidebar.isPublic = function() {
  var isPublic;
  isPublic = findOneModelByOptions({
    _id: Session.get('model')
  }).isPublic;
  if (isPublic !== void 0) {
    return isPublic;
  } else {
    return null;
  }
};

Template.modelSidebar.events({
  'click #slideContainerListItems>li>ul>li': function(e) {
    var className, invitedName, options, tagName;
    if (Template.modelSidebar.isOwner()) {
      className = e.target.className;
      if (className === 'modelname') {
        return $(e.target).replaceWith("<input autofocus='autofocus' id='editModelName' type='text' value='" + Template.modelSidebar.modelname() + "'>");
      } else if (className === 'tags') {
        tagName = $(e.target).html();
        if (tagName.length === 0) {
          return $(e.target).replaceWith("<input autofocus='autofocus' id='addTag' type='text' placeholder='Tagname'>");
        } else {
          options = {
            _id: Session.get('model'),
            tag: tagName
          };
          return Meteor.call('removeModelTag', options, function(error, result) {
            if (error) {
              return console.log(error.reason);
            }
          });
        }
      } else if (className === 'invited') {
        invitedName = $(e.target).html();
        if (invitedName.length === 0) {
          return $(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'><select id='invitedRole'><option value='owner'>Owner</option><option value='collaborator'>Collaborator</option><option value='viewer'>Viewer</option></select>");
        } else {
          options = {
            _id: Session.get('model'),
            invite: invitedName
          };
          return Meteor.call('removeModelInvite', options, function(error, result) {
            if (error) {
              return console.log(error.reason);
            }
          });
        }
      } else if (className === 'isPublic') {
        options = {
          _id: Session.get('model'),
          isPublic: Template.modelSidebar.isPublic()
        };
        return Meteor.call('updateModelIsPublic', options, function(error, result) {
          if (error) {
            return console.log(error.reason);
          }
        });
      }
    }
  },
  'blur #editModelName': function(e) {
    var modelName, options;
    modelName = e.target.value;
    if (modelName.length > 3) {
      if ($('#errorUpdateModelName')[0] !== void 0) {
        $('#errorUpdateModelName').remove();
      }
      options = {
        _id: Session.get('model'),
        name: modelName
      };
      return Meteor.call('updateModelName', options, function(error, result) {
        if (error) {
          return $('#editModelName').after("<div id='errorUpdateModelName'>" + error.reason + "</div>");
        }
      });
    }
  },
  'keydown #editModelName': function(e) {
    if (e.keyCode === 13) {
      return $('#editModelName').blur();
    }
  },
  'blur #addTag': function(e) {
    var options;
    if ($('#errorUpdateTag')[0] !== void 0) {
      $('#errorUpdateTag').remove();
    }
    options = {
      _id: Session.get('model'),
      tag: e.target.value
    };
    return Meteor.call('updateModelTag', options, function(error, result) {
      if (error) {
        return $('#addTag').after("<div id='errorUpdateTag'>" + error.reason + "</div>");
      }
    });
  },
  'keydown #addTag': function(e) {
    if (e.keyCode === 13) {
      return $('#addTag').blur();
    }
  },
  'blur #addInvite': function(e) {
    var options, role;
    if ($('#errorUpdateInvite')[0] !== void 0) {
      $('#errorUpdateInvite').remove();
    }
    role = $('#invitedRole').val();
    options = {
      _id: Session.get('model'),
      invite: e.target.value,
      role: role
    };
    return Meteor.call('updateModelInvite', options, function(error, result) {
      if (error) {
        return $('#addInvite').after("<div id='errorUpdateInvite'>" + error.reason + "</div>");
      }
    });
  },
  'keydown #addInvite': function(e) {
    if (e.keyCode === 13) {
      return $('#addInvite').blur();
    }
  },
  'click #favourite': function() {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $push: {
        favourites: Session.get('model')
      }
    });
  },
  'click #defavourite': function() {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $pull: {
        favourites: Session.get('model')
      }
    });
  },
  'click #clone': function(e) {
    if ($('#cloneModelName')[0] !== void 0) {
      $('#cloneModelName').remove();
      $('#createCloneModel').remove();
    }
    return $(e.target).after("<input type='text' id='cloneModelName' placeholder='Enter Modelname'><input type='button' id='createCloneModel' value='Create Clone'>");
  },
  'click #createCloneModel': function() {
    var modelName, options;
    modelName = $('#cloneModelName').val();
    if ($('#errorCloneModel')[0] !== void 0) {
      $('#errorCloneModel').remove();
    }
    options = {
      name: modelName,
      predecessor: Session.get('model'),
      creator: currentProfile()._id,
      isPublic: false
    };
    return Meteor.call('createModel', options, function(error, result) {
      if (error) {
        return $('#createNewModel').after("<div id='errorCloneModel'>" + error.reason + "</div>");
      } else {
        return Workspace.model(result);
      }
    });
  }
});

Template.modelSidebar.profilesList = function() {
  return Profiles.find({});
};

Template.modelSidebar.isFavourited = function() {
  var favourited;
  if (Meteor.user() === null) {
    return false;
  } else {
    favourited = findOneProfileByOptions({
      _id: currentProfile()._id,
      favourites: Session.get('model')
    });
    if (favourited === void 0) {
      return true;
    } else {
      return false;
    }
  }
};

Template.modelEdit.handleModelPermission = function() {
  var permission;
  permission = checkModelPermission(Session.get('model'));
  if (permission < Roles.viewer) {
    return Workspace.model('index');
  } else if (permission < Roles.collaborator) {
    return Workspace.model(Session.get('model'));
  }
};

})();
