###
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
###

Template.page_controller.display_page = ->
  if Session.get('template')
    checkLoginProtection()
    Template[Session.get("template")]()


WorkspaceRouter = Backbone.Router.extend(
  routes:
    "": "index"
    "/": "index"
    "index": "index"
    "model/:id": "model"
    "modelShowroom" : "modelShowroom"
    "search": "search" # #search
    "search/:query": "search" # #search/kiwis
    "unit_tests": "unit_tests"
    "profile/:_id" : "profile"
    "news" : "news"
    "impressum" : "impressum"

  index: ->
    #console.log "indexRouter"
    Session.set "template", "index"  
    @navigate "index",
      trigger: true
      replace: true

  model: (_id)->
    Session.set "modelId", _id
    Session.set "template", "loading"
    Session.set "modelingColor", DefaultModelColors[7].color
    Session.set "voxelSize", DefaultVoxelSizes[2].size
    Meteor.subscribe 'model', Session.get('modelId'), ->
      Session.set "template", "model"
          
    @navigate "model/" + _id,
      trigger: true
      replace: true

  modelShowroom: ->
    Session.set "template", "modelShowroom"
    @navigate "modelShowroom",
      trigger: true
      replace: true

  search: (query) ->
    #console.log "search " + query 
    Session.set "searchQuery", decodeURIComponent(query)    
    Session.set "search", query
    #Session.set("template", "search")
    @navigate "search/" + query,
      trigger: true
      replace: true

  unit_tests: ->
    Session.set "template", "unit_tests"
    @navigate "unit_tests",
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

  impressum: ->
    #console.log "impressum"
    Session.set "template", "impressum"
    @navigate "impressum",
    trigger: true
    replace: true
)
@Workspace = new WorkspaceRouter()
Meteor.startup ->
  Backbone.history.start pushState: true