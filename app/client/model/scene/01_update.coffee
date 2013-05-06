# # Update

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene
scene.currentObjects ?= []

cubeMaterial = new THREE.MeshLambertMaterial color: 0x7FAD00

scene.update = ->
  # ## Parallelization of update process
  parallelizationContext =
    latestDBObjects: ModelObjects.find({modelId: Session.get 'modelId'}).fetch()
    currentSceneObjects: Modeling.scene.currentObjects

  parallelSceneUpdater = new Parallel parallelizationContext

  # ### Identify changes
  parallelSceneUpdater.spawn (context) ->
    currentSceneObjects = context.currentSceneObjects
    objectsToBeAdded = []
    objectsToBeUpdated = []
    for objectDB in context.latestDBObjects
      objectCurrentlyInScene = context.currentSceneObjects[objectDB._id]
      if not objectCurrentlyInScene
        objectsToBeAdded.push objectDB
        currentSceneObjects[objectDB._id] = objectDB
      # #### TODO
      # Register all objects that were updated according to field 'updatedAt'
    updateData =
      currentSceneObjects: currentSceneObjects
      objectsToBeAdded: objectsToBeAdded
      objectsToBeUpdated: objectsToBeUpdated

  # ### Incorporate changes into the scene
  parallelSceneUpdater.then (updateData) ->
    Modeling.scene.currentObjects = updateData.currentSceneObjects
    for newObject in updateData.objectsToBeAdded
      cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
      cubeMesh.position = newObject.position
      Modeling.scene.content.add cubeMesh
    # #### TODO
    # Incorporate all object updates