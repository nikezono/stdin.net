
/*

 app.coffee
 */

(function() {
  $(function() {

    /* Configration & Initialize */
    var App, animate, animateFlag, articles, articlesView, httpApi, path, refresh, refreshModel, refreshRandom;
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
        if (err) {
          console.error(err);
          notify.danger("Initialize Error.Please Reload.");
          if (callback) {
            return callback();
          }
        }
        return refreshModel(data, callback);
      });
    };
    refreshRandom = function(callback) {
      return httpApi.getPageList({
        limit: 20,
        random: true,
        sortByPubDate: false
      }, function(err, data) {
        if (err) {
          console.error(err);
          notify.danger("Initialize Error.Please Reload.");
          if (callback) {
            return callback();
          }
        }
        return refreshModel(data, callback);
      });
    };
    refreshModel = function(data, callback) {
      var article, _i, _len;
      articles.reset([]);
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        article = data[_i];
        articles.push(new Article(article));
      }
      notify.success("Refreshed");
      if (callback) {
        return callback();
      }
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
    animateFlag = true;
    animate = function($dom) {
      return $dom.animate({
        zIndex: 1
      }, {
        duration: 500,
        step: function(now) {
          return $dom.css({
            transform: "rotate(" + (now * 360) + "deg)"
          });
        },
        complete: function() {
          $dom.css('zIndex', 0);
          if (animateFlag) {
            return animate($dom);
          }
        }
      });
    };
    $('#Refresh').click(function() {
      animateFlag = true;
      animate($('#Refresh'));
      return refresh(function() {
        return animateFlag = false;
      });
    });
    $('#Random').click(function() {
      animateFlag = true;
      animate($('#Random'));
      return refreshRandom(function() {
        return animateFlag = false;
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
