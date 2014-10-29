window.ArticleView = Backbone.Marionette.ItemView.extend
  template:"#articleTemplate"

window.ArticlesView = Backbone.Marionette.CollectionView.extend
  childView:ArticleView
  className:'panel-group'

