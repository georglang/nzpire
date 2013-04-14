Meteor.startup ->
  Profiles.allow
    update: (userId, doc, fields, modifier) ->
      return true