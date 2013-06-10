/*
FH Salzburg 2013
MultiMediaTechnology
Lizenz: GNU Affero General Public License (AGPL)

Students:
Altmann Christoph
Lang Georg
Margreiter Daniel
Schaekermann Mike
*/

this.open('http://localhost:3000', function() {
  this.describe('Logo', function() {
    this.assert.ok(this.$('#logo').length, 'expects logo to be in the DOM');
    //this.success();
  });
  /*
	this.describe('CreateModelInput', function(){
		this.$('#model').click(function(){
			this.assert.ok(this.$('#modelName').length, 'expects create input to be in the DOM');
			this.success();
		});
	});
*/
});