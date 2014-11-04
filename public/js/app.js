
/*

 app.coffee
 */

(function() {
  $(function() {

    /* Configration & Initialize */
    var App, articles, articlesView, httpApi, path, refresh;
    _.templateSettings = {
      interpolate: /\{\{(.+?)\}\}/g
    };
    path = window.location.pathname.substr(1);
    httpApi = httpApiWrapper;
    articles = new Articles();
    articlesView = new ArticlesView({
      collection: articles
    });
    refresh = function(callback) {
      return httpApi.getLatestArticles(function(err, data) {
        var article, newArticles, _i, _len;
        if (err) {
          console.error(err);
          notify.danger("Initialize Error.Please Reload.");
          if (callback) {
            return callback();
          }
        }
        newArticles = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          article = data[_i];
          newArticles.push(new Article(article));
        }
        articles.reset(newArticles);
        notify.success("Refreshed");
        if (callback) {
          return callback();
        }
      });
    };
    App = new Backbone.Marionette.Application();
    App.addRegions({
      modals: '#Modals',
      pages: '#Pages'
    });
    App.addInitializer(function(options) {
      return App.pages.show(articlesView);
    });
    $(document).ready(function() {
      return refresh(function() {
        return App.start();
      });
    });
    return $('button#Find').click(function() {
      var query;
      query = $('#FindQuery').val();
      return httpApi.findFeed(query, function(err, data) {
        var title, _i, _j, _len, _len1, _ref, _ref1, _results;
        if (err) {
          return notify.danger(err);
        }
        _ref = data.added;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          title = _ref[_i];
          notify.success("Added: " + title);
        }
        _ref1 = data.alreadyAdded;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          title = _ref1[_j];
          _results.push(notify.info("Already Added:" + title));
        }
        return _results;
      });
    });
  });

}).call(this);
