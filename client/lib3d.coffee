class Point
  # x
  # y
  # z
  # these are the three values which define the point
  
  constructor: (@x, @y, @z) ->


class BoundingBox
  # center
  # this is the center of the bounding box
  
  # width
  # height
  # depth
  # lengths of each sides of the bounding box
  
  # halfWidth
  # halfHeight
  # halfDepth
  # these are the lengths half's
  # can be used to calculate points on the outside without calculating the value of the half of the lengths
  
  constructor: (x, y, z, @width, @height, @depth) ->
    @center = new Point(x, y, z)

    @halfWidth = @width / 2
    @halfHeight = @height / 2
    @halfDepth = @depth / 2
  
  intersects: (point) ->
    return false if point.x < @center.x - @halfWidth || point.x > @center.x + @halfWidth ||
                    point.y < @center.y - @halfHeight || point.y > @center.y + @halfHeight ||
                    point.z < @center.z - @halfDepth || point.z > @center.z + @halfDepth
    return true

class Octree
  # minLevel
  # the minimum level says what the minimum level of the tree has to be
  # for example the minimum is 5 then the tree has to be split to level 5 and
  # the biggest voxel can be one 5th of the octree
  # it has to be at least 1
  
  # maxLevel
  # the maximum level is the exact opposite of the minimum level
  # the tree cannot be split further than the maximum level, so it is the deepest level in the tree
  
  # currentLevel
  # is the current level in the tree
  
  # isInUse
  # says whether the voxel is set and should be drawn
  
  # boundingBox
  # the bounding box of the current note in the tree

  # topLeftFront
  # topRightFront
  # bottomLeftFront
  # bottomRightFront
  # topLeftBack
  # topRightBack
  # bottomLeftBack
  # bottomRightBack
  # these are the children of the note
  
  constructor: (minLevel, maxLevel, currentLevel, boundingBox)->
    #console.log "----------------------------------------------- ctor"
    if minLevel >= 0
      @minLevel = minLevel
    else
      @minLevel = 0
    
    if maxLevel > minLevel
      @maxLevel = maxLevel  
    else
      @maxLevel = minLevel
    
    @currentLevel = currentLevel
    
    @boundingBox = boundingBox
    
    @split() if @currentLevel < @minLevel
    
  split: ->
    #console.log "----------------------------------------------- split"
    return if @maxLevel <= @currentLevel || @topLeftFront != undefined

    @instantiateChildren()

    if @isInUse
      @fillAllChildren()
      @isInUse = false

    return
  
  instantiateChildren: ->
    #console.log "----------------------------------------------- instantiateChildren"
    
    x = @boundingBox.center.x
    y = @boundingBox.center.y
    z = @boundingBox.center.z
    
    width = @boundingBox.width
    height = @boundingBox.height
    depth = @boundingBox.depth

    halfWidth = @boundingBox.halfWidth
    halfHeight = @boundingBox.halfHeight
    halfDepth = @boundingBox.halfDepth

    halfHalfWidth = halfWidth / 2
    halfHalfHeight = halfHeight / 2
    halfHalfDepth = halfDepth / 2

    newCurrentLevel = @currentLevel + 1


    boundingBox = new BoundingBox(x - halfHalfWidth, y + halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @topLeftFront = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x + halfHalfWidth, y + halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @topRightFront = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x - halfHalfWidth, y - halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @bottomLeftFront = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x + halfHalfWidth, y - halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @bottomRightFront = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)
    

    boundingBox = new BoundingBox(x - halfHalfWidth, y + halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @topLeftBack = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x + halfHalfWidth, y + halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @topRightBack = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x - halfHalfWidth, y - halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @bottomLeftBack = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)

    boundingBox = new BoundingBox(x + halfHalfWidth, y - halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth)
    @bottomRightBack = new Octree(@minLevel, @maxLevel, newCurrentLevel, boundingBox)
    
    return
  
  fillAllChildren: ->
    #console.log "----------------------------------------------- fillAllChildren"
    @topLeftFront.fill()
    @topRightFront.fill()
    @bottomLeftFront.fill()
    @bottomRightFront.fill()

    @topLeftBack.fill()
    @topRightBack.fill()
    @bottomLeftBack.fill()
    @bottomRightBack.fill()

    return

  fill: ->
    #console.log "----------------------------------------------- fill"
    @isInUse = true

    return

  insertPointInChildren: (point, level)->
    #console.log "----------------------------------------------- insertPointInChildren"
    @split() if @topLeftFront == undefined

    # if we are in the maximum level right now, we cannot split and we have to set the current voxel to isInUse, so it will be drawn
    if @topLeftFront == undefined
      @isInUse = true
      return

    @topLeftFront.insert point, level
    @topRightFront.insert point, level
    @bottomLeftFront.insert point, level
    @bottomRightFront.insert point, level
    
    @topLeftBack.insert point, level
    @topRightBack.insert point, level
    @bottomLeftBack.insert point, level
    @bottomRightBack.insert point, level
    
    return
  
  insert: (point, level) ->
    #console.log "----------------------------------------------- insert"
    
    if !@boundingBox.intersects point || @isInUse
      return
    
    level = @minLevel if level < @minLevel
    level = @maxLevel if level > @maxLevel

    if level > @currentLevel
      @insertPointInChildren(point, level)
    else if level == @currentLevel
      @isInUse = true
      ###
      console.log "inserted point"
      console.log "level: " + @currentLevel
      console.log "position:"
      console.log @boundingBox.center
      ###
    return
  
  removePointInChildren: (point, level)->
    #console.log "----------------------------------------------- removePointInChildren"
    @split() if @topLeftFront == undefined || (@isInUse && level > @currentLevel && @currentLevel <= @maxLevel)

    # if we are in the maximum level right now, we cannot split and we have to set the current voxel to isInUse, so it will be drawn
    if @topLeftFront == undefined
      @isInUse = false
      return

    @topLeftFront.remove point, level
    @topRightFront.remove point, level
    @bottomLeftFront.remove point, level
    @bottomRightFront.remove point, level
    
    @topLeftBack.remove point, level
    @topRightBack.remove point, level
    @bottomLeftBack.remove point, level
    @bottomRightBack.remove point, level
    
    return
  
  remove: (point, level) ->
    #console.log "----------------------------------------------- remove"
    return if !@boundingBox.intersects point

    level = @minLevel if level < @minLevel
    level = @maxLevel if level > @maxLevel

    if level > @currentLevel
      @removePointInChildren(point, level)
    else if level == @currentLevel
      @isInUse = false
      ###
      console.log "removed point"
      console.log "level: " + @currentLevel
      console.log "position:"
      console.log @boundingBox.center
      ###
    return

  draw: (scene)->
    # experimental!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(isInUse)
      cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial)
      cubeMesh.position = cube.position

      scene.add cubeMesh

    if @topLeftFront != undefined
      @topLeftFront.draw scene
      @topRightFront.draw scene
      @bottomLeftFront.draw scene
      @bottomRightFront.draw scene
      
      @topLeftBack.draw scene
      @topRightBack.draw scene
      @bottomLeftBack.draw scene
      @bottomRightBack.draw scene

    return