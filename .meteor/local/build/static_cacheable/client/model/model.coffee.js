(function(){ var camera, cubesNode, lastMousePosition, mouseDelta;

camera = void 0;

lastMousePosition = void 0;

mouseDelta = void 0;

cubesNode = void 0;

Template.model.events({
  'click canvas': function(e) {
    console.log('inserting cube into the scene');
    return Cubes.insert({
      position: camera.position
    });
  },
  'mouseover #modelContainer': function(e) {},
  'mouseout #modelContainer': function(e) {},
  'mousemove #modelContainer': function(e) {},
  'keydown #modelContainer': function(e) {
    if (e.keyCode === 76) {
      console.log('removing all cubes from the scene');
      return Cubes.remove({});
    }
  }
});

Template.model.create = function() {
  return Meteor.defer(function() {
    var ASPECT, FAR, NEAR, VIEW_ANGLE, clock, container, controls, cubeMaterial, pointLight, render, renderer, scene, x, y, z;
    cubesNode = new THREE.Object3D();
    $(window).resize(function() {
      var ASPECT, HEIGHT, WIDTH;
      WIDTH = container.width();
      HEIGHT = container.height();
      ASPECT = WIDTH / HEIGHT;
      renderer.setSize(WIDTH, HEIGHT);
      camera.aspect = ASPECT;
      return camera.updateProjectionMatrix();
    });
    container = $("#modelContainer");
    container.focus();
    VIEW_ANGLE = 45;
    ASPECT = 1;
    NEAR = 0.1;
    FAR = 10000;
    renderer = new THREE.WebGLRenderer();
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
    $(window).resize();
    controls = new THREE.FlyControls(camera, document.getElementById('modelContainer'));
    controls.movementSpeed = 1000;
    controls.rollSpeed = 1.0;
    controls.dragToLook = true;
    clock = new THREE.Clock();
    scene = new THREE.Scene();
    scene.add(camera);
    camera.position.z = 300;
    scene.add(cubesNode);
    cubeMaterial = new THREE.MeshLambertMaterial({
      color: 0xCC0000
    });
    x = -1;
    while (x < 2) {
      y = -1;
      while (y < 2) {
        ++y;
        z = -1;
        while (z < 2) {
          ++z;
          pointLight = new THREE.PointLight(0xFFFFFF);
          pointLight.position.x = x * 400;
          pointLight.position.y = z * 400;
          pointLight.position.z = y * 400;
          scene.add(pointLight);
        }
      }
      ++x;
    }
    container.append(renderer.domElement);
    render = function() {
      if (Session.get("template") === "model") {
        renderer.render(scene, camera);
        controls.update(clock.getDelta());
      }
      return requestAnimationFrame(render);
    };
    render();
    return Meteor.autorun(function() {
      var c, cubes, numOfCubes;
      console.log("running model autorun ...");
      cubes = Cubes.find().fetch();
      numOfCubes = cubesNode.children.length;
      c = 0;
      while (c < numOfCubes) {
        ++c;
        cubesNode.remove(cubesNode.children[0]);
      }
      return cubes.forEach(function(cube) {
        var cubeMesh;
        cubeMesh = new THREE.Mesh(new THREE.CubeGeometry(50, 50, 50), cubeMaterial);
        cubeMesh.position = cube.position;
        return cubesNode.add(cubeMesh);
      });
    });
  });
};

})();
