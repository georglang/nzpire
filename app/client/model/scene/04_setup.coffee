# # Setup

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene

if Detector.webgl
    Modeling.renderer ?= new THREE.WebGLRenderer()
else
    Modeling.renderer ?= new THREE.CanvasRenderer()
renderer = Modeling.renderer

scene.setup = ->
  scene.currentObjects = []

  # Ensure that the DOM is ready for take-off! 
  Meteor.defer ->
    # ## DOM element
    container = $ "#modelContainer"
    container.focus()

    # ## Rendering
    viewAngle = 45
    aspect = 1
    near = 0.1
    far = 10000

    camera = scene.camera = new THREE.PerspectiveCamera viewAngle, aspect, near, far
    camera.position.z = 1000
    camera.position.y = 1000

    controls = new THREE.FocusControls camera, container[0]

    controls.rotateSpeed = 1.0
    controls.zoomSpeed = 1.2
    controls.panSpeed = 0.8

    controls.noZoom = false
    controls.noPan = false

    controls.staticMoving = true
    controls.dynamicDampingFactor = 0.3

    render = ->
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
    camera.add cameraLight

    # ## Building plane
    plane = new THREE.Mesh(new THREE.PlaneGeometry(10000, 10000, 50, 50), new THREE.MeshLambertMaterial({color: 0x333333}))
    plane.rotation.x = - Math.PI / 2
    scene.pickable.add plane

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

    # Kick off rendering loop!
    render()