Template.footer.events

	'click #impressum': ()->
			console.log "clicked impressum"
			Workspace.impressum()
			false