###

Crowler.coffee
全FeedのCrowlerをメモリに持つ

###

debug = require('debug')('stdin/crowler/feed')
domain = require('domain')
_    = require 'underscore'
async = require 'async'
request = require 'request'

DTimer = require('dtimer').DTimer

redis = require('redis')
url = require("url")

if process.env.REDISCLOUD_URL
  redisURL = url.parse(process.env.REDISCLOUD_URL)
  client = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  client.auth redisURL.auth.split(":")[1]
  pub = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  pub.auth redisURL.auth.split(":")[1]
  sub = redis.createClient(redisURL.port, redisURL.hostname,no_ready_check: true)
  sub.auth redisURL.auth.split(":")[1]

else
  client = redis.createClient()
  pub = redis.createClient()
  sub = redis.createClient()

exports = module.exports = (app)->

  Feed = app.get('models').Feed
  Page = app.get('models').Page

  # タイマーを生成
  dt = new DTimer("stdin", pub, sub)
  dt.on 'error',(err)-> return app.emit 'error',err


  parseAndUpdate = async.queue (url,callback)->

    debug "parseAndUpdate #{url}"

    # Feed探索
    Feed.findOne url:url,(err,feed)->
      return callback err if err

      # リクエスト/Parsing
      req = request url
      req.on 'error',(err)-> return callback err
      req.on 'response',(res)->
        return this.emit 'error', new Error('Bad status code') if res.statusCode isnt 200
        stream = this
        stream.pipe feedParser

      articles = []
      newArticles = []
      feedParser = new (require('feedparser'))({addmeta:true})
      feedParser.on 'error', (err)-> return app.emit 'error',err
      feedParser.on 'readable', ->
        stream = this

        # 記事ごとに、新着かどうか判定
        if article = stream.read()
          articles.push article
        else return

        if not _.contains(feed.links,article.link)
          debug "new Articles:#{article.link}"
          newArticles.push article

      feedParser.on 'end', ->
        return callback() if articles.length is 0 or newArticles.length is 0

        # ページオブジェクト更新
        async.forEach newArticles,(article,cb)->
          Page.upsertOneWithFeed article,feed,(err,page)->
            if err
              app.emit 'error',err
              return cb()
            pageObject = page.toObject()
            page.feed = feed
            app.emit 'new article',
              page:page
            return cb()
        ,->
          # ページリストをfeedに書き込み
          feed.update links:_.pluck(articles,'link'),(err)->
            return callback err if err
            return callback()
  ,app.get('feed crawler queue')

  app.set 'feedCrawlerQueue', parseAndUpdate

  # Helper
  parseAndUpdate:parseAndUpdate

  createWatcher: (feed,callback)->
    debug "New Watcher:#{feed.url}"
    @parseAndUpdate.push feed.url,(err)=>
      return callback err if err

      debug "Initialize End:#{feed.url}"

      # タイマーセット
      dt.post {url:feed.url},1000*60*3,(err,evId)->
        return app.emit 'error', err if err

      return callback()

  initialize : ->

    @initializeTimer()
    Feed.find {}, (err,feeds)=>
      return debug err if err
      for feed in feeds
        @createWatcher feed,(err)->
          return app.emit 'error',err if err
          debug "Create Watcher #{feed.feed.title}"

  initializeTimer: ->

    # イベント時処理
    dt.on 'event',(object)=>
      url = object.url
      debug "DTimer:#{url}"

      # 取得/追加
      @parseAndUpdate.push url,(err)->
        return app.emit 'error',err if err

        # 取得/計算終了時、タイマー起動
        dt.post {url:url},1000*60*3,(err,evId)->
          return app.emit 'error',err if err

    # タイマー起動
    dt.join (err)->
      return throw Error("Cant Generate Redis Event Listener:#{err}") if err
      debug "dtimer setup completed."


