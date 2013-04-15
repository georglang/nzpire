(function(){ 
describe("Model", function() {
  return describe("updateModelname", function() {
    return it("renames the Model", function() {
      var modelId, newModelId, options, optionsUpdateModelName;
      options = {
        name: "testmodel",
        creator: "Altmann Christoph",
        predecessor: "",
        isPublic: false
      };
      Meteor.call('createModel', options, function(error, result) {
        if (error) {
          return console.log(error.reason);
        }
      });
      modelId = findOneModelByOptions(options);
      optionsUpdateModelName = {
        _id: modelId._id,
        name: "renamedTestModel"
      };
      Meteor.call('updateModelName', optionsUpdateModelName, function(error, result) {
        if (error) {
          return console.log(error.reason);
        }
      });
      newModelId = findOneModelByOptions(optionsUpdateModelName);
      chai.assert.equal(modelId._id, newModelId._id);
      chai.expect(modelId._id).to.equal(newModelId._id);
      chai.should();
      return modelId._id.should.equal(newModelId._id);
    });
  });
});

})();
