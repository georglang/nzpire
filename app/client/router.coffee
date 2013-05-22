Template.page_controller.display_page = ->
  #console.log "controller display page"
  #console.log "display_page"
  if Session.get('template') == undefined
    #console.log "undefined == true"
    Session.set "template", "index"
  #console.log "Template act:" + Session.get 'template'
  checkLoginProtection()
  Template[Session.get("template")]()

WorkspaceRouter = Backbone.Router.extend(
  routes:
    "/": "index"
    "index": "index"
    "model/:id": "model"
    "model/:id/edit": "modelEdit"
    "modelshowroom" : "modelshowroom"
    "help": "help" # #help
    "search": "search" # #search
    "search/:query": "search" # #search/kiwis
    "test/:abc/p:page": "test" # #search/kiwis/p7
    "profile/:_id" : "profile"
    "news" : "news"

  index: ->
    #console.log "indexRouter"
    Session.set "template", "index"  
    @navigate "index",
      trigger: true
      replace: true

  model: (_id)->
    #console.log "modelRouter"
    Session.set "modelId", _id
    Session.set "template", "loading"
    Session.set "voxelColor", DefaultModelColors[7].color
    Session.set "voxelSize", DefaultVoxelSizes[2].size
    Meteor.subscribe 'model', Session.get('modelId'), ()->
      Session.set "template", "model"
      Modeling.scene.setup()
      Meteor.defer Modeling.scene.update
      Modeling.interaction.mouseBindings.setup()
      Meteor.autorun ->
        Meteor.subscribe 'modelObjects', Session.get 'modelId'
        Meteor.subscribe 'modelActions', Session.get 'modelId'
          
    @navigate "model/" + _id,
      trigger: true
      replace: true

  modelEdit: (_id)->
    #console.log "modelEdit"
    Session.set "template", "modelEdit"
    Session.set "model", _id
    @navigate "model/" + _id + "/edit"
      trigger: true
      replace: true

  modelShowroom: ->
    Session.set "template", "modelShowroom"
    @navigate "modelshowroom",
      trigger: true
      replace: true

  help: ->
    #console.log "help"
    Session.set "template", "help"
    @navigate "help",
      trigger: true
      replace: true

  search: (query) ->
    #console.log "search " + query 
    Session.set "searchQuery", decodeURIComponent(query)    
    Session.set "template", "search"
    @navigate "search/" + query,
      trigger: true
      replace: true

  test: (abc, page) ->
    #console.log "test " + abc + " " + page
    Session.set "template", "test"
    @navigate "test/" + abc + "/" + page,
      trigger: true
      replace: true

  profile: (_id) ->
    Session.set "profileId", _id
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
    #console.log "news" 
    Session.set "template", "news"
    @navigate "news",
      trigger: true
      replace: true
)
@Workspace = new WorkspaceRouter()
Meteor.startup ->
  Backbone.history.start pushState: true