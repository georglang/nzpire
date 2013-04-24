# # Setup

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene

scene.setup = ->
  subscribeToModelContent = ->
    model = Models.findOne _id: Session.get 'modelId'
    if model and model.contentId
      Session.set 'modelContentId', model.contentId
      Meteor.subscribe 'modelContent', Session.get 'modelContentId'

  # Always get the correct model content
  Meteor.autorun subscribeToModelContent

  # Ensure that the DOM is ready for take-off! 
  Meteor.defer ->
    # ## Rendering
    viewAngle = 45
    aspect = 1
    near = 0.1
    far = 10000

    renderer = new THREE.WebGLRenderer()
    camera = scene.camera = new THREE.PerspectiveCamera viewAngle, aspect, near, far
    camera.position.z = 1000
    camera.position.y = 1000

    render = ->
      # Only render when template is active.
      if Session.get("template") == "model"
        renderer.render scene.itself, camera
        controls.update clock.getDelta()
      requestAnimationFrame render

    # ## Controls
    controls = new THREE.FlyControls camera, document.getElementById 'modelContainer'
    controls.movementSpeed = 1000
    controls.rollSpeed = 1.0
    controls.dragToLook = true

    # ## Clock
    clock = new THREE.Clock()

    # ## Scene itself
    scene.itself = new THREE.Scene()
    scene.itself.add camera
    camera.lookAt new THREE.Vector3 0, 0, -2000
    scene.content = new THREE.Object3D()
    scene.itself.add scene.content

    # ## Lights
    Modeling.scene.lights.setup()

    # ## Building plane
    plane = new THREE.Mesh(new THREE.PlaneGeometry(10000, 10000, 50, 50), new THREE.MeshLambertMaterial({color: 0x333333}))
    plane.rotation.x = - Math.PI / 2
    scene.itself.add plane

    # ## Insertion into DOM
    container = $ "#modelContainer"
    container.focus()
    container.append renderer.domElement

    # ## Window resizing
    $(window).resize ->
      width = container.width()
      height = container.height()
      aspect = width / height

      renderer.setSize width, height
      camera.aspect = aspect
      camera.updateProjectionMatrix();

    $(window).resize()

    # Kick off rendering loop!
    render()

    # Always keep the scene aligned with the current model content
    Meteor.autorun Modeling.scene.update