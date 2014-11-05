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

### Detect NewRelic Enability ###
newrelicEnable = (
  process.env.NEW_RELIC_APP_NAME? and
  process.env.NEW_RELIC_LICENSE_KEY? and
  process.env.NEW_RELIC_NO_CONFIG_FILE?
) or fs.existsSync('./newrelic.js')

console.log "using newrelic:#{newrelicEnable}"
if newrelicEnable
  require 'newrelic'

# @todo エラー処理はNewRelicに投げる
app.on "error",(err)->
  debug err

process.on 'uncaughtException',(err)->
  debug err

# 初期化処理
server = http.createServer app
app.get('models').Page.syncRandom (err,result)->
  return app.emit err if err
  return debug "SyncRandom done"

## クローラ起動

# RSSクローラ
crowler = require(path.resolve 'crowler','feed') app
crowler.initialize()
app.set 'crowler',crowler

# はてなクローラ
hatenaCrowler = require(path.resolve 'crowler','hatenaHotentry')
hatenaCrowler(app)
recursiveCrowl = ->
  setTimeout ->
    hatenaCrowler(app)
    recursiveCrowl()
  ,1000*60*60*1 # 1hour


server.listen app.get("port"), ->
  debug "Express server listening on port " + app.get("port")

