# # Main file

Template.model.create = ->
  Meteor.startup ->
    Modeling.interaction.history.start()
    Modeling.interaction.keyBindings.setup()
    Modeling.interaction.mouseBindings.setup()
    Modeling.scene.setup()