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

# # Published data sets

# ## Profiles

# ### All profiles
# Profile information is published without restriction.
# This is crucial for search functionality.

Meteor.publish "allProfiles", ->
  Profiles.find({})

# ### User data
# The following user data is only published to the user,
# currently logged in:
# * login services (facebook, twitter, google plus, github)
# * email address
Meteor.publish "userData", ->
  return Meteor.users.find {_id: this.userId},
    fields:
      'services': 1
      'mail': 1

# ### Allow rules
# These rules only apply to direct changes to the database,
# coming from the client.
# The following operations may only be performed by the profile owner:
# * updating
# * removing

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

# ## Models
# ### All Models
# Model information is published to every client
# with the following restrictions:
# * no action ids (needed for action history = undo/redo funtionality)
# * no colors (needed for editing shortcuts)
Meteor.publish "allModels", ->
  user = Meteor.users.findOne({_id: this.userId})
  if not user 
    return Models.find({isPublic: true},{fields: _id: 1, name: 1, tags: 1})

  userMail = Meteor.users.findOne({_id: this.userId}).mail[0]
  currentProfile = Profiles.find({email:userMail}).fetch()[0]
  return Models.find({
    $or: [
      {isPublic: true},
      {'invited.userId': currentProfile?._id},
      {creator: currentProfile?._id}
    ]
  }, {
    fields: {
      actionIds: 0,
      colors: 0
    }
  });

# ### Model (to view or to edit)
# The following model information is published to all clients,
# requesting information about a specific model (for viewing or editing),
# who have at least the role 'viewer':
# * unrestricted model information
# * model objects
# * model actions
Meteor.publish 'model', (modelId) ->
  user = Meteor.users.findOne({_id: this.userId})
  if not user
    modelCursor = Models.find
      _id: modelId
      isPublic: true
    model = modelCursor.fetch()[0]
    if not model
      return []
    modelObjectsCursor = ModelObjects.find modelId: modelId
    return [modelCursor, modelObjectsCursor]

  userMail = Meteor.users.findOne({_id: this.userId}).mail[0]
  currentProfile = Profiles.find({email:userMail}).fetch()[0]

  modelCursor = Models.find({
    $and: [
      {_id: modelId},
      {
        $or: [
          {isPublic: true},
          {'invited.userId': currentProfile?._id},
          {creator: currentProfile?._id}
        ]
      }
    ]
  });
  model = modelCursor.fetch()[0]
  if not model
    return []

  modelObjectsCursor = ModelObjects.find modelId: modelId
  modelActionsCursor = ModelActions.find modelId: modelId
  modelChatCursor = ModelChat.find modelId: modelId
  return [modelCursor, modelObjectsCursor, modelActionsCursor, modelChatCursor]