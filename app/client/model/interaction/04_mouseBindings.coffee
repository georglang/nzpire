# # Mouse bindings

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.mouseBindings = mouseBindings = {}

# ## Setup

# Installs the mouse bindings on the 3D canvas
mouseBindings.setup = ->
  # Here, the event map is created
  Template.model.events
    # By clicking
    'click canvas': (e) ->
      # a cube is added at the current camera position
      Modeling.interaction.manipulation.object.add
        object:
          position: Modeling.scene.camera.position