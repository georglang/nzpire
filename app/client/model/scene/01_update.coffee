# # Update

@Modeling ?= {}
Modeling.scene ?= {}
scene = Modeling.scene

getContent = ->
  ModelContents.findOne Session.get 'modelContentId'

clearContent = ->
  content = Modeling.scene.content
  # removes all children from the content node
  numOfObjects = content.children.length
  o = 0
  while o < numOfObjects
    ++o
    content.remove content.children[0]

cubeMaterial = new THREE.MeshLambertMaterial color: 0x7FAD00

refillContentWith = (newContent) ->
  content = Modeling.scene.content
  # adds content to content node
  newContent?.objects?.forEach (object) ->
    cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
    cubeMesh.position = object.position

    content.add cubeMesh

# for updating:
scene.update = ->
  newContent = getContent()
  if newContent
    # * clear content
    clearContent()
    # * refill content
    refillContentWith newContent