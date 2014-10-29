window.ArticleView = Backbone.Marionette.ItemView.extend
  template:"#articleTemplate"

window.ArticlesView = Backbone.Marionette.CollectionView.extend
  childView:ArticleView
  className:'panel-group'

window.CandidateView = Backbone.Marionette.ItemView.extend
  template:"#candidateTemplate"
  modelEvents:
    change: "render"
  ui:
    button:"button"
  events:
    "click @ui.button":"subscribe"

  # Sub/Unsub
  subscribe:->
    path = (window.location.pathname).substr(1)
    httpApi = httpApiWrapper
    httpApi.postSubscribeFeed
      feed: this.model.toJSON()
    ,(err,data)=>
      return notify.danger err if err
      return notify.success "Subscribed"

window.CandidatesView = Backbone.Marionette.CompositeView.extend
  template:"#candidatesRootTemplate"
  childView:CandidateView
  childViewContainer:"ol"

