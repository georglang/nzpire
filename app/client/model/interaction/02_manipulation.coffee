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
  Meteor.call 'doModelAction',
    modelId: Session.get 'modelId'
    type: 'addObject'
    specifics:
      object: options.object

# ### Remove

object.remove = (options) ->
  Meteor.call 'doModelAction',
    modelId: Session.get 'modelId'
    type: 'removeObject'
    specifics:
      objectId: options.objectId    

# ### Translate

# ### Rotate

# ### Scale

# ## Group