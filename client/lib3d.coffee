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
