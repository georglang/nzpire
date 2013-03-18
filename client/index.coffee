Template.modelingspace.events
  'click canvas': ->
    #sphereMaterial.color = new THREE.Color().setRGB Math.random(), Math.random(), Math.random()
    min = -100
    max = 100

    Cubes.insert
      position:
        x: min + Math.random() * (max - min)
        y: min + Math.random() * (max - min)
        z: 0

Template.modelingspace.create = ->
  #After Rendering or Rerendering
  Meteor.defer ->    
    #console.log "create"
    changedTemplate = false
    # get the DOM element to attach to
    # - assume we've got jQuery to hand
    $container = $("#modelingspace")
    #console.log $container

    #console.log renderer.domElement
    # attach the render-supplied DOM element
    #console.log getRenderer()
    #console.log getRenderer().domElement
    $container.append(getRenderer().domElement)
    #$container.append("<img></img>")
    render()

# set the scene size
WIDTH = 400
HEIGHT = 300

# set some camera attributes
VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

# create a WebGL renderer, camera
# and a scene
renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
scene = new THREE.Scene()

# add the camera to the scene
scene.add camera

getScene = ->
  return scene

getRenderer = ->
  return renderer
# the camera starts at 0,0,0
# so pull it back
camera.position.z = 300

# start the renderer
renderer.setSize WIDTH, HEIGHT

# create the sphere's material
cubeMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)

# create a point light
pointLight = new THREE.PointLight(0xFFFFFF)

# set its position
pointLight.position.x = 10
pointLight.position.y = 50
pointLight.position.z = 130

# add to the scene
scene.add pointLight

render = ->
  # draw!
  renderer.render scene, camera

  if Session.get("template") == "modelingspace"
    requestAnimationFrame render

Meteor.startup ->
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

    #console.log scene


  # get the DOM element to attach to
  # - assume we've got jQuery to hand
  $container = $("#modelingspace")
  #console.log $container

  #console.log renderer.domElement
  # attach the render-supplied DOM element
  $container.append(renderer.domElement)

  