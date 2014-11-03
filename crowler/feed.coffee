###

Crowler.coffee
全FeedのCrowlerをメモリに持つ

###

debug = require('debug')('stdin/config/crowler')
domain = require('domain')
_    = require 'underscore'
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
            @setToJubatus page

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
            @setToJubatus page
            app.emit 'new feed',
              feed:feed

  initialize : ->
    Feed.find {}, (err,feeds)=>
      return debug err if err
      for feed in feeds
        @createWatcher(feed)

  setToJubatus:(page)->
    request page.link,(err,res,body)->
      return app.emit 'error', err if err
      return debug "error setToJubatus:#{page.link} #{res.statusCode}" if res.statusCode isnt 200

      request.post
        url:app.get('jubatus_url')+"/set"
        body:
          id:page._id
          text:getExtractContent(body)
        json:true
      ,(err,response,body)->
        return debug err if err
        debug "Page #{page.article.title} has set in Jubatus"
        debug "New Page Founded or Updated. #{page.article.title}"

# 本文抽出
# とりあえずサニタイズ,タグ外しのみ
getExtractContent = (string)->
  return string.replace /<.+?>/g," "
