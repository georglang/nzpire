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

# # Global_Functions

# ## Check Login Protection
# Redirects to Index if the User is not logged in
@checkLoginProtection = ->
	if Meteor.user() == null
		currentTemplateSession = Session.get 'template'
		currentTemplateInArray = $.inArray(currentTemplateSession,loginProtectionArray)

		if currentTemplateInArray >= 0
			Workspace.index()

# ## Login Protected Sites
@loginProtectionArray = [
	"news"
	"profile"
]

@materials ?= 
  default: new THREE.MeshLambertMaterial(color: 0xFFFFFF)

# ## Creating a mesh for a given database object
@meshForObject = (object) ->
  colorKey = object.color ? 'default'
  material = undefined
  materialInMap = materials[colorKey]
  if materialInMap
    material = materialInMap
  else
    colorAsInteger = parseInt colorKey, 16
    materials[colorKey] = material = new THREE.MeshLambertMaterial color: colorAsInteger
  mesh = new THREE.Mesh(new THREE.CubeGeometry(1, 1, 1), material)
  mesh.position = object.position
  if object.type == 'voxel'
    scale = object.size ? 50
    mesh.scale.set scale, scale, scale
  mesh.name = object._id
  return mesh