
/*

 app.coffee
 */

(function() {
  $(function() {

    /* Configration & Initialize */
    var App, articles, articlesView, candidates, candidatesView, httpApi, ioApi, path, refresh, resetCandidates, socket;
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
    candidates = new Candidates();
    articlesView = new ArticlesView({
      collection: articles
    });
    candidatesView = new CandidatesView({
      model: null,
      collection: candidates
    });
    refresh = function(callback) {
      return httpApi.getLatestArticles(function(err, data) {
        var article, newArticles, _i, _len;
        if (err) {
          console.error(err);
          return notify.danger("Initialize Error.Please Reload.");
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
      App.pages.show(articlesView);
      return App.modals.show(candidatesView);
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
      return refresh();
    });
    socket.on("new article", function(data) {
      return refresh();
    });
    resetCandidates = function(data) {
      var candidate, newCandidates, _i, _len;
      newCandidates = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        candidate = data[_i];
        newCandidates.push(new Candidate(candidate));
      }
      candidates.reset(newCandidates);
      return $('.modal').modal();
    };
    return $('button#Find').click(function() {
      var query;
      query = $('#FindQuery').val();
      return httpApi.findFeed(query, function(err, data) {
        if (err) {
          return notify.danger(err);
        }
        if (_.isEmpty(data)) {
          return notify.danger("candidate not found");
        }
        return resetCandidates(data);
      });
    });
  });

}).call(this);
