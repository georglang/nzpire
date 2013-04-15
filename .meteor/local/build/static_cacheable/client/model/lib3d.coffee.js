(function(){ var BoundingBox, Octree, Point;

Point = (function() {

  function Point(x, y, z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  return Point;

})();

BoundingBox = (function() {

  function BoundingBox(x, y, z, width, height, depth) {
    this.width = width;
    this.height = height;
    this.depth = depth;
    this.center = new Point(x, y, z);
    this.halfWidth = this.width / 2;
    this.halfHeight = this.height / 2;
    this.halfDepth = this.depth / 2;
  }

  BoundingBox.prototype.intersects = function(point) {
    if (point.x < this.center.x - this.halfWidth || point.x > this.center.x + this.halfWidth || point.y < this.center.y - this.halfHeight || point.y > this.center.y + this.halfHeight || point.z < this.center.z - this.halfDepth || point.z > this.center.z + this.halfDepth) {
      return false;
    }
    return true;
  };

  return BoundingBox;

})();

Octree = (function() {

  function Octree(minLevel, maxLevel, currentLevel, boundingBox) {
    if (minLevel >= 0) {
      this.minLevel = minLevel;
    } else {
      this.minLevel = 0;
    }
    if (maxLevel > minLevel) {
      this.maxLevel = maxLevel;
    } else {
      this.maxLevel = minLevel;
    }
    this.currentLevel = currentLevel;
    this.boundingBox = boundingBox;
    if (this.currentLevel < this.minLevel) {
      this.split();
    }
  }

  Octree.prototype.split = function() {
    if (this.maxLevel <= this.currentLevel || this.topLeftFront !== void 0) {
      return;
    }
    this.instantiateChildren();
    if (this.isInUse) {
      this.fillAllChildren();
      this.isInUse = false;
    }
  };

  Octree.prototype.instantiateChildren = function() {
    var boundingBox, depth, halfDepth, halfHalfDepth, halfHalfHeight, halfHalfWidth, halfHeight, halfWidth, height, newCurrentLevel, width, x, y, z;
    x = this.boundingBox.center.x;
    y = this.boundingBox.center.y;
    z = this.boundingBox.center.z;
    width = this.boundingBox.width;
    height = this.boundingBox.height;
    depth = this.boundingBox.depth;
    halfWidth = this.boundingBox.halfWidth;
    halfHeight = this.boundingBox.halfHeight;
    halfDepth = this.boundingBox.halfDepth;
    halfHalfWidth = halfWidth / 2;
    halfHalfHeight = halfHeight / 2;
    halfHalfDepth = halfDepth / 2;
    newCurrentLevel = this.currentLevel + 1;
    boundingBox = new BoundingBox(x - halfHalfWidth, y + halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.topLeftFront = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x + halfHalfWidth, y + halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.topRightFront = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x - halfHalfWidth, y - halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.bottomLeftFront = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x + halfHalfWidth, y - halfHalfHeight, z - halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.bottomRightFront = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x - halfHalfWidth, y + halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.topLeftBack = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x + halfHalfWidth, y + halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.topRightBack = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x - halfHalfWidth, y - halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.bottomLeftBack = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
    boundingBox = new BoundingBox(x + halfHalfWidth, y - halfHalfHeight, z + halfHalfDepth, halfWidth, halfHeight, halfDepth);
    this.bottomRightBack = new Octree(this.minLevel, this.maxLevel, newCurrentLevel, boundingBox);
  };

  Octree.prototype.fillAllChildren = function() {
    this.topLeftFront.fill();
    this.topRightFront.fill();
    this.bottomLeftFront.fill();
    this.bottomRightFront.fill();
    this.topLeftBack.fill();
    this.topRightBack.fill();
    this.bottomLeftBack.fill();
    this.bottomRightBack.fill();
  };

  Octree.prototype.fill = function() {
    this.isInUse = true;
  };

  Octree.prototype.insertPointInChildren = function(point, level) {
    if (this.topLeftFront === void 0) {
      this.split();
    }
    if (this.topLeftFront === void 0) {
      this.isInUse = true;
      return;
    }
    this.topLeftFront.insert(point, level);
    this.topRightFront.insert(point, level);
    this.bottomLeftFront.insert(point, level);
    this.bottomRightFront.insert(point, level);
    this.topLeftBack.insert(point, level);
    this.topRightBack.insert(point, level);
    this.bottomLeftBack.insert(point, level);
    this.bottomRightBack.insert(point, level);
  };

  Octree.prototype.insert = function(point, level) {
    if (!this.boundingBox.intersects(point || this.isInUse)) {
      return;
    }
    if (level < this.minLevel) {
      level = this.minLevel;
    }
    if (level > this.maxLevel) {
      level = this.maxLevel;
    }
    if (level > this.currentLevel) {
      this.insertPointInChildren(point, level);
    } else if (level === this.currentLevel) {
      this.isInUse = true;
      /*
      console.log "inserted point"
      console.log "level: " + @currentLevel
      console.log "position:"
      console.log @boundingBox.center
      */

    }
  };

  Octree.prototype.removePointInChildren = function(point, level) {
    if (this.topLeftFront === void 0 || (this.isInUse && level > this.currentLevel && this.currentLevel <= this.maxLevel)) {
      this.split();
    }
    if (this.topLeftFront === void 0) {
      this.isInUse = false;
      return;
    }
    this.topLeftFront.remove(point, level);
    this.topRightFront.remove(point, level);
    this.bottomLeftFront.remove(point, level);
    this.bottomRightFront.remove(point, level);
    this.topLeftBack.remove(point, level);
    this.topRightBack.remove(point, level);
    this.bottomLeftBack.remove(point, level);
    this.bottomRightBack.remove(point, level);
  };

  Octree.prototype.remove = function(point, level) {
    if (!this.boundingBox.intersects(point)) {
      return;
    }
    if (level < this.minLevel) {
      level = this.minLevel;
    }
    if (level > this.maxLevel) {
      level = this.maxLevel;
    }
    if (level > this.currentLevel) {
      this.removePointInChildren(point, level);
    } else if (level === this.currentLevel) {
      this.isInUse = false;
      /*
      console.log "removed point"
      console.log "level: " + @currentLevel
      console.log "position:"
      console.log @boundingBox.center
      */

    }
  };

  Octree.prototype.draw = function(scene) {
    var cubeMesh;
    if (isInUse) {
      cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial);
      cubeMesh.position = cube.position;
      scene.add(cubeMesh);
    }
    if (this.topLeftFront !== void 0) {
      this.topLeftFront.draw(scene);
      this.topRightFront.draw(scene);
      this.bottomLeftFront.draw(scene);
      this.bottomRightFront.draw(scene);
      this.topLeftBack.draw(scene);
      this.topRightBack.draw(scene);
      this.bottomLeftBack.draw(scene);
      this.bottomRightBack.draw(scene);
    }
  };

  return Octree;

})();

})();
