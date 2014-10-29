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
  candidates     = new Candidates()

  articlesView   = new ArticlesView
    collection:articles
  candidatesView = new CandidatesView
    model: null
    collection:candidates

  # Helper Method
  refresh = (callback)->
    httpApi.getLatestArticles (err,data)->
      if err
        console.error err
        return notify.danger "Initialize Error.Please Reload."

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
    App.modals.show candidatesView # @note modalなので常にshowしておいてjsで制御する

  # 初回記事読み込み
  $(document).ready ->
    refresh ->
      App.start()

  # 繋ぎ直した時
  socket.on 'reconnect',->
    refresh()

  ## Socket.io EventHandlers ##
  socket.on "new feed", (data)->
    refresh()
  socket.on "new article", (data)->
    refresh()

  resetCandidates = (data)->
    newCandidates = []
    for candidate in data
      newCandidates.push new Candidate candidate
    candidates.reset newCandidates
    $('.modal').modal()

  ## Navigation Event @note backboneに落としこむ
  $('button#Find').click ->
    query = $('#FindQuery').val()
    httpApi.findFeed query,(err,data)->
      return notify.danger err if err
      return notify.danger "candidate not found" if _.isEmpty data
      resetCandidates(data)

