
/*

 app.coffee
 */

(function() {
  $(function() {

    /* Configration & Initialize */
    var App, articles, articlesView, httpApi, ioApi, path, refresh, socket;
    _.templateSettings = {
      interpolate: /\{\{(.+?)\}\}/g
    };
    path = window.location.pathname.substr(1);
    socket = io("/" + path);
    httpApi = httpApiWrapper;
    ioApi = ioApiWrapper(socket);
    socket.on("connect", function() {
      return notify.info("Connected.");
    });
    socket.on("error", function(err) {
      return notify.danger(err);
    });
    socket.on("serverError", function(err) {
      console.error(err);
      console.trace();
      return alert.danger("Error");
    });
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
    socket.on('reconnect', function() {
      return refresh();
    });
    socket.on("new feed", function(data) {
      console.log(data);
      notify.info("New Feed:" + data.feed.url);
      return refresh();
    });
    socket.on("new article", function(data) {
      console.log(data);
      notify.info("New Article:" + data.page.article.title);
      return Articles.unshift(new Article(data.page));
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
