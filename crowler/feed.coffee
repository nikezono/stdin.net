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
      debug "New Watcher:#{feed.url}"
      watcher = new Watcher(feed.url)
      watcher.set
        interval:60*3 # @todo frequency moduleがオカシイ
      watcher.on 'error',(err)-> return app.emit 'error',err
      watcher.on 'new article',(article)=>
        # あれば追加しない
        Page.findOne link:article.link,(err,doc)=>
          return app.emit 'error',err if err
          return debug "Already Registerd Link Is Published.#{article.link}" if doc
          debug "New Article. #{article.link}"
          Page.upsertOneWithFeed article,feed,(err,page)=>
            return app.emit 'error', err if err

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
            app.emit 'new feed',
              feed:feed

  initialize : ->
    Feed.find {}, (err,feeds)=>
      return debug err if err
      for feed in feeds
        @createWatcher(feed)


