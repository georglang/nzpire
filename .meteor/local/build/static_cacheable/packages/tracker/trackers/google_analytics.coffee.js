(function(){ var GoogleAnalyticsTracker;

GoogleAnalyticsTracker = (function() {

  function GoogleAnalyticsTracker(options) {
    var ga, s;
    this._gaq = this._gaq || [];
    ga = document.createElement('script');
    ga.type = 'text/javascript';
    ga.async = true;
    ga.src = (document.location.protocol === 'https:' ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(ga, s);
    this._gaq.push(['_setAccount', options.account]);
  }

  GoogleAnalyticsTracker.prototype.track = function(identifier, parameters) {
    this._gaq.push(['_trackEvent', identifier, 'clicked', parameters]);
    return console.log(identifier);
  };

  GoogleAnalyticsTracker.prototype.identify = function() {};

  return GoogleAnalyticsTracker;

})();

})();
