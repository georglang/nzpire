Package.describe({
  summary: "parallel.js - a tiny library for multi-core processing in JavaScript."
});

Package.on_use(function (api) {
  api.add_files([
    'parallel.js'
  ], ['client']
  );
});