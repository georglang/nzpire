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
    id = options._id ? Session.get 'modelContentId'
    newObject = options.object
    newObject._id = new Meteor.Collection.ObjectID()
    ModelContents.setProperty id, 'objects', newObject
    Modeling.interaction.history.save()

# ### Remove

# ### Translate

# ### Rotate

# ### Scale

# ## Group