# # Key bindings

# Find a reference at [meteor-keybindings](https://github.com/matteodem/meteor-keybindings)

@Modeling ?= {}
Modeling.interaction ?= {}
Modeling.interaction.keyBindings = keyBindings = {}

# ## Setup
keyBindings.setup = ->
  inputShouldNotBeIgnored = (event) ->
    tagName = $(event.target).prop('tagName')
    tagNamesToIgnore = [
      'INPUT'
      'TEXTAREA'
    ]
    doNotIgnoreInput = tagNamesToIgnore.indexOf(tagName) is -1

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
    'z'
  ]

  # a list of redo shortcuts
  redoShortcuts = [
    'ctrl+y'
    'shift+y'
    'y'
    'ctrl+r'
    'shift+r'
    'r'
  ]
  
  $(document).ready ->
    # for each undo shortcut being activated
    # undo the last step
    for undoShortcut in undoShortcuts
      Meteor.Keybindings.addOne undoShortcut,
        (event) ->
          if inputShouldNotBeIgnored event
            Modeling.interaction.history.undo()
        keybindingsContext
        keybindingsEvent

    # for each redo shortcut being activated
    # redo the last step
    for redoShortcut in redoShortcuts
      Meteor.Keybindings.addOne redoShortcut,
        (event) ->
          if inputShouldNotBeIgnored event
            Modeling.interaction.history.redo()
        keybindingsContext
        keybindingsEvent

    # for each color shortcut begin activated
    # choose a color
    installColorShortcut = (key, id) ->
      Meteor.Keybindings.addOne key,
        (event) ->
          if inputShouldNotBeIgnored event
            $(id).click()
        keybindingsContext
        keybindingsEvent

    for modelingColor in DefaultModelColors
      installColorShortcut modelingColor.shortcut, "#modelingColor_" + modelingColor.index

    voxelSizeIncreaseShortcut = 'l'

    Meteor.Keybindings.addOne voxelSizeIncreaseShortcut,
      (event) ->
        if inputShouldNotBeIgnored event
          activeSizeBox = $('.activeSize')
          siblings = activeSizeBox.siblings()
          nextActiveSizeBox = null
          if activeSizeBox.index() == siblings.length
            nextActiveSizeBox = siblings[0]
          else
            nextActiveSizeBox = activeSizeBox.next()
          nextActiveSizeBox.click()
      keybindingsContext,
      keybindingsEvent

    voxelSizeDecreaseShortcut = 'k'

    Meteor.Keybindings.addOne voxelSizeDecreaseShortcut,
      (event) ->
        if inputShouldNotBeIgnored event
          activeSizeBox = $('.activeSize')
          siblings = activeSizeBox.siblings()
          prevActiveSizeBox = null
          if activeSizeBox.index() == 0
            prevActiveSizeBox = siblings[siblings.length - 1]
          else
            prevActiveSizeBox = activeSizeBox.prev()
          prevActiveSizeBox.click()
      keybindingsContext,
      keybindingsEvent