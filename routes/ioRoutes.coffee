###

  ioRoutes.coffee
  socket.io event Routing

###

module.exports = exports = (app,io,socket) ->

  # include events
  Events       = app.get('events')

  # 記事配信
  app.on "new article",(article)->
    return debug "new article"

  # フィード追加通知
  app.on "new feed",(feed)->
    return debug "new feed"

