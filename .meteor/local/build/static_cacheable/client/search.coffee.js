(function(){ var checkForFavourites, checkForFollowing, order, searchForModels, searchForProfiles;

searchForProfiles = function(searchQuery) {
  return Profiles.find({
    name: eval(searchQuery)
  });
  /*
  	Profiles.find( $or:[
  			email: eval(searchQuery)
  		,
  			name: eval(searchQuery)
  		])
  */

};

searchForModels = function(searchQuery) {
  var modelsResult, tmpResult;
  tmpResult = Models.find({
    name: eval(searchQuery)
  }).fetch();
  modelsResult = [];
  tmpResult.forEach(function(i) {
    var permission;
    permission = checkModelPermission(i._id);
    if (permission > Roles.none) {
      return modelsResult.push(i);
    }
  });
  return modelsResult;
};

checkForFollowing = function(_id) {
  return Profiles.find({
    _id: currentProfile()._id,
    following: _id
  });
};

checkForFavourites = function(_id) {
  return Profiles.find({
    _id: currentProfile()._id,
    favourites: _id
  });
};

order = function(searchingFor, _id) {
  var loggedIn;
  loggedIn = Meteor.userId();
  if (searchingFor === "profileLink" && loggedIn !== null) {
    if (checkForFollowing(_id).fetch().length > 0) {
      return "unfollow";
    } else {
      return "follow";
    }
  } else if (searchingFor === "modelLink" && loggedIn !== null) {
    if (checkForFavourites(_id).fetch().length > 0) {
      return "defavourite";
    } else {
      return "favourite";
    }
  }
};

Template.search.getResults = function() {
  var i, result, result2, searchQuery, searchingFor, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _len7, _m, _n, _o, _p;
  searchingFor = Session.get("searchQuery").charAt(0);
  if (searchingFor === "@") {
    searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i";
    result = searchForProfiles(searchQuery);
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      i = result[_i];
      i.searchingFor = "profileLink";
    }
    for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
      i = result[_j];
      i.order = order("profileLink", i._id);
    }
  } else if (searchingFor === "#") {
    searchQuery = "/" + Session.get("searchQuery").slice(1) + "/i";
    result = searchForModels(searchQuery);
    for (_k = 0, _len2 = result.length; _k < _len2; _k++) {
      i = result[_k];
      i.searchingFor = "modelLink";
    }
    for (_l = 0, _len3 = result.length; _l < _len3; _l++) {
      i = result[_l];
      i.order = order("modelLink", i._id);
    }
  } else {
    searchQuery = "/" + Session.get("searchQuery") + "/i";
    result = searchForProfiles(searchQuery).fetch();
    result2 = searchForModels(searchQuery);
    for (_m = 0, _len4 = result.length; _m < _len4; _m++) {
      i = result[_m];
      i.searchingFor = "profileLink";
    }
    for (_n = 0, _len5 = result.length; _n < _len5; _n++) {
      i = result[_n];
      i.order = order("profileLink", i._id);
    }
    for (_o = 0, _len6 = result2.length; _o < _len6; _o++) {
      i = result2[_o];
      i.searchingFor = "modelLink";
    }
    for (_p = 0, _len7 = result2.length; _p < _len7; _p++) {
      i = result2[_p];
      i.order = order("modelLink", i._id);
    }
    jQuery.merge(result, result2);
  }
  return result;
};

Template.search.events({
  'click div.profileLink': function(e) {
    return Workspace.profile(e.target.id);
  },
  'click div.modelLink': function(e) {
    return Workspace.model(e.target.id);
  },
  'click div.follow': function(e) {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $push: {
        following: e.target.id
      }
    });
  },
  'click div.favourite': function(e) {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $push: {
        favourites: e.target.id
      }
    });
  },
  'click div.defavourite': function(e) {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $pull: {
        favourites: e.target.id
      }
    });
  },
  'click div.unfollow': function(e) {
    return Profiles.update({
      _id: currentProfile()._id
    }, {
      $pull: {
        following: e.target.id
      }
    });
  }
});

})();
