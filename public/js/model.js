(function() {
  window.Article = Backbone.Model.extend({
    initialize: function(attr, opts) {
      var timestamp;
      timestamp = new Date(this.pubDate) / 1000;
      return this.set("timestamp", timestamp);
    }
  });

  window.Articles = Backbone.Collection.extend(Article);

}).call(this);
