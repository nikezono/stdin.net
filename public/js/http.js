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
    postSubscribeFeed: function(data, callback) {
      return $.ajax("/api/feed/subscribe", {
        type: "POST",
        data: {
          feed: JSON.stringify(data.feed)
        },
        success: function(data) {
          return callback(null, data);
        },
        error: function(err) {
          return callback(err, null);
        }
      });
    }
  };

}).call(this);
