transactionManager = Meteor.tx
camera = undefined
lastMousePosition = undefined
mouseDelta = undefined
contentNode = undefined

addObjectToModelContent = (options) ->
  if not options._id or not options.object
    throw new Meteor.Error(490, "Undefined Parameter")
  else
    console.log 'adding object to model content with id:', options._id
    newObject = options.object
    newObject._id = new Meteor.Collection.ObjectID()
    ModelContents.setProperty options._id, 'objects', newObject
    if not options.deferTransactionCommit
      transactionManager.commit()

undoModelContentAction = (options)->
  transactionManager.undo()

redoModelContentAction = (options) ->
  transactionManager.redo()

Template.model.events
  'click canvas': (e) ->
    console.log 'inserting cube into the scene'
    addObjectToModelContent
      _id: Session.get 'modelContentId'
      object:
        position: camera.position

Template.model.create = ->
  Meteor.startup ->
    setupKeybindings()

    Meteor.autorun ->
      model = Models.findOne _id: Session.get 'modelId'
      if model and model.contentId
        console.log 'model for modelId', Session.get('modelId'), ':', model
        Session.set 'modelContentId', model.contentId
        Meteor.subscribe 'modelContent', Session.get 'modelContentId'

  Meteor.defer ->
    contentNode = new THREE.Object3D()

    $(window).resize ->
      WIDTH = container.width()
      HEIGHT = container.height()
      ASPECT = WIDTH / HEIGHT

      renderer.setSize WIDTH, HEIGHT
      camera.aspect = ASPECT
      camera.updateProjectionMatrix();

    container = $ "#modelContainer"
    container.focus()

    # camera attributes
    VIEW_ANGLE = 45
    ASPECT = 1
    NEAR = 0.1
    FAR = 10000

    renderer = new THREE.WebGLRenderer()
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
    $(window).resize()

    controls = new THREE.FlyControls camera, document.getElementById 'modelContainer'
    controls.movementSpeed = 1000
    controls.rollSpeed = 1.0
    controls.dragToLook = true

    clock = new THREE.Clock()

    scene = new THREE.Scene()
    scene.add camera
    camera.position.z = 300

    scene.add contentNode

    cubeMaterial = new THREE.MeshLambertMaterial color: 0xCC0000

    x = -1

    while x < 2
      y = -1

      while y < 2
        ++y

        z = -1

        while z < 2
          ++z
          pointLight = new THREE.PointLight 0xFFFFFF
          pointLight.position.x = x * 400
          pointLight.position.y = z * 400
          pointLight.position.z = y * 400

          scene.add pointLight

      ++x

    container.append renderer.domElement

    render = ->
      if Session.get("template") == "model"
        renderer.render scene, camera
        controls.update clock.getDelta()
      requestAnimationFrame render

    render()

    Meteor.autorun ->
      console.log "running model autorun ..."
      content = ModelContents.findOne Session.get 'modelContentId'
      if content
        console.log 'content', content
        numOfObjects = contentNode.children.length
        o = 0
        while o < numOfObjects
          ++o
          contentNode.remove contentNode.children[0]

        content?.objects?.forEach (object) ->
          cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
          cubeMesh.position = object.position

          contentNode.add cubeMesh

# # Keybindings
# Find a reference at [meteor-keybindings](https://github.com/matteodem/meteor-keybindings)
setupKeybindings = ->
  # the context is the DOM element
  # on which the keybinding is called
  # (body by default)
  keybindingsContext = undefined
  # the event can be specified by a
  # string, such as 'keydown' (= default)
  keybindingsEvent = undefined
  
  # a list of undo shortcuts
  undoShortcuts = [
    'z'
    'cmd+z'
    'ctrl+z'
    'shift+z'
  ]

  # a list of redo shortcuts
  redoShortcuts = [
    'y'
    'ctrl+y'
    'shift+y'
  ]
  
  # for each undo shortcut being activated
  for undoShortcut in undoShortcuts
    Meteor.Keybindings.addOne undoShortcut,
      ->
        # undo the last commit
        undoModelContentAction()
      keybindingsContext
      keybindingsEvent

  # for each redo shortcut being activated
  for redoShortcut in redoShortcuts
    Meteor.Keybindings.addOne redoShortcut,
      ->
        # redo the last commit
        redoModelContentAction()
      keybindingsContext
      keybindingsEvent
