Cubes = new Meteor.Collection 'cubes'
Models = new Meteor.Collection 'models'


Meteor.methods
	createModel: (options)->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			return Models.insert({name: options.name,createdAt: new Date(),updatedAt:new Date(),tags:[],creator:options.creator,invited:[],predecessor:options.predecessor,isPublic:options.isPublic})

	updateModelName: (options)->
		checkNameAvailability = findModelByName options.name
		if checkNameAvailability
			throw new Meteor.Error(499, "Modelname already taken");
		else
			return Models.update({_id: options._id},{$set: {name: options.name}})

	updateModelIsPublic: (options)->
		isPublic = options.isPublic
		if options.isPublic == false
			isPublic = true
		else
			isPublic = false
		return Models.update({_id: options._id},{$set: {isPublic: isPublic}})

	updateModelTag: (options)->
		if options._id == undefined || options.tag == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		tagName = options.tag
		checkForAvailability = Models.findOne({_id: options._id, tags: tagName})
		if tagName.length < 3
			throw new Meteor.Error(497, "Tagname too short");
		else if checkForAvailability != undefined
			throw new Meteor.Error(498, "Tagname already added");
		else
			Models.update({_id: options._id},{$push: {tags: tagName}})

	updateModelInvite: (options)->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		if options.invite.length < 3
			throw new Meteor.Error(497, "Username too short");
		invitedProfile = Profiles.findOne({name: options.invite})

		if invitedProfile == undefined
			throw new Meteor.Error(496, "Username does not exist");
		else
			findObject = {userId: invitedProfile._id}
			checkAlreadyInvited = Models.findOne({_id: options._id,invited: findObject})
			
		if checkAlreadyInvited == undefined
			updateObject = {userId: invitedProfile._id}
			Models.update({_id: options._id},{$push: {invited: updateObject}})				
		else
			throw new Meteor.Error(498, "User already invited")		

	removeModelTag: (options)->
		if options._id == undefined || options.tag == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			return Models.update({_id: options._id},{$pull: {tags: options.tag}})

	removeModelInvite: (options)->
		if options._id == undefined || options.invite == undefined
			throw new Meteor.Error(490, "Undefined Parameter");
		else
			return Models.update({_id: options._id},{$pull: {invited: options.invite}})





findModelByName = (name)->
	return Models.findOne({name: name})

findOneModelByOptions = (options)->
	return Models.findOne(options)