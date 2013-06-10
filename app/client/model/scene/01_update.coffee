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

scene.materials ?= 
  default: new THREE.MeshLambertMaterial(color: 0xFFFFFF)
materials = scene.materials

# ## Creating a mesh for a given database object
meshForObject = (object) ->
  colorKey = object.color ? 'default'
  material = undefined
  materialInMap = materials[colorKey]
  if materialInMap
    material = materialInMap
  else
    colorAsInteger = parseInt colorKey, 16
    materials[colorKey] = material = new THREE.MeshLambertMaterial color: colorAsInteger
  mesh = new THREE.Mesh(new THREE.CubeGeometry(1, 1, 1), material)
  mesh.position = object.position
  if object.type == 'voxel'
    scale = object.size ? 50
    mesh.scale.set scale, scale, scale
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