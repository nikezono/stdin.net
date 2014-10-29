###

 app.coffee

###

$ ->

  ### Configration & Initialize ###
  _.templateSettings =
    interpolate: /\{\{(.+?)\}\}/g

  path = (window.location.pathname).substr(1)
  socket = io "/#{path}"

  httpApi = httpApiWrapper
  ioApi   = ioApiWrapper(socket)

  socket.on "connect",->
    notify.info "Connected."

  socket.on "error",(err)->
    notify.danger err

  socket.on "serverError",(err)->
    console.error err
    console.trace()
    alert.danger("Error")

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

  # 繋ぎ直した時
  socket.on 'reconnect',->
    refresh()

  ## Socket.io EventHandlers ##
  socket.on "new feed", (data)->
    console.log data
    notify.info "New Feed:#{data.feed.url}"
    refresh()
  socket.on "new article", (data)->
    console.log data
    notify.info "New Article:#{data.page.article.title}"
    Articles.unshift new Article(data.page)

## Navigation Event @note backboneに落としこむ
  $('button#Find').click ->
    query = $('#FindQuery').val()
    httpApi.findFeed query,(err,data)->
      return notify.danger err if err
      for title in data.added
        notify.success "Added: #{title}"
      for title in data.alreadyAdded
        notify.info "Already Added:#{title}"

