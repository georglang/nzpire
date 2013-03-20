Template.modeling.events
  'click canvas': ->
    #sphereMaterial.color = new THREE.Color().setRGB Math.random(), Math.random(), Math.random()
    min = -100
    max = 100

    Cubes.insert
      position:
        x: min + Math.random() * (max - min)
        y: min + Math.random() * (max - min)
        z: 0

  'keydown body': (e) ->
    console.log e.keyCode

Template.modeling.create = ->
  Meteor.defer ->
    $(window).resize ->
      console.log 'resize'
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

    scene = new THREE.Scene()
    scene.add camera
    camera.position.z = 300

    cubeMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)

    pointLight = new THREE.PointLight(0xFFFFFF)
    pointLight.position.x = 10
    pointLight.position.y = 50
    pointLight.position.z = 130

    scene.add pointLight

    container.append renderer.domElement

    render = ->
      if Session.get("template") == "modeling"
        renderer.render scene, camera
        console.log 'rendering'
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