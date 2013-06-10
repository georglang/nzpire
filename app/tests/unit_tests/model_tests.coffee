###
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
###

# # Unit_Tests
# ## Steps to success:
# ### * Clear database before running unit_tests
# ### * Start Meteorite Server with: sudo METEOR_MOCHA_TEST_DIRS=tests/unit_tests mrt
# ### * Call localhost:3000/unit_tests
# ### * Check out your tests

describe "Profile", ->
  describe "Profile", ->
    it "create new Account", ->
      if not Meteor.userId()
        Accounts.createUser
          username: "maxmustermann"
          password: "password"
          email: "a@b.com"
          profile:
            name: "Max Mustermann"

        chai.assert.equal Meteor.user()?,true

describe "Models", ->
  describe "Model Methods", ->
    it "Create new Model", ->
      if Meteor.user()?.services
        options = {name: "testmodel", creator: currentProfile()?._id, predecessor: "", isPublic: false}
        Meteor.call 'createModel',options
        createdModel = Models.findOne({name: "testmodel"})
        chai.assert.equal createdModel?, true

    it "Create same Model again", ->
      if Meteor.user()?.services
        options = {name: "testmodel", creator: currentProfile()?._id, predecessor: "", isPublic: false}
        Meteor.call 'createModel',options
        createdModel = Models.find({name: "testmodel"}).fetch()
        chai.assert.equal createdModel.length, 1

    it "Rename Model", ->
      if Meteor.user()?.services
        modelId = Models.findOne({name:"testmodel"})
        optionsUpdateModelName = {_id: modelId._id, name: "renamedTestmodel"}
        Meteor.call 'updateModelName',optionsUpdateModelName

        oldModel = Models.find({name:"testmodel"}).fetch()
        chai.assert.equal oldModel.length, 0

        renamedModel = Models.find({name:"renamedTestmodel"}).fetch()
        chai.assert.equal renamedModel.length, 1

    it "Clone Model", ->
      if Meteor.user()?.services
        predecessorModel = Models.find({name:"renamedTestmodel"}).fetch()
        chai.assert.equal predecessorModel.length, 1

        options = {name: "clonedModel", predecessor: predecessorModel[0]?._id, creator: currentProfile()?._id,isPublic: false}
        Meteor.call 'cloneModel',options

        clonedModel = Models.find({name:"clonedModel"}).fetch()
        chai.assert.equal clonedModel.length, 1        

    it "Update Model Public State", ->
      if Meteor.user()?.services
        model = Models.findOne({name:"renamedTestmodel"})
        chai.assert.equal model.isPublic, false

        options = {_id: model._id,isPublic: true}
        Meteor.call 'updateModelIsPublic',options

        updatedModel = Models.findOne({name:"renamedTestmodel"})
        chai.assert.equal updatedModel.isPublic, true

    it "Add Tags to Model", ->
      if Meteor.user()?.services
        model = Models.findOne({name:"renamedTestmodel"})
        chai.assert.equal model.tags.length, 0

        options = {_id: model._id,tag: "testTag1"}
        Meteor.call 'updateModelTag', options

        updatedModel = Models.find({name:"renamedTestmodel"})
        chai.assert.equal updatedModel.tags[0], "testTag1"
        
  describe "Model Permissions", ->
    it "Check Permission", ->
      if Meteor.user()?.services
        model = Models.findOne({name:"renamedTestmodel"})      
        chai.assert.equal checkModelPermission(model._id,true), Roles.creator