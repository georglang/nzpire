Package.describe({
  summary: "FileSaver.js and BlobBuilder.js - libraries to build blob data and save it on the client side."
});

Package.on_use(function (api) {
  api.add_files([
    'Blob.js',
    'FileSaver.min.js'
  ], ['client']
  );
});