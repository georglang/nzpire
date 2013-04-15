(function(){ 
Template.menue.events({
  'click #news': function() {
    console.log("clicked news");
    Workspace.news();
    return false;
  },
  'click #home': function() {
    console.log("clicked home");
    Workspace.index();
    return false;
  },
  'click #search': function() {
    console.log("clicked search");
    Workspace.search(encodeURIComponent(document.getElementById("searchQuery").value));
    return false;
  },
  'click #model': function() {
    console.log("clicked model");
    if ($('#newModel')[0] === void 0) {
      $('#model').after("<li id='newModel'><input id='modelName' type='text' placeholder='Modelname'><a href='#' id='createNewModel'>Create</a></li>");
    }
    return false;
  },
  'click #createNewModel': function() {
    var modelName, options;
    modelName = $('#modelName').val();
    if ($('#errorNewModel')[0] !== void 0) {
      $('#errorNewModel').remove();
    }
    options = {
      name: modelName,
      predecessor: "",
      creator: currentProfile()._id,
      isPublic: false
    };
    return Meteor.call('createModel', options, function(error, result) {
      if (error) {
        return $('#createNewModel').after("<div id='errorNewModel'>" + error.reason + "</div>");
      } else {
        $('#newModel')[0].remove();
        return Workspace.model(result);
      }
    });
  },
  'click #profile': function() {
    console.log("clicked profile");
    Workspace.profile(currentProfile()._id);
    return false;
  },
  'click #edit': function() {
    console.log("clicked edit");
    return Workspace.edit();
  },
  'keydown #searchQuery': function(e) {
    return Meteor.defer(function() {
      var searchQuery;
      searchQuery = document.getElementById("searchQuery").value;
      if (searchQuery.length > 2 || e.keyCode === 13) {
        return Workspace.search(encodeURIComponent(searchQuery));
      } else if (searchQuery.length <= 2) {
        $('#searchresult').empty();
        return Workspace.search("");
      }
    });
  },
  'click #login-buttons-logout': function() {
    console.log("logout");
    return Workspace.index();
  }
});

})();
