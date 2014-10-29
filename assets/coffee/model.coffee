## Model ##
window.Article   = Backbone.Model.extend
  initialize:(attr,opts)->
    timestamp = new Date(this.pubDate) / 1000
    this.set "timestamp",timestamp

## Collection ##
window.Articles = Backbone.Collection.extend Article

