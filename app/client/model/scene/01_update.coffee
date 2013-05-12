# # Update

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene

cubeMaterial = new THREE.MeshLambertMaterial color: 0x7FAD00

# ## Creating a mesh for a given database object
meshForObject = (object) ->
  mesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
  mesh.position = object.position
  mesh.name = object._id
  return mesh

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