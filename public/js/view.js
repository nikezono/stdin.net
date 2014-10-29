(function() {
  window.ArticleView = Backbone.Marionette.ItemView.extend({
    template: "#articleTemplate"
  });

  window.ArticlesView = Backbone.Marionette.CollectionView.extend({
    childView: ArticleView,
    className: 'panel-group'
  });

  window.CandidateView = Backbone.Marionette.ItemView.extend({
    template: "#candidateTemplate",
    modelEvents: {
      change: "render"
    },
    ui: {
      button: "button"
    },
    events: {
      "click @ui.button": "subscribe"
    },
    subscribe: function() {
      var httpApi, path;
      path = window.location.pathname.substr(1);
      httpApi = httpApiWrapper;
      return httpApi.postSubscribeFeed({
        feed: this.model.toJSON()
      }, (function(_this) {
        return function(err, data) {
          if (err) {
            return notify.danger(err);
          }
          return notify.success("Subscribed");
        };
      })(this));
    }
  });

  window.CandidatesView = Backbone.Marionette.CompositeView.extend({
    template: "#candidatesRootTemplate",
    childView: CandidateView,
    childViewContainer: "ol"
  });

}).call(this);
