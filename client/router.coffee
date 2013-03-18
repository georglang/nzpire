Session.set "template", "index"

Template.page_controller.display_page = ->
  Template[Session.get("template")]()

WorkspaceRouter = Backbone.Router.extend(
  routes:
    "index": "index"
    "modelingspace/:id": "modelingspace"
    "help": "help" # #help
    "search": "search" # #search
    "search/:query": "search" # #search/kiwis
    "test/:abc/p:page": "test" # #search/kiwis/p7
    "profile/:_id" : "profile"

  index: ->
    console.log "index"
    Session.set "template", "index"  
    @navigate "index",
      trigger: true
      replace: true

  modelingspace: (_id = "new")->
    console.log "modelingspace"
    Session.set "template", "modelingspace"
    @navigate "modelingspace/" + _id,
      trigger: true
      replace: true

  help: ->
    console.log "help"
    Session.set "template", "help"
    @navigate "help",
      trigger: true
      replace: true


  search: (query) ->
    console.log "search " + query
    Session.set "template", "search"
    Session.set "searchQuery", query
    @navigate "search/" + query,
      trigger: true
      replace: true


  test: (abc, page) ->
    console.log "test " + abc + " " + page
    Session.set "template", "test"
    @navigate "test/" + abc + "/" + page,
      trigger: true
      replace: true

  profile: (_id) ->
    console.log "profile" + _id
    Session.set "template", "profile"
    @navigate "profile/" + _id,
      trigger: true
      replace: true    

)
Workspace = new WorkspaceRouter()
Meteor.startup ->
  Backbone.history.start pushState: true