(function(){ var WorkspaceRouter;

Session.set("template", "index");

Template.page_controller.display_page = function() {
  checkLoginProtection();
  return Template[Session.get("template")]();
};

WorkspaceRouter = Backbone.Router.extend({
  routes: {
    "index": "index",
    "model/:id": "model",
    "model/:id/edit": "modelEdit",
    "help": "help",
    "search": "search",
    "search/:query": "search",
    "test/:abc/p:page": "test",
    "profile/:_id": "profile",
    "news": "news"
  },
  index: function() {
    Session.set("template", "index");
    return this.navigate("index", {
      trigger: true,
      replace: true
    });
  },
  model: function(_id) {
    Session.set("template", "model");
    Session.set("model", _id);
    return this.navigate("model/" + _id, {
      trigger: true,
      replace: true
    });
  },
  modelEdit: function(_id) {
    Session.set("template", "modelEdit");
    Session.set("model", _id);
    return this.navigate("model/" + _id + "/edit")({
      trigger: true,
      replace: true
    });
  },
  help: function() {
    Session.set("template", "help");
    return this.navigate("help", {
      trigger: true,
      replace: true
    });
  },
  search: function(query) {
    Session.set("searchQuery", decodeURIComponent(query));
    Session.set("template", "search");
    return this.navigate("search/" + query, {
      trigger: true,
      replace: true
    });
  },
  test: function(abc, page) {
    Session.set("template", "test");
    return this.navigate("test/" + abc + "/" + page, {
      trigger: true,
      replace: true
    });
  },
  profile: function(_id) {
    Session.set("template", "profile");
    return this.navigate("profile/" + _id, {
      trigger: true,
      replace: true
    });
  },
  edit: function() {
    Session.set("template", "edit");
    return this.navigate("edit/", {
      trigger: true,
      replace: true
    });
  },
  news: function() {
    Session.set("template", "news");
    return this.navigate("news", {
      trigger: true,
      replace: true
    });
  }
});

this.Workspace = new WorkspaceRouter();

Meteor.startup(function() {
  return Backbone.history.start({
    pushState: true
  });
});

})();
