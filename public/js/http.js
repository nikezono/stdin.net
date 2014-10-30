(function() {
  window.httpApiWrapper = {
    findFeed: function(url, callback) {
      return $.getJSON("/api/feed/find", {
        url: url
      }).success(function(data) {
        return callback(null, data);
      }).error(function(err) {
        return callback(err, null);
      });
    },
    getLatestArticles: function(callback) {
      return $.getJSON("/api/page/latest").success(function(data) {
        return callback(null, data);
      }).error(function(err) {
        return callback(err, null);
      });
    },
    getSimilarArticles: function(id, callback) {
      return $.getJSON("/api/page/" + id + "/similar").success(function(data) {
        return callback(null, data);
      }).error(function(err) {
        return callback(err, null);
      });
    }
  };

}).call(this);
