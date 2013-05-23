# # Key bindings

# Find a reference at [meteor-keybindings](https://github.com/matteodem/meteor-keybindings)

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.keyBindings = keyBindings = {}

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
  # undo the last step
  for undoShortcut in undoShortcuts
    Meteor.Keybindings.addOne undoShortcut,
      ->
        Modeling.interaction.history.undo()
      keybindingsContext
      keybindingsEvent

  # for each redo shortcut being activated
  # redo the last step
  for redoShortcut in redoShortcuts
    Meteor.Keybindings.addOne redoShortcut,
      ->
        Modeling.interaction.history.redo()
      keybindingsContext
      keybindingsEvent

  # a list of color shortcuts
  colorShortcuts = [
    { key: '1', id: '#0' }
    { key: '2', id: '#1' }
    { key: '3', id: '#2' }
    { key: '4', id: '#3' }
    { key: '5', id: '#4' }
    { key: '6', id: '#5' }
    { key: '7', id: '#6' }
    { key: '8', id: '#7' }
    { key: '9', id: '#8' }
    { key: '0', id: '#9' }
  ]

  # for each color shortcut begin activated
  # choose a color
  installColorShortcut = (key, id) ->
    Meteor.Keybindings.addOne key,
      ->
        $(id).click()
      keybindingsContext
      keybindingsEvent

  for colorShortcut in colorShortcuts
    installColorShortcut colorShortcut.key, colorShortcut.id