# # Lights

@Modeling ?= {}
Modeling.scene ?= {}
Modeling.scene.lights = lights = {}

lights.setup = ->
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

        Modeling.scene.itself.add pointLight

    ++x