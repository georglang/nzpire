###
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
###

# # Lights

@Modeling ?= {}
Modeling.scene ?= {}
Modeling.scene.lights = lights = {}

lights.setup = ->
  lightDistance = 2000
  numberOfLightsPerDimension = 3
  
  minXZ = - Math.round(numberOfLightsPerDimension / 2)
  maxXZ = Math.round(numberOfLightsPerDimension / 2)

  minY = 0
  maxY = numberOfLightsPerDimension
  
  x = minXZ
  while x <= maxXZ
    y = minY
    while y <= maxY
      z = minXZ
      while z <= maxXZ
        pointLight = new THREE.PointLight 0xffffff, 0.75, lightDistance * 2
        pointLight.position.x = z * lightDistance
        pointLight.position.y = y * lightDistance
        pointLight.position.z = x * lightDistance

        Modeling.scene.itself.add pointLight
        ++z
      ++y
    ++x