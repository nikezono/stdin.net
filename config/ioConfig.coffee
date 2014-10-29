###

  io.coffee
  socket.ioのevent設定ファイル

###

path  = require 'path'
debug = require('debug')('stdin/config/io')
async = require 'async'
_     = require 'underscore'

module.exports = (app, server) ->

  # setup socket.io
  io = (require 'socket.io').listen server

  # 記事配信
  app.on "new article",(data)->
    io.sockets.emit 'new article',data

  # フィード追加通知
  app.on "new feed",(data)->
    io.sockets.emit 'new feed',data

  # Routing
  io.sockets.on "connection", (socket) ->

    # on Error
    socket.on "error", (err)->
      app.emit 'error', err

    # Use Router
    (require path.resolve('routes','ioRoutes')) app,io,socket
