Session.set "template", "index"

Template.page_controller.display_page = ->
  Template[Session.get("template")]()

WorkspaceRouter = Backbone.Router.extend(
  routes:
    "index": "index"
    "modeling/:id": "modeling"
    "help": "help" # #help
    "search": "search" # #search
    "search/:query": "search" # #search/kiwis
    "test/:abc/p:page": "test" # #search/kiwis/p7
    "profile/:_id" : "profile"
    "news" : "news"

  index: ->
    console.log "index"
    Session.set "template", "index"  
    @navigate "index",
      trigger: true
      replace: true

  modeling: (_id = "new")->
    console.log "modeling"
    Session.set "template", "modeling"
    @navigate "modeling/" + _id,
      trigger: true
      replace: true

  help: ->
    console.log "help"
    Session.set "template", "help"
    @navigate "help",
      trigger: true
      replace: true


  search: (query = " ") ->
    console.log "search " + query
    Session.set "template", "search"
    @navigate "search/" + query,
      trigger: true
      replace: true
    if query.charAt(0) == "%"
      query = decodeURIComponent(query)
    if query != " "    
      Session.set "searchQuery", query


  test: (abc, page) ->
    console.log "test " + abc + " " + page
    Session.set "template", "test"
    @navigate "test/" + abc + "/" + page,
      trigger: true
      replace: true

  profile: (_id) ->
    console.log "profile id:" + _id
    Session.set "template", "profile"
    @navigate "profile/" + _id,
      trigger: true
      replace: true

  edit: ->
    Session.set "template", "edit"
    @navigate "edit/",
      trigger: true
      replace: true      

  news: ->
    console.log "news"
    Session.set "template", "news"
    @navigate "news",
      trigger: true
      replace: true
)
Workspace = new WorkspaceRouter()
Meteor.startup ->
  Backbone.history.start pushState: true