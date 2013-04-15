(function(){ /*

Usage:
AppTracker = new Tracker();
AppTracker.register(GoogleAnalyticsTracker, 'UA-XXXXXX');

In your router or controllers:
AppTracker.track('Clicked link ' + slug);
*/

var Tracker;

Tracker = (function() {
  var identify;

  function Tracker(name) {
    this.name = name;
    this._trackers = [];
  }

  Tracker.prototype.register = function(tracker, options) {
    return this._trackers.push(new tracker(options));
  };

  Tracker.prototype.unregister = function(callback) {
    return this._trackers.forEach(function(tracker) {
      if (tracker === callback) {
        return this.children.splice(i, 1);
      }
    });
  };

  identify = function() {};

  Tracker.prototype.track = function(event, parameters) {
    return this._trackers.forEach(function(tracker) {
      return tracker.track(event, parameters);
    });
  };

  return Tracker;

})();

})();
