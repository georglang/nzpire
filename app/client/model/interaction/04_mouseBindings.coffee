# # Mouse bindings

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.mouseBindings = mouseBindings = {}

# ## Setup

position =
  absolute: new THREE.Vector2
  relative: new THREE.Vector2

mouseBindings.getPosition =
  absolute: -> position.absolute
  relative: -> position.relative

# Installs the mouse bindings on the 3D canvas
mouseBindings.setup = ->
  # Here, the event map is created
  Template.model.events
    # By clicking
    'click canvas': (e) ->
      pick = Modeling.scene.picking.pick()

      if pick
        blockSize = 50
        buildingPoint = pick.point.add pick.face.normal.clone().setLength(blockSize / 2)
        # ### Snap to grid
        dimensions = ['x', 'y', 'z']
        # For all 3 dimensions x, y and z
        for d in dimensions
          isNegative = buildingPoint[d] < 0
          # normalize to positive values
          if isNegative
            buildingPoint[d] *= -1
          # get the modulo rest, applying block size
          rest = buildingPoint[d] % blockSize
          # round up or down
          roundUp = rest >= blockSize / 2
          summand = if roundUp then blockSize - rest else -rest
          buildingPoint[d] = buildingPoint[d] + summand
          # add offset
          offsetDirection = if roundUp then -1 else 1
          buildingPoint[d] += offsetDirection * blockSize / 2
          # denormalize from positive values
          if isNegative
            buildingPoint[d] *= -1

        # add a new object
        Modeling.interaction.manipulation.object.add
          object:
            position: buildingPoint
      # prevents default action for event
      e.preventDefault()
      # prevents event from bubbling up to parent elements
      e.stopPropagation()

  # When mouse is moved, save the
  Meteor.defer ->
    $('#modelContainer').mousemove (e) ->      
      offset = $(this).offset()
      width = $(this).width()
      height = $(this).height()

      # absolute and
      position.absolute.x = e.pageX - offset.left
      position.absolute.y = e.pageY - offset.top
      
      # relative positions
      position.relative.x =   (position.absolute.x / width  * 2) - 1
      position.relative.y = - (position.absolute.y / height * 2) + 1