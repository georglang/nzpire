@Modeling ?= {}
@Modeling.interaction ?= {}
@Modeling.interaction.history = history = {}

# # Modeling history

# The interaction history allows the user to
# * save
# * undo
# * redo
# during a session. The history belongs to a user.
# 
# **CAUTION***:
# After each, the user's interaction will be reset
# after every:
#
# * page reload
# * model change
#
# This problem will be tackled in the future!
#
# The transaction library in use is
# [meteor-versioning](https://github.com/jerico-dev/meteor-versioning).

transactionManager = Meteor.tx

history.start = (options) ->
  transactionManager._purgeUndoRedo()

  history.save = (options) ->
    transactionManager.commit()

  history.undo = (options) ->
    transactionManager.undo()

  history.redo = (options) ->
    transactionManager.redo()

history.save = history.undo = history.redo = ->
  console.error 'History has not been started yet! Use Modeling.interaction.history.start() to start the interaction history.'