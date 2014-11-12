###

  FeedEvent.coffee

###

debug  = require('debug')('stdin/events/feed')
_      = require 'underscore'
async  = require 'async'
domain = require 'domain'
finder = require 'find-rss'
finder.setOptions
  favicon:true
  getDetail:true

module.exports.FeedEvent = (app) ->

  Feed        = app.get('models').Feed

  # GET /api/feed/find
  # @param url
  findFeed: (req,res,next)->
    url = req.query.url
    # Feedが既にあればドキュメントを返す
    Feed.findOne
      url:url
    ,(err,feed)=>
      app.emit 'error',err if err
      return res.json feed if feed

      @findFeedAlias url,(err,urls)->
        return res.status(500).send err if err
        return res.send urls

      return res.send 400 if not url or _.isEmpty url

  findFeedAlias:(url,callback)->
    # Find-RSS
    d = domain.create()
    d.on 'error',(err)-> app.emit 'error',err

    d.run ->
      finder url,(err,candidates)=>
        if err
          app.emit 'error',err if err
          return callback err,null

        # 選択させずに全て登録する
        urls = []
        alreadyUrls = []
        async.forEach candidates, (candidate,cb)->
          # 既にある場合は弾く
          Feed.findOne url:candidate.url,(err,doc)->
            if err
              app.emit 'error',err if err
              return cb()
            if doc
              alreadyUrls.push doc.feed.link
              return cb()
            debug "Register:#{candidate.url}"
            # Feed 作成
            Feed.create
              url:candidate.url
              feed:candidate
            ,(err,doc)->
              if err
                app.emit 'error',err if err
                return cb()
              app.get('crawler').createWatcher doc,(err)->
                urls.push doc.feed.link
                return cb()
        ,->
          callback null,
            added:urls
            alreadyAdded:alreadyUrls


  # POST /api/feed/subscribe
  # @param feed
  subscribe: (req,res,next)->
    feed = JSON.parse req.body.feed

    return res.send 400 if not feed or _.isEmpty feed

    # 既にある場合は弾く
    Feed.findOne url:feed.url,(err,doc)->
      if err
        app.emit 'error',err if err
        return res.send 500
      if doc
        return res.status(400).send("already subscribed")

      # Feed 作成
      Feed.create
        url:feed.url
        feed:feed
      ,(err,doc)->
        if err
          app.emit 'error',err if err
          return res.send 500
        if doc
          app.get('crawler').createWatcher doc,(err)->
            if err
              app.emit 'error',err
              return res.send 500
            res.send 200
