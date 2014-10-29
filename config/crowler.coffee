###

Crowler.coffee
全FeedのCrowlerをメモリに持つ

###

debug = require('debug')('config/crowler')
_    = require 'underscore'
Watcher = require 'rss-watcher'

exports = module.exports = (app)->

  Feed = app.get('models').Feed
  Page = app.get('models').Page

  # api
  addToSet:(feed)->
    Feed.findOne url:feed.url,(err,doc)->
      return app.emit 'error', err if err
      return debug "already added. #{url}" if doc
      @createWatcher(feed)

  createWatcher : (feed)->
    watcher = new Watcher(feed.url)
    watcher.set
      interval:60*3 # @todo frequency moduleがオカシイ
    watcher.on 'new article',(article)=>
      debug "new article on #{url}"
      Page.upsertOneWithFeed article,feed,(err,page)->
        return app.emit 'error', err if err
        app.emit 'new article',
          page:page
          feed:feed

    watcher.run (err,articles)=>
      return app.emit 'error', err if err

      for article in articles
        Page.upsertOneWithFeed article,feed,(err,page)->
          return app.emit 'error', err if err
          app.get('emitter').emit 'new feed',
            feed:feed

  initialize : ->
    Feed.find {}, (err,feeds)=>
      return debug err if err
      for feed in feeds
        @createWatcher(feed)


