###

Crawler.coffee
全FeedのCrawlerをメモリに持つ

###

debug = require('debug')('stdin/crawler/feed')
_    = require 'underscore'
async = require 'async'
request = require 'request'
DTimer = require('dtimer').DTimer
redis = require('redis')
url = require("url")
path = require 'path'

if process.env.REDISCLOUD_URL
  redisURL = url.parse(process.env.REDISCLOUD_URL)
  client   = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  client.auth redisURL.auth.split(":")[1]
  pub      = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  pub.auth redisURL.auth.split(":")[1]
  sub      = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  sub.auth redisURL.auth.split(":")[1]

else
  client = redis.createClient()
  pub    = redis.createClient()
  sub    = redis.createClient()

Feed = (require path.resolve 'models','FeedSchema').Feed
Page = (require path.resolve 'models','PageSchema').Page

exports = module.exports = class FeedCrawler
  app = null

  constructor:(_app)->
    app             = _app
    @timer          = new DTimer("stdin", pub, sub)
    @interval       = app.get('timer interval')
    @concurrency    = app.get 'feed crawler queue'
    @parseAndUpdate = async.queue parser,@concurrency
    app.set 'feedCrawlerQueue', @parseAndUpdate

    # タイマーセット
    @timer.on 'error',(err)-> return app.emit 'error',err
    @timer.on 'event',(object)=>
      debug "DTimer posted:#{object.url}. queue:#{@parseAndUpdate.length()}"

      # 取得/追加
      @parseAndUpdate.push {app:app,url:object.url},(err)=>
        return app.emit 'error',err if err

        # 取得/計算終了時、タイマー起動
        @timer.post {url:object.url},@interval,(err,evId)->
          return app.emit 'error',err if err

    # タイマー起動
    @timer.join (err)->
      return throw Error("Cant Generate Redis Event Listener:#{err}") if err
      debug "dtimer setup completed."


  initialize: ->
    debug "Feed Crawler Start:Interval #{@interval/(60*1000)}min"
    Feed.find {}, (err,feeds)=>
      return debug err if err

      async.forEach feeds,(feed,cb)=>
        @createWatcher feed,(err)->
          return cb()
      ,->
        debug "FeedCrawler Initialize End"

  # タイマーセット
  createWatcher:(feed,callback)->
    @timer.post {url:feed.url},0,(err,evId)->
      if err
        app.emit 'error',err if err
        return callback err if callback
      debug "Create Watcher #{feed.feed.title}"
      return callback

# パーサ
parser = (object,callback)->
  debug "parseAndUpdate #{object.url}"

  # Feed探索
  Feed.findOne url:object.url,(err,feed)->
    return callback err if err

    # リクエスト/Parsing
    req = request object.url
    req.on 'error',(err)-> return callback err
    req.on 'response',(res)->
      return this.emit 'error', new Error('Bad status code') if res.statusCode isnt 200
      stream = this
      stream.pipe feedParser

    articles = []
    newArticles = []
    feedParser = new (require('feedparser'))({addmeta:true})
    feedParser.on 'error', (err)-> return object.app.emit 'error',err
    feedParser.on 'readable', ->
      stream = this
      # 記事ごとに、新着かどうか判定
      if article = stream.read()
        articles.push article
      else return

      if not _.contains(feed.links,article.link)
        newArticles.push article

    feedParser.on 'end', ->

      # 新着記事が存在しない場合、終了
      if articles.length is 0 or newArticles.length is 0
        debug "Nothing New Articles:#{object.url}"
        return callback()

      # 新着記事が存在する場合,ページオブジェクト更新
      debug "new Articles:#{newArticles.length} in #{object.url}"
      async.forEach newArticles,(article,cb)->
        Page.upsertOneWithFeed article,feed,(err,page)->
          object.app.emit 'error',err if err
          return cb()
      ,(err)->
        # ページリストをfeedに書き込み
        feed.update links:_.pluck(articles,'link'),(err)->
          return callback err if err
          return callback()
