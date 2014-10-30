###

Crowler.coffee
全FeedのCrowlerをメモリに持つ

###

debug = require('debug')('stdin/config/crowler')
_    = require 'underscore'
Watcher = require 'rss-watcher'
request = require 'request'

exports = module.exports = (app)->

  Feed = app.get('models').Feed
  Page = app.get('models').Page

  # api
  addToSet:(feed)->
    Feed.findOne url:feed.url,(err,doc)->
      return app.emit 'error', err if err
      return debug "already added. #{feed.url}" if doc
      @createWatcher(feed)

  createWatcher : (feed)->
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
    request.post
      url:app.get('jubatus_url')+"/set"
      body:
        id:page._id
        text:page.article.description # @note 本文fetchしてsanitizeして使ったほうがいいかも
      json:true
    ,(err,response,body)->
      return debug err if err
      debug "Page #{page.article.title} has set in Jubatus"
      debug "New Page or update. #{page.article.title}"



