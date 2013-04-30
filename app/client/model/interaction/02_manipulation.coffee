# # Manipulation

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.manipulation = manipulation = {}

manipulation.object = object = {}

# ## Object

# ### Add
# Adds an object to the current model.

# options:

# * object {Object}
object.add = (options) ->
  if not options.object
    throw new Meteor.Error(490, "Object to be added is not defined.")
  else
    options.object.modelId = Session.get 'modelId'
    Meteor.call 'doModelAction',
      modelId: Session.get 'modelId'
      type: 'addObject'
      specifics:
        object: options.object

# ### Remove

# ### Translate

# ### Rotate

# ### Scale

# ## Group