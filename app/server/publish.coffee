Meteor.startup ->
  Profiles.allow
    update: (userId, doc, fields, modifier) ->
      if currentProfile()?._id ==  doc._id
        return true
      return false
    remove: (userId, doc) ->
      if currentProfile()?._id ==  doc._id
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

Meteor.publish 'model', (modelId) ->
  user = Meteor.users.findOne({_id: this.userId})
  if user
    modelCursor = Models.find({$and: [{_id: modelId}, {$or: [{isPublic: true},{'invited.userId': currentProfile._id},{creator: currentProfile._id}]}]});
    model = modelCursor.fetch()[0]
    if model
      modelObjectsCursor = ModelObjects.find modelId: modelId
      modelActionsCursor = ModelActions.find modelId: modelId
    return [modelCursor, modelObjectsCursor, modelActionsCursor]
  else
    return []
