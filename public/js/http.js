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
      return $.getJSON("/api/page/latest?limit=20").success(function(data) {
        return callback(null, data);
      }).error(function(err) {
        return callback(err, null);
      });
    },
    getPageList: function(options, callback) {
      return $.getJSON("/api/page/list", options).success(function(data) {
        return callback(null, data);
      }).error(function(err) {
        return callback(err, null);
      });
    }
  };

}).call(this);
