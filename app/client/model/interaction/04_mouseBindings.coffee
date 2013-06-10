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

# # Mouse bindings

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.mouseBindings = mouseBindings = {}

# ## Setup

position =
  absolute: new THREE.Vector2
  relative: new THREE.Vector2
  mouseDown: new THREE.Vector2

mouseBindings.getPosition =
  absolute: -> position.absolute
  relative: -> position.relative
  mouseDown: -> position.mouseDown

getBuildingPointFromPick = (pick) ->
  blockSize = Session.get 'voxelSize'
  # ### Snap to grid
  # Put the normal of the face clicked on into world space
  matrixNormal = new THREE.Matrix3().getNormalMatrix pick.object.matrixWorld
  normalWorld = pick.face.normal.clone().applyMatrix3(matrixNormal).normalize()
  buildingPoint = pick.point.add normalWorld.setLength(blockSize / 2)
  # For all 3 dimensions x, y and z:
  
  # * normalize to positive values
  # * get the modulo rest, applying block size
  # * round up or down
  # * add offset
  # * denormalize from positive values
  dimensions = ['x', 'y', 'z']
  for d in dimensions
    isNegative = buildingPoint[d] < 0
    if isNegative
      buildingPoint[d] *= -1
    rest = buildingPoint[d] % blockSize
    roundUp = rest >= blockSize / 2
    summand = if roundUp then blockSize - rest else -rest
    buildingPoint[d] = buildingPoint[d] + summand
    offsetDirection = if roundUp then -1 else 1
    buildingPoint[d] += offsetDirection * blockSize / 2
    if isNegative
      buildingPoint[d] *= -1
  return buildingPoint

updateObjectPreview = ->
  pick = Modeling.scene.picking.pick()
  if pick
    objectPreview = Modeling.scene.objectPreview
    objectPreview?.position = getBuildingPointFromPick pick

# ### By clicking
# * on the left mouse button, add an object
# * on the right mouse button, remove the object that was clicked
# ### By moving,
# save the absolute and relative (to the canvas)
# positions of the mouse cursor
Template.model.events
  'mousedown canvas': (e) ->
    position.mouseDown = mouseBindings.getPosition.relative().clone();
  'mouseup canvas': (e) ->
    if mouseBindings.getPosition.relative().equals mouseBindings.getPosition.mouseDown()
      pick = Modeling.scene.picking.pick()

      if pick
        if e.which is 1
          Modeling.interaction.manipulation.object.add
            object:
              type: 'voxel'
              position: getBuildingPointFromPick pick
              color: Session.get 'modelingColor'
              size: Session.get 'voxelSize'
        else if e.which is 3
          if pick.object.name
            Modeling.interaction.manipulation.object.remove
              objectId: pick.object.name
              
mouseBindings.setup = ->
  mouseMoveContainer = (e) ->
    $(this).focus()

  mouseMoveCanvas = (e) ->
    offset = $(this).offset()
    width = $(this).width()
    height = $(this).height()

    position.absolute.x = e.pageX - offset.left
    position.absolute.y = e.pageY - offset.top
    
    position.relative.x =   (position.absolute.x / width  * 2) - 1
    position.relative.y = - (position.absolute.y / height * 2) + 1
    
    updateObjectPreview()
  
  Meteor.defer ->
    $('#modelContainer').off 'mousemove', mouseMoveContainer
    $('#modelContainer').on 'mousemove', mouseMoveContainer
    $('#modelContainer > canvas').off 'mousemove', mouseMoveCanvas
    $('#modelContainer > canvas').on 'mousemove', mouseMoveCanvas