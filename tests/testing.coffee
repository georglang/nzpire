describe "Model", ->
  describe "updateModelname", ->
    it "renames the Model", ->
      #create a model
      options = {name: "testmodel", creator: "Altmann Christoph", predecessor: "", isPublic: false}
      Meteor.call 'createModel',options, (error,result)->
      	if error
      		console.log error.reason

      modelId = findOneModelByOptions(options)

      optionsUpdateModelName = {_id: modelId._id, name: "renamedTestModel"}
      Meteor.call 'updateModelName',optionsUpdateModelName, (error,result)->
      	if error
      		console.log error.reason

      newModelId = findOneModelByOptions(optionsUpdateModelName)

      chai.assert.equal modelId._id, newModelId._id
      chai.expect(modelId._id).to.equal(newModelId._id)
      chai.should()
      modelId._id.should.equal(newModelId._id)