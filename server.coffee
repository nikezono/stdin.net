###

  server.coffee
  起動スクリプト

###

# dependency
http  = require "http"
path  = require 'path'
fs    = require 'fs'
debug = require('debug')("stdin/server")

### Detect NewRelic Enability ###
newrelicEnable = (
  process.env.NEW_RELIC_APP_NAME? and
  process.env.NEW_RELIC_LICENSE_KEY? and
  process.env.NEW_RELIC_NO_CONFIG_FILE?
) or fs.existsSync('./newrelic.js')

console.log "using newrelic:#{newrelicEnable}"
newrelic = require 'newrelic' if newrelicEnable

# user library
app   = require path.resolve('config','expressConfig')
app.on "error",(err)->
  newrelic.noticeError err if newrelicEnable
  debug err

process.on 'uncaughtException',(err)->
  newrelic.noticeError err if newrelicEnable
  debug err
  process.exit 1

# 初期化処理
server = http.createServer app
app.get('models').Page.syncRandom (err,result)->
  return app.emit err if err
  debug "SyncRandom done"

# サーバ起動
server.listen app.get("port"), ->
  debug "Express server listening on port " + app.get("port")

## クローラ起動
# RSSクローラ
FeedCrawler = require(path.resolve 'crawler','feed')
crawler = new FeedCrawler(app)
crawler.initialize()
app.set 'crawler',crawler

# はてなクローラ
hatenaCrawler = require(path.resolve 'crawler','hatenaHotentry')
hatenaCrawler(app)
recursiveCrawl = ->
  setTimeout ->
    hatenaCrawler(app)
    recursiveCrawl()
  ,1000*60*60*1 # 1hour
