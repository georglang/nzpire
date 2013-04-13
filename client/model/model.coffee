camera = undefined
lastMousePosition = undefined
mouseDelta = undefined
cubesNode = undefined

Template.model.events
  'click canvas': (e) ->
    console.log 'inserting cube into the scene'
    Cubes.insert position: camera.position

  'mouseover #modelContainer': (e) ->
    #$("#modelContainer").focus()

  'mouseout #modelContainer': (e) ->
    #$("#modelContainer").blur()

  'mousemove #modelContainer': (e) ->
    #console.log e

  'keydown #modelContainer': (e) ->
    # if 'l' is pressed delete all Cubes
    if e.keyCode is 76
      console.log 'removing all cubes from the scene'
      Cubes.remove {}

Template.model.create = ->
  Meteor.defer ->
    cubesNode = new THREE.Object3D()

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

    scene.add cubesNode

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
      cubes = Cubes.find().fetch()

      numOfCubes = cubesNode.children.length
      c = 0
      while c < numOfCubes
        ++c
        cubesNode.remove cubesNode.children[0]

      cubes.forEach (cube) ->
        cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
        cubeMesh.position = cube.position

        cubesNode.add cubeMesh