@Modeling ?= {}
@Modeling.interaction ?= {}
@Modeling.interaction.keyBindings = keyBindings = {}

# # Keybindings
# Find a reference at [meteor-keybindings](https://github.com/matteodem/meteor-keybindings)

# ## Setup
keyBindings.setup = ->
    # the context is the DOM element
    # on which the keybinding is called
    # (body by default)
    keybindingsContext = undefined
    # the event can be specified by a
    # string, such as 'keydown' (= default)
    keybindingsEvent = undefined
    
    # a list of undo shortcuts
    undoShortcuts = [
      'cmd+z'
      'ctrl+z'
      'shift+z'
    ]

    # a list of redo shortcuts
    redoShortcuts = [
      'ctrl+y'
      'shift+y'
    ]
    
    # for each undo shortcut being activated
    for undoShortcut in undoShortcuts
      Meteor.Keybindings.addOne undoShortcut,
        ->
          # undo the last commit
          Modeling.interaction.history.undo()
        keybindingsContext
        keybindingsEvent

    # for each redo shortcut being activated
    for redoShortcut in redoShortcuts
      Meteor.Keybindings.addOne redoShortcut,
        ->
          # redo the last commit
          Modeling.interaction.history.redo()
        keybindingsContext
        keybindingsEvent