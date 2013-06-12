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

# # Model_Sidebar

# ##Owner
# Checks if the current User the models owner is    
#  * return: bool
Template.modelSidebar.isOwner = ->
  if Meteor.user() == null
    return false
  else
    if currentProfile()._id == findOneModelByOptions({_id: Session.get('modelId')}).creator
      return true
    else
      return false

# ## Modelname
# * return: string
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

# ## UpdatedAt
# * return: date
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

# ## Tags
# * return: array
Template.modelSidebar.tags = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    tags = []
    tags.push({name: i, class:""}) for i in model.tags
    #tags = model.tags
    if tags != undefined
      if Template.modelSidebar.isOwner()    
        tags.push {name:"click to tag", class: "addAble"}
      return tags
    else
      return null

# ## Creator
# * return: string
Template.modelSidebar.creator = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    creatorId = model.creator
    if creatorId != ""
      name = findOneProfileByOptions({_id: creatorId})?.name
      return name
    else
      return null

# ## Invited
# * return: array
Template.modelSidebar.invited = ->
  names = []
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    invitedPeople = model.invited
    if invitedPeople != undefined
      names.push({name: findOneProfileByOptions({_id: i.userId}).name,role: i.role, class:""}) for i in invitedPeople
      if Template.modelSidebar.isOwner()
        names.push {name:"click to invite",role:"",class:"addAble"}
      return names
    else
      return null

# ## Predecessor
# * return: string
Template.modelSidebar.predecessor = ->
  model = findOneModelByOptions({_id: Session.get('modelId')})
  if model == undefined
    return null
  else
    predecessorId = model.predecessor
    if predecessorId != ""
      name = findOneModelByOptions({_id:predecessorId})?.name
      return name
    else
      return null
 
# ## Publicity
# * return: bool  
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

# ## Profilelist
# * return: cursor
Template.modelSidebar.profilesList = ->
  return Profiles.find({})

# ## Favourite
# * return: bool
Template.modelSidebar.isFavourited = ->
  if Meteor.user() == null
    return false
  else
    favourited = findOneProfileByOptions({_id: currentProfile()._id,favourites: Session.get('modelId')})
    if favourited == undefined
      return true
    else
      return false

Template.modelSidebar.isShortcutShow = ->
  if not Session.get 'activeShortcutInfo'
    return true
  return false

getSnapshotDataURL = (width, height, format) ->
  originalWidth = Modeling.renderer.domElement.width
  originalHeight = Modeling.renderer.domElement.height

  Modeling.renderer.setSize width, height
  Modeling.scene.camera.aspect = width / height
  Modeling.scene.camera.updateProjectionMatrix()
  Modeling.renderer.render Modeling.scene.itself, Modeling.scene.camera
  snapshotDataURL = Modeling.renderer.domElement.toDataURL("image/" + format)
  
  Modeling.renderer.setSize originalWidth, originalHeight
  Modeling.scene.camera.aspect = originalWidth / originalHeight
  Modeling.scene.camera.updateProjectionMatrix()
  Modeling.renderer.render Modeling.scene.itself, Modeling.scene.camera
  snapshotDataURL

# ## Events
Template.modelSidebar.events

  # ### Model Owner Events
  # #### Manages create, edit and delete for:
  'click #slideContainerListItems>li>ul>li': (e)->
    if Template.modelSidebar.isOwner()
      className = e.target.className
      # ##### * Modelname
      if className == 'modelname'
        $(e.target).replaceWith("<input autofocus='autofocus' id='editModelName' type='text' value='"+Template.modelSidebar.modelname()+"'>")
      # ##### * Tags
      else if className == 'tags addAble'
        tagName = $(e.target).html()
        $(e.target).replaceWith("<input autofocus='autofocus' id='addTag' type='text' placeholder='Tagname'>")
      else if className == 'tags '
        tagName = $(e.target).html()
        options = {_id: Session.get('modelId'),tag: tagName}
        Meteor.call 'removeModelTag', options, (error,result)->
          if error
            console.log error.reason
      # ##### * Invites
      else if className == 'invited addAble'
        invitedName = $(e.target).html()
        #$(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'><select id='invitedRole'><option value='owner'>Owner</option><option value='collaborator'>Collaborator</option><option value='viewer'>Viewer</option></select><input id='addInviteButton' type='button' value='invite'>")
        $(e.target).replaceWith("<input autofocus='autofocus' id='addInvite' type='text' list='profilesDatalist' placeholder='Username'><br><input type='radio' name='role' value='owner'>Owner <br><input type='radio' name='role' value='collaborator'>Collaborator <br><input type='radio' name='role' value='viewer' checked='checked'>Viewer <br><input id='addInviteButton' type='button' value='invite'>")
      else if className == 'invited '
        invitedName = $(e.target).html()
        options = {_id: Session.get('modelId'),invite: invitedName}
        Meteor.call 'removeModelInvite', options, (error,result)->
          if error
            console.log error.reason
      # ##### * Publicity
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
    #role = $('#invitedRole').val()
    role = $('input:radio[name=role]:checked').val()
    options = {_id: Session.get('modelId'),invite: $('#addInvite').val(),role:role}
    Meteor.call 'updateModelInvite',options, (error,result)->
      if error
        $('#addInvite').after("<div id='errorUpdateInvite'>"+error.reason+"</div>")   

  'keydown #addInvite': (e)->
    if e.keyCode == 13
      $('#addInviteButton').click()      

  # ### Viewer Events:
  # #### * Favourite
  'click #favourite': ->
    Profiles.update {_id: currentProfile()._id},{$push: {favourites: Session.get('modelId')}}
    
  # #### * Defavourite
  'click #defavourite': ->
    Profiles.update {_id: currentProfile()._id},{$pull:{favourites: Session.get('modelId')}}

  # #### * Clone
  'click #clone': (e)->
    if $('#cloneModelName')[0] != undefined
      $('#cloneModelName').remove()
      $('#createCloneModel').remove()
    $(e.target).after("<input type='text' id='cloneModelName' placeholder='Enter Modelname'><input class='btn btn-primary' type='button' id='createCloneModel' value='Create Clone'>")

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

  # #### * Snapshot
  'click #takeSnapshot': ->
    snapshotDataURL = getSnapshotDataURL(100,100,'png')
    Models.update({_id: Session.get('modelId')},{$set: {snapshotURL: snapshotDataURL}})

  # #### * Show Shortcuts
  'click #showShortcuts': ->
    Session.set 'activeShortcutInfo', true

  'click #hideShortcuts': ->
    Session.set 'activeShortcutInfo', false

  'click #download': ->
    options = 
      id: Session.get "modelId"
    Meteor.call 'saveModelToObjectFile', options, (error, result) ->
      if error
        $('#createNewModel').after("<div id='errorCloneModel'>"+error.reason+"</div>")
      else
        objBlob = new Blob([result.obj], {type: "text/plain;charset=utf-8"})
        saveAs(objBlob, "model.obj")
        
        mtlBlob = new Blob([result.mtl], {type: "text/plain;charset=utf-8"})
        saveAs(mtlBlob, "model.mtl")







