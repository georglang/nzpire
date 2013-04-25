this.open('http://localhost:3000', function() {
  this.describe('Logo', function() {
    this.assert.ok(this.$('.brand').length, 'expects logo to be in the DOM');
    this.success();
  });
});