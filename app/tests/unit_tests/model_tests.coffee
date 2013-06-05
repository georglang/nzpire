describe "Model", ->
  describe "createModel", ->
    it "create new Model", ->
      if not Meteor.userId()
        Accounts.createUser
          username: "maxmustermann"
          password: "password"
          email: "a@b.com"
          profile:
            name: "Max Mustermann"

      if Meteor.user()?.services
        console.log "start"
        options = {name: "testmodel", creator: "Altmann Christoph", predecessor: "", isPublic: false}
        Meteor.call 'createModel',options
        createdModel = Models.findOne({name: "testmodel"})
        console.log createdModel
        chai.assert.equal createdModel?, true
        console.log "done"

    it "create new Model and throw Exception", ->
      if Meteor.user()?.services
        console.log "start2"
        console.log "start second Test"
        options = {name: "testmodel", creator: "Altmann Christoph", predecessor: "", isPublic: false}
        Meteor.call 'createModel',options
        
        console.log "done2"

      

      ###
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
      ###
