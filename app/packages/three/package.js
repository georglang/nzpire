Package.describe({
  summary: "THREE.js - a 3D rendering lib, easy to use and yet powerful."
});

Package.on_use(function (api) {
  api.add_files([
    'three.min.js',
    'FlyControls.js',
    'TrackballControls.js',
    'FocusControls.js',
    'Detector.js'
  ], ['client']
  );
});