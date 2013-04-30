# # History

# The interaction history allows the user to

# * undo
# * redo

# The history belongs to a model and not to a user.

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.history = history = {}

# ## Start

# allows the following actions to be performed:

# * undo
history.undo = (options) ->
  Meteor.call 'undoModelAction', modelId: Session.get 'modelId'

# * redo
history.redo = (options) ->
  Meteor.call 'redoModelAction', modelId: Session.get 'modelId'