###

Crowler.coffee
全FeedのCrowlerをメモリに持つ

###

debug = require('debug')('stdin/crowler/feed')
domain = require('domain')
_    = require 'underscore'
async = require 'async'
Watcher = require 'rss-watcher'
request = require 'request'

exports = module.exports = (app)->

  Feed = app.get('models').Feed
  Page = app.get('models').Page

  # api
  addToSet:(feed)->
    @createWatcher(feed)

  createWatcher : (feed)->
    d = domain.create()
    d.on 'error',(err)->
      app.emit 'error',err
    d.run =>
      watcher = new Watcher(feed.url)
      watcher.set
        interval:60*3 # @todo frequency moduleがオカシイ
      watcher.on 'new article',(article)=>
        # あれば追加しない
        Page.findOne link:article.link,=>
          return debug "Already Registerd Link Is Published.#{article.link}"
          debug "New Article. #{article.link}"
          Page.upsertOneWithFeed article,feed,(err,page)=>
            return app.emit 'error', err if err
            @setToJubatus.push page

            # 擬似Populate
            pageObject = page.toObject()
            page.feed = feed
            app.emit 'new article',
              page:page

      watcher.run (err,articles)=>
        return app.emit 'error', err if err

        for article in articles
          Page.upsertOneWithFeed article,feed,(err,page)=>
            return app.emit 'error', err if err
            @setToJubatus.push page
            app.emit 'new feed',
              feed:feed

  initialize : ->
    Feed.find {}, (err,feeds)=>
      return debug err if err
      for feed in feeds
        @createWatcher(feed)

  # Jubatusにセットするキュー
  setToJubatus:async.queue (page,callback)->
    d = domain.create()
    d.on 'error',(err)->
      app.emit 'error',err
      callback()
    d.run ->
      return if not page.link or page.link is "" or page.link is null

      request page.link,(err,res,body)->
        if err
          app.emit 'error', err
          return callback()
        if res.statusCode isnt 200
          debug "error setToJubatus:#{page.link} #{res.statusCode}"
          return callback()

        request.post
          url:app.get('jubatus_url')+"/set"
          body:
            id:page._id
            text:getExtractContent(body)
          json:true
        ,(err,response,body)->
          if err or response.statusCode isnt 200
            debug "error postToJubatusProxy:#{page.link} #{res.statusCode}"
            return callback()
          debug "Page #{page.article.title} has set in Jubatus"
          return callback()
    ,2

# 本文抽出
# とりあえずサニタイズ,タグ外しのみ
getExtractContent = (string)->
  return string.replace /<.+?>/g," "
