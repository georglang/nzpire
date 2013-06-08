# # Setup

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene
controls = scene.controls = new THREE.FocusControls()

if Detector.webgl
    Modeling.renderer ?= new THREE.WebGLRenderer
        antialias: true
        # preserving the drawing buffer is important for
        # taking screenshots from the canvas
        preserveDrawingBuffer: true
        clearColor: 0x000000
else
    Modeling.renderer ?= new THREE.CanvasRenderer()
renderer = Modeling.renderer

renderer.continueRenderLoop = false;

scene.setup = ->
  scene.currentObjects = []

  # Ensure that the DOM is ready for take-off! 
  Meteor.defer ->
    # ## DOM element
    container = $ "#modelContainer"

    # ## Rendering
    viewAngle = 45
    aspect = 1
    near = 10
    far = 100000

    camera = scene.camera = new THREE.PerspectiveCamera viewAngle, aspect, near, far
    camera.position.z = 1000
    camera.position.y = 1000

    renderer.continueRenderLoop = true

    render = ->
      if renderer.continueRenderLoop
        # Only render when template is active.
        if Session.get("template") == "model"
          renderer.render scene.itself, camera
          controls.update()
        requestAnimationFrame render

    # ## Clock
    clock = new THREE.Clock()

    # ## Scene itself
    scene.itself = new THREE.Scene()
    scene.itself.add camera
    camera.lookAt new THREE.Vector3 0, 0, -2000

    # ## Pickable
    scene.pickable = new THREE.Object3D()
    scene.itself.add scene.pickable

    # ## Content
    scene.content = new THREE.Object3D()
    scene.pickable.add scene.content

    # ## Lights
    cameraLight = new THREE.PointLight 0xffffff, 1.0, 10000
    cameraLight.castShadow = true
    camera.add cameraLight

    # ## Building plane
    plane = new THREE.Mesh(new THREE.PlaneGeometry(10000, 10000, 50, 50), new THREE.MeshBasicMaterial({color: 0xffffff, transparent: true, opacity: 0.5}))
    plane.rotation.x = - Math.PI / 2
    scene.pickable.add plane

    # ## Skybox
    path = "/textures/skyboxes/sky01/"
    format = ".jpg"
    urls = [
        path + "px" + format,
        path + "nx" + format,
        path + "py" + format,
        path + "ny" + format,
        path + "pz" + format,
        path + "nz" + format
    ]
    textureCube = THREE.ImageUtils.loadTextureCube(urls, new THREE.CubeRefractionMapping())
    shader = THREE.ShaderLib["cube"]
    shader.uniforms["tCube"].value = textureCube
    material = new THREE.ShaderMaterial(
      fragmentShader: shader.fragmentShader
      vertexShader: shader.vertexShader
      uniforms: shader.uniforms
      depthWrite: false
      side: THREE.BackSide
    )
    skybox = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000), material)
    scene.itself.add skybox

    # ## Object preview
    scene.materials.objectPreview = objectPreviewMaterial = new THREE.MeshLambertMaterial
      color: 0xFFFFFF
      transparent: true
      opacity: 0.5
    scene.objectPreview = new THREE.Mesh(new THREE.CubeGeometry(1, 1, 1), scene.materials.objectPreview)
    scene.itself.add scene.objectPreview
    Meteor.autorun ->
      scale = Session.get 'voxelSize'
      scene.objectPreview.scale.set scale, scale, scale
    Meteor.autorun ->
      color = new THREE.Color parseInt Session.get('modelingColor'), 16
      objectPreviewMaterial.color = color
    # ## Insertion into DOM
    container.append renderer.domElement

    # ## Window resizing
    $(window).resize ->
      if container.length
        container.height($(window).height() - container.offset().top)
        width = container.width()
        height = container.height()
        aspect = width / height

        renderer.setSize width, height
        camera.aspect = aspect
        camera.updateProjectionMatrix();

    $(window).resize()

    # ## Camera controls
    canvas = container.find "canvas"
    controls.object = camera
    controls.updateDomElement canvas[0]
    controls.enabled = true

    # Kick off rendering loop!
    render()

scene.shutdown = ->
  renderer.continueRenderLoop = false
  controls.enabled = false