describe "Model", ->
  describe "updateModelname", ->
    it "renames the Model", ->
      #create a model
      options = {name: "testmodel", creator: "Altmann Christoph", predecessor: "", isPublic: false}
      Meteor.call 'createModel',options, (error,result)->
      	if error 
      		console.log error.reason

      console.log Models.find({}).fetch()

      modelId = findOneModelByOptions(options)
      optionsUpdateModelName = {_id: modelId._id, name: "renamedTestModel"}
      Meteor.call 'updateModelName',optionsUpdateModelName, (error,result)->
      	if error
      		console.log error.reason

      console.log Models.find({}).fetch()    
      
      newModel = findOneModelByOptions(optionsUpdateModelName)
      chai.assert.equal modelId._id, newModel._id
      chai.assert.equal newModel.name, "renamedTestModel"
      chai.expect(modelId._id).to.equal(newModel._id)
      chai.should()
      modelId._id.should.equal(newModel._id)

      optionsRemove = {name: newModel.name}
      Meteor.call 'removeModel',optionsRemove, (error,result)->
        if error
          console.log error.reason

      console.log Models.find({}).fetch()

      optionsRemove2 = {name: "testmodel"}
      Meteor.call 'removeModel',optionsRemove2, (error,result)->
        if error
          console.log error.reason

      console.log Models.find({}).fetch()
