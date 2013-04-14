Meteor.startup ->
  # code to run on server at startup

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

Meteor.publish 'modelContent', (modelContentId) ->
  modelContent = ModelContents.find _id: modelContentId
  console.log 'model content', modelContent
  return modelContent