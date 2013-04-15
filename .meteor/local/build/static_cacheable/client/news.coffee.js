(function(){ var getModelNews, getProfileNews, sortArrayByTimestamp;

getModelNews = function() {
  var models;
  models = Models.find({
    _id: {
      $in: currentProfile().favourites
    }
  }, {
    sort: {
      updatedAt: -1
    },
    limit: 10
  }).fetch();
  return models;
};

getProfileNews = function() {
  var profiles;
  profiles = Profiles.find({
    _id: {
      $in: currentProfile().following
    }
  }, {
    sort: {
      updatedAt: -1
    },
    limit: 10
  }).fetch();
  return profiles;
};

sortArrayByTimestamp = function(a, b) {
  if (a.updatedAt > b.updatedAt) {
    return -1;
  }
  if (a.updatedAt < b.updatedAt) {
    return 1;
  }
  return 0;
};

Template.news.getNews = function() {
  var result, result2;
  result = getModelNews();
  result2 = getProfileNews();
  jQuery.merge(result, result2);
  result.sort(sortArrayByTimestamp);
  return result;
};

})();
