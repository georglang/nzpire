camera = undefined
lastMousePosition = undefined
mouseDelta = undefined

Template.modeling.events
  'click canvas': (e) ->
    Cubes.insert position: camera.position

  'mouseover #modelingContainer': (e) ->
    #$("#modelingContainer").focus()

  'mouseout #modelingContainer': (e) ->
    #$("#modelingContainer").blur()

  'mousemove #modelingContainer': (e) ->
    #console.log e

  'keydown #modelingContainer': (e) ->
    #console.log 'keycode', e.keyCode

Template.modeling.create = ->
  Meteor.defer ->
    $(window).resize ->
      WIDTH = container.width()
      HEIGHT = container.height()
      ASPECT = WIDTH / HEIGHT

      renderer.setSize WIDTH, HEIGHT
      camera.aspect = ASPECT
      camera.updateProjectionMatrix();

    container = $ "#modelingContainer"

    # camera attributes
    VIEW_ANGLE = 45
    ASPECT = 1
    NEAR = 0.1
    FAR = 10000

    renderer = new THREE.WebGLRenderer()
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
    $(window).resize()

    controls = new THREE.FlyControls camera, renderer.domElement
    controls.movementSpeed = 1000
    controls.rollSpeed = 1.0
    controls.dragToLook = true

    clock = new THREE.Clock()

    scene = new THREE.Scene()
    scene.add camera
    camera.position.z = 300

    cubeMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)

    x = -1

    while x < 2
      y = -1

      while y < 2
        ++y

        z = -1

        while z < 2
          ++z
          pointLight = new THREE.PointLight(0xFFFFFF)
          pointLight.position.x = x * 400
          pointLight.position.y = z * 400
          pointLight.position.z = y * 400

          scene.add pointLight

      ++x

    container.append renderer.domElement

    render = ->
      if Session.get("template") == "modeling"
        renderer.render scene, camera
        controls.update clock.getDelta()
      requestAnimationFrame render

    render()

    Meteor.autorun ->
      cubes = Cubes.find().fetch()
      #console.log cubes
      scene.children.forEach (child) ->
        scene.remove child
      scene.add pointLight

      cubes.forEach (cube) ->
        cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
        cubeMesh.position = cube.position

        scene.add cubeMesh