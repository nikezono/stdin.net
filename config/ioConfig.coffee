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

  # Routing
  io.sockets.on "connection", (socket) ->

    # on Error
    socket.on "error", (err)->
      app.emit 'error', err

    # Use Router
    (require path.resolve('routes','ioRoutes')) app,io,socket
