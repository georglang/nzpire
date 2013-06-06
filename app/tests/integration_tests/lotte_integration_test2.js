this.open('http://localhost:3000', function() {
  this.describe('SignUp and Login', function() {
    this.assert.ok(this.$('#login-buttons').length, 'expects login buttons');
    this.success();
  });

  this.describe('Check if social media buttons exists', function() {
    this.assert.ok(this.$('#socialMediaButtons').length, 'expects social media buttons');
    this.success();
  });

  this.describe('Check if impressum link exists', function() {
    this.assert.ok(this.$('#impressum').length, 'expects impressum link');
    this.success();
  });
});

this.describe('Check content on impressum page',function(){
  this.open('impressum', function(){
    this.assert.equal('Georg Lang', 'expects text georg lang');
    this.sucess();
  });
}); 
