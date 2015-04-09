###

 app.coffee

###

$ ->

  ### Configration & Initialize ###
  _.templateSettings =
    interpolate: /\{\{(.+?)\}\}/g

  path = (window.location.pathname).substr(1)

  httpApi = httpApiWrapper

 # Model & View Initialize
  articles       = new Articles()

  articlesView   = new ArticlesView
    collection:articles

  # Helper Method
  refresh = (callback)->
    httpApi.getLatestArticles (err,data)->
      if err
        console.error err
        notify.danger "Initialize Error.Please Reload."
        return callback() if callback
      refreshModel data,callback

  refreshRandom = (callback)->
    httpApi.getPageList
      limit:20
      random:true
      sortByPubDate:false
    ,(err,data)->
      if err
        console.error err
        notify.danger "Initialize Error.Please Reload."
        return callback() if callback
      refreshModel data,callback

  refreshModel = (data,callback)->
    articles.reset []
    for article in data
      articles.push new Article(article)
    notify.success "Refreshed"
    return callback() if callback

  ## Marionette ##
  App = new Backbone.Marionette.Application()
  App.addRegions
    modals: '#Modals'
    pages: '#Pages'

  App.addInitializer (options)->
    App.pages.show articlesView

  # 初回記事読み込み
  $(document).ready ->
    refresh ->
      App.start()

  ## Navigation Event @note backboneに落としこむ
  animateFlag = true
  animate = ($dom)->
    $dom.animate
      zIndex: 1
    ,
      duration: 500
      step: (now) ->
        return $dom.css transform: "rotate(" + (now * 360) + "deg)"
      complete: ->
        $dom.css('zIndex', 0)
        animate($dom) if animateFlag

  # Refresh button
  $('#Refresh').click ->
    animateFlag = true
    animate($('#Refresh'))
    refresh ->
      animateFlag = false

  # Random button
  $('#Random').click ->
    animateFlag = true
    animate($('#Random'))
    refreshRandom ->
      animateFlag = false


