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

# # Picking

@Modeling ?= {}
Modeling.scene ?= {}
Modeling.scene.picking = picking = {}

projector = new THREE.Projector()
raycaster = new THREE.Raycaster()

# ## Pick
picking.pick = pick = ->
  camera = Modeling.scene.camera
  relativeMousePosition = Modeling.interaction.mouseBindings.getPosition.relative()
  vector = new THREE.Vector3 relativeMousePosition.x, relativeMousePosition.y, 1
  projector.unprojectVector vector, camera
  raycaster.set camera.position, vector.sub(camera.position).normalize()
  intersects = raycaster.intersectObject Modeling.scene.pickable, true
  intersects[0]

# ## Pick object
picking.pickObject = pickObject = ->
  pick()?.object

# ## Get picked position
picking.pickPoint = pickPoint = ->
  pick()?.point