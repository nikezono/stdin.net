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

  # Refresh button
  $('#Refresh').click ->
    animateFlag = true
    animate = ->
      $("#Refresh").animate
        zIndex: 1
      ,
        duration: 500
        step: (now) ->
          return $(this).css transform: "rotate(" + (now * 360) + "deg)"
        complete: ->
          $("#Refresh").css('zIndex', 0)
          animate() if animateFlag
    animate()
    refresh ->
      animateFlag = false

  # Find Button
  $('button#Find').click ->
    query = $('#FindQuery').val()
    httpApi.findFeed query,(err,data)->
      return notify.danger err if err
      for title in data.added
        notify.success "Added: #{title}"
      for title in data.alreadyAdded
        notify.info "Already Added:#{title}"
