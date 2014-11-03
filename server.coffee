###

  server.coffee
  起動スクリプト

###

# dependency
http  = require "http"
path  = require 'path'
fs    = require 'fs'
debug = require('debug')("stdin/server")

# user library
app   = require path.resolve('config','expressConfig')
io    = require path.resolve('config','ioConfig')

### Detect NewRelic Enability ###
newrelicEnable = (
  process.env.NEW_RELIC_APP_NAME? and
  process.env.NEW_RELIC_LICENSE_KEY? and
  process.env.NEW_RELIC_NO_CONFIG_FILE?
) or fs.existsSync('./newrelic.js')

console.log "using newrelic:#{newrelicEnable}"
if newrelicEnable
  require 'newrelic'
  # @todo 以下
  app.on "error",(err)->
    debug err
  #   newrelic.postErrorEvent 的な何か

### start socket.io and http server ###
server = http.createServer app
io app,server

### start rss crowler ###
crowler = require(path.resolve 'crowler','feed') app
crowler.initialize()
app.set 'crowler',crowler

### start hatena-hotentry crowler ###
hatenaCrowler = require(path.resolve 'crowler','hatenaHotentry')
hatenaCrowler(app)
recursiveCrowl = ->
  setTimeout ->
    hatenaCrowler(app)
    recursiveCrowl()
  ,1000*60*60 # 1hour


server.listen app.get("port"), ->
  debug "Express server listening on port " + app.get("port")

