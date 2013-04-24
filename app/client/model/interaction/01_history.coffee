# # History

# The interaction history allows the user to

# * save
# * undo
# * redo

# during a session. The history belongs to a user.
# 
# **CAUTION**:
# The user's interaction will be reset
# after every:

# * page reload
# * model change

# This problem will be tackled in the future!

# The transaction library in use is
# [meteor-versioning](https://github.com/jerico-dev/meteor-versioning).

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.history = history = {}

transactionManager = Meteor.tx

# ## Start
history.start = (options) ->
  # resets the history and
  transactionManager._purgeUndoRedo()

  # allows the following actions to be performed:

  # * save
  history.save = (options) ->
    transactionManager.commit()

  # * undo
  history.undo = (options) ->
    transactionManager.undo()

  # * redo
  history.redo = (options) ->
    transactionManager.redo()

# If any actions are performed before the history is
# initialized by

# `Modeling.interaction.history.start()`

# error messages will be thrown!
history.save = history.undo = history.redo = ->
  console.error 'History has not been started yet! Use Modeling.interaction.history.start() to start the interaction history.'