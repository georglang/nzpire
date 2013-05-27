Meteor.startup ->
  Profiles.allow
    update: (userId, doc, fields, modifier) ->
      if currentProfile()._id ==  doc._id
        return true
      return false
    remove: (userId, doc) ->
      if currentProfile()._id ==  doc._id
        return true
      return false

Meteor.publish "userData", ->
  return Meteor.users.find {_id: this.userId},
    fields:
      'services': 1
      'mail': 1

Meteor.publish "allProfiles", ->
	Profiles.find({})

Meteor.publish "allModels", ->
  user = Meteor.users.findOne({_id: this.userId})
  if not user 
    return Models.find({isPublic: true},{fields: _id: 1, name: 1, tags: 1})

  userMail = Meteor.users.findOne({_id: this.userId}).mail[0]
  currentProfile = Profiles.find({email:userMail}).fetch()[0]
  models = Models.find({$or: [{isPublic: true},{'invited.userId': currentProfile._id},{creator: currentProfile._id}]},{fields: actionIds: 0, colors: 0, invited: 0})
  return models

  ###
  permittedModels = []
  allModels.forEach (m) ->
    permission = checkPermission(m._id,this.userId, userMail, true)
    if permission > Roles.none
      permittedModels.push m
  console.log permittedModels
  ###
  #return permittedModels


Meteor.publish 'model', (modelId) ->
  Models.find _id: modelId

Meteor.publish 'modelObjects', (modelId) ->
  modelObjects = ModelObjects.find modelId: modelId

Meteor.publish 'modelActions', (modelId) ->
  modelActions = ModelActions.find modelId: modelId