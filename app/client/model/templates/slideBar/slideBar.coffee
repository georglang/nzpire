# ## Model_Sidebar

Template.modelSidebar.isOwner = ->
  if Meteor.user() == null
    return false
  else
    if currentProfile()._id == findOneModelByOptions({_id: Session.get('modelId')}).creator
      return true
    else
      return false

Template.modelSidebar.modelname = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    name = model.name
    if name != undefined
      return name
    else
      return null

Template.modelSidebar.updatedAt = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    updatedAt = model.updatedAt
    if updatedAt != undefined
      d = new Date(updatedAt)
      return d.toUTCString()
    else
      return null

Template.modelSidebar.tags = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    tags = model.tags
    if tags != undefined
      if Template.modelSidebar.isOwner()    
        tags.push ""
      return tags
    else
      return null

Template.modelSidebar.creator = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    creatorId = model.creator
    if creatorId != ""
      name = findOneProfileByOptions({_id: creatorId}).name
      return name
    else
      return null

Template.modelSidebar.invited = ->
  names = []
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    invitedPeople = model.invited
    if invitedPeople != undefined
      names.push({name: findOneProfileByOptions({_id: i.userId}).name,role: i.role}) for i in invitedPeople
      if Template.modelSidebar.isOwner()
        names.push {name:"",role:""}
      return names
    else
      return null

Template.modelSidebar.predecessor = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    predecessorId = model.predecessor
    if predecessorId != ""
      name = findOneModelByOptions({_id:predecessorId}).name
      return name
    else
      return null
  
Template.modelSidebar.isPublic = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    isPublic = model.isPublic
    if isPublic != undefined
      return isPublic
    else
      return null

Template.modelSidebar.profilesList = ->
  return Profiles.find({})

Template.modelSidebar.isFavourited = ->
  if Meteor.user() == null
    return false
  else
    favourited = findOneProfileByOptions({_id: currentProfile()._id,favourites: Session.get('modelId')})
    if favourited == undefined
      return true
    else
      return false

Template.modelSidebar.events
  'click #slideContainerListItems>li>ul>li': (e)->
    if Template.modelSidebar.isOwner()
      className = e.target.className
      if className == 'modelname'
        $(e.target).replaceWith("<input autofocus='autofocus' id='editModelName' type='text' value='"+Template.modelSidebar.modelname()+"'>")
      else if className == 'tags'
        tagName = $(e.target).html()
        if tagName.length == 0
          $(e.target).replaceWith("<input autofocus='autofocus' id='addTag' type='text' placeholder='Tagname'>")
        else
          options = {_id: Session.get('modelId'),tag: tagName}
          Meteor.call 'removeModelTag', options, (error,result)->
            if error
              console.log error.reason
      else if className == 'invited'
        invitedName = $(e.target).html()
        if invitedName.length == 0
          $(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'><select id='invitedRole'><option value='owner'>Owner</option><option value='collaborator'>Collaborator</option><option value='viewer'>Viewer</option></select><input id='addInviteButton' type='button' value='invite'>")
        else
          options = {_id: Session.get('modelId'),invite: invitedName}
          Meteor.call 'removeModelInvite', options, (error,result)->
            if error
              console.log error.reason
      else if className == 'isPublic'
        options = {_id: Session.get('modelId'),isPublic: Template.modelSidebar.isPublic()}
        Meteor.call 'updateModelIsPublic',options, (error,result)->
          if error
            console.log error.reason

  'blur #editModelName': (e)->
    modelName = e.target.value
    if modelName.length > 3
      if $('#errorUpdateModelName')[0] != undefined
        $('#errorUpdateModelName').remove() 

      options = {_id:Session.get('modelId'),name: modelName}
      Meteor.call 'updateModelName', options, (error,result) ->
        if error
          $('#editModelName').after("<div id='errorUpdateModelName'>"+error.reason+"</div>")


  'keydown #editModelName': (e)->
    if e.keyCode == 13
      $('#editModelName').blur()

  'blur #addTag': (e)->
    if $('#errorUpdateTag')[0] != undefined
      $('#errorUpdateTag').remove()     
    options = {_id: Session.get('modelId'),tag: e.target.value}
    Meteor.call 'updateModelTag', options, (error,result)->
      if error
        $('#addTag').after("<div id='errorUpdateTag'>"+error.reason+"</div>")     

  'keydown #addTag': (e)->
    if e.keyCode == 13
      $('#addTag').blur()

  'click #addInviteButton': (e)->
    if $('#errorUpdateInvite')[0] != undefined
      $('#errorUpdateInvite').remove()        
    role = $('#invitedRole').val()
    options = {_id: Session.get('modelId'),invite: $('#addInvite').val(),role:role}
    Meteor.call 'updateModelInvite',options, (error,result)->
      if error
        $('#addInvite').after("<div id='errorUpdateInvite'>"+error.reason+"</div>")   

  'keydown #addInvite': (e)->
    if e.keyCode == 13
      $('#addInviteButton').click()      

  'click #favourite': ->
    Profiles.update {_id: currentProfile()._id},{$push: {favourites: Session.get('modelId')}}

  'click #defavourite': ->
    Profiles.update {_id: currentProfile()._id},{$pull:{favourites: Session.get('modelId')}}

  'click #clone': (e)->
    if $('#cloneModelName')[0] != undefined
      $('#cloneModelName').remove()
      $('#createCloneModel').remove()
    $(e.target).after("<input type='text' id='cloneModelName' placeholder='Enter Modelname'><input type='button' id='createCloneModel' value='Create Clone'>")

  'click #createCloneModel': ->
    modelName = $('#cloneModelName').val()
    if $('#errorCloneModel')[0] != undefined
      $('#errorCloneModel').remove()

    options = {name: modelName, predecessor: Session.get('modelId'), creator: currentProfile()._id,isPublic: false}
    Meteor.call 'cloneModel',options, (error,result)->
      if error
        $('#createNewModel').after("<div id='errorCloneModel'>"+error.reason+"</div>")
      else
        Workspace.model(result)

