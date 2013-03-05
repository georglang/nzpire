Session.set "template", "index"

Template.page_controller.display_page = ->
  console.log "Loading page template"
  Template[Session.get("template")]()

WorkspaceRouter = Backbone.Router.extend(
  routes:
    "index": "index"
    "modelingspace": "modelingspace"
    "help": "help" # #help
    "search": "search" # #search
    "search/:query": "search" # #search/kiwis
    "test/:abc/p:page": "test" # #search/kiwis/p7

  index: ->
    console.log "index"
    Session.set "template", "index"  
    @navigate "index",
      trigger: true
      replace: true

  modelingspace: ->
    console.log "modelingspace"
    Session.set "template", "modelingspace"
    @navigate "modelingspace"
      trigger: true
      replace: true

  help: ->
    console.log "help"
    Session.set "template", "help"
    @navigate "help",
      trigger: true
      replace: true


  search: ->
    console.log "search"
    Session.set "template", "search"
    @navigate "search"
      trigger: true
      replace: true


  test: (abc, page) ->
    console.log "test " + abc + " " + page
    Session.set "template", "test"
    @navigate "test/" + abc + "/" + page,
      trigger: true
      replace: true

)
Workspace = new WorkspaceRouter()
Meteor.startup ->
  Backbone.history.start pushState: true