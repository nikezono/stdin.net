###

  ioRoutes.coffee
  socket.io event Routing

###

debug = require('debug')('stdin/routes/ioRoutes')
module.exports = exports = (app,io,socket) ->

  # include events
  Events       = app.get('events')

