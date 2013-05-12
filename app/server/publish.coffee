Meteor.startup ->
  Profiles.allow
    update: (userId, doc, fields, modifier) ->
      return true
    remove: (userId, doc) ->
      return true

Meteor.publish "userData", ->
  return Meteor.users.find {_id: this.userId},
    fields:
      'services': 1
      'mail': 1

Meteor.publish "allProfiles", ->
	Profiles.find({})

Meteor.publish "allModels", ->
	Models.find({})

Meteor.publish 'model', (modelId) ->
  return  Models.find _id: modelId

Meteor.publish 'modelObjects', (modelId) ->
  modelObjects = ModelObjects.find modelId: modelId
  return modelObjects