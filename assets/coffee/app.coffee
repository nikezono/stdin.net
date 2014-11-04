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

      newArticles = []
      for article in data
        newArticles.push new Article(article)
      articles.reset newArticles
      notify.success "Refreshed"
      refreshPanelEvent()
      return callback() if callback

  refreshPanelEvent = ->
    $('button.Similar').click (e)->
      query = $(this).attr("id")
      httpApi.getSimilarArticles query,(err,data)->
        return notify.danger err if err
        newArticles = []
        for page in data
          newArticles.push new Article(page)
        articles.reset newArticles
        notify.success "Refreshed"
        refreshPanelEvent()


  ## Marionette ##
  App = new Backbone.Marionette.Application()
  App.addRegions
    modals: '#Modals'
    pages: '#Pages'

  App.addInitializer (options)->
    App.pages.show articlesView
    refreshPanelEvent()

  # 初回記事読み込み
  $(document).ready ->
    refresh ->
      App.start()

  ## Navigation Event @note backboneに落としこむ
  $('button#Find').click ->
    query = $('#FindQuery').val()
    httpApi.findFeed query,(err,data)->
      return notify.danger err if err
      for title in data.added
        notify.success "Added: #{title}"
      for title in data.alreadyAdded
        notify.info "Already Added:#{title}"

