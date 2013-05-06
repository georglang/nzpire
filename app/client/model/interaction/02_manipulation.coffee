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
    newObject = options.object
    newObject.modelId = Session.get 'modelId'
    ModelObjects.insert newObject
    Modeling.interaction.history.save()

# ### Remove

# ### Translate

# ### Rotate

# ### Scale

# ## Group