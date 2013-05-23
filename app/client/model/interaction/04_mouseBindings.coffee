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

# Installs the mouse bindings on the 3D canvas
mouseBindings.setup = ->
  # Here, the event map is created
  Template.model.events
    'mousedown canvas': (e) ->
      position.mouseDown = mouseBindings.getPosition.relative().clone();
    # By clicking
    'click canvas': (e) ->
      if mouseBindings.getPosition.relative().equals mouseBindings.getPosition.mouseDown()
        pick = Modeling.scene.picking.pick()

        if pick
          blockSize = 50
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

          # add a new object
          Modeling.interaction.manipulation.object.add
            object:
              type: 'voxel'
              position: buildingPoint
              color: Session.get 'modelingColor'
              size: Session.get 'voxelSize'
        # stop event from being called more than once for a click!
        e.stopImmediatePropagation()

  # When mouse is moved, save the
  mouseMove = (e) ->
    offset = $(this).offset()
    width = $(this).width()
    height = $(this).height()

    # absolute and
    position.absolute.x = e.pageX - offset.left
    position.absolute.y = e.pageY - offset.top
    
    # relative positions
    position.relative.x =   (position.absolute.x / width  * 2) - 1
    position.relative.y = - (position.absolute.y / height * 2) + 1
  
  Meteor.defer ->
    $('#modelContainer').off 'mousemove', mouseMove
    $('#modelContainer').on 'mousemove', mouseMove 