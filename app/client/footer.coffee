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

Template.footer.events

	'click #impressum': ()->
			console.log "clicked impressum"
			Workspace.impressum()
			false

Template.footer.activeModelingClass = ->
  if 'model' is Session.get 'template'
    console.log 'active footer modeling'
    return 'activeModeling'