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

# # Update

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene

Meteor.startup ->
  scene.materials = materials
  console.log 'scene.materials', scene.materials

# ## Adding the mesh to the scene
addObject = (object) ->
  Modeling.scene.content.add meshForObject object

# ## Removing an existing mesh from the scene
removeObject = (object) ->
  objectMesh = Modeling.scene.content.getChildByName object._id
  Modeling.scene.content.remove objectMesh

# ## Updating a mesh (= remove old one + add new one)
updateObject = (object) ->
  removeObject object
  addObject object

scene.update = ->
  # ## Registration of observer callbacks
  ModelObjects.find({modelId: Session.get 'modelId'}).observe
    added: addObject
    updated: updateObject
    removed: removeObject