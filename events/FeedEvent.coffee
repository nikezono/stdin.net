###

  FeedEvent.coffee

###

debug  = require('debug')('stdin/events/feed')
_      = require 'underscore'
finder = require 'find-rss'
finder.setOptions
  favicon:true
  getDetail:true

module.exports.FeedEvent = (app) ->

  Feed        = app.get('models').Feed

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
        return res.json candidates

  subscribe: (req,res,next)->
    feed = req.query.feed

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
          res.send 200

