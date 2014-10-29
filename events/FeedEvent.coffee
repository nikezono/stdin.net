###

  FeedEvent.coffee

###

debug  = require('debug')('stdin/events/feed')
_      = require 'underscore'
async  = require 'async'
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

    return res.send 400 if not url or _.isEmpty url

    # Feedが既にあればドキュメントを返す
    Feed.findOne
      url:url
    ,(err,feed)->
      app.emit 'error',err if err
      return res.json feed if feed

      # Find-RSS
      finder url, (err,candidates)=>
        if err
          app.emit 'error',err if err
          return res.send 500

        # 選択させずに全て登録する
        urls = []
        alreadyUrls = []
        async.forEach candidates, (candidate,cb)->
          # 既にある場合は弾く
          Feed.findOne url:candidate.url,(err,doc)->
            return cb() app.emit 'error',err if err
            if doc
              alreadyUrls.push doc.feed.title
              return cb()

            # Feed 作成
            Feed.create
              url:candidate.url
              feed:candidate
            ,(err,doc)->
              if err
                app.emit 'error',err if err
                return cb()
              app.get('crowler').addToSet doc
              urls.push doc.feed.title
              return cb()
        ,->
          res.send
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
          app.get('crowler').addToSet doc
          res.send 200

