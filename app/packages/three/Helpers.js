inputShouldNotBeIgnored = function(event) {
  var doNotIgnoreInput, tagName, tagNamesToIgnore;
  tagName = $(event.target).prop('tagName');
  tagNamesToIgnore = ['INPUT', 'TEXTAREA'];
  return doNotIgnoreInput = tagNamesToIgnore.indexOf(tagName) === -1;
};