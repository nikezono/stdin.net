###

  PageEvent.coffee

###

debug = require("debug")("stdin/events/page")
_     = require 'underscore'
request = require 'request'
async = require 'async'

module.exports.PageEvent = (app) ->
  Page        = app.get("models").Page

  # GET /api/page/list
  getPageList: (req,res,next)->

    # Options
    # 実行順
    options = req.query
    options.random ||= false # ランダムに出す
    options.populateFeed ||= true # Feedの情報を取得する
    options.sortByPubDate ||= true # PubDateでソートする
    options.limit ||= 100 # Limit:件数制限

    promise = Page
    promise = promise.find() if not options.random
    promise = promise.findRandom() if options.random
    promise = promise.populate('feed') if options.populateFeed
    promise = promise.sort('article.pubDate':-1) if options.sortByPubDate
    promise = promise.limit(options.limit)
    promise = promise.exec (err,pages)->
      if err
        app.emit 'error', err
        return res.send 500
      return res.send 404 if not pages or _.isEmpty pages
      return res.json pages

  # GET /api/page/stream
  # 追加される度に流していくhttpStream
  # @todo 実装
  getPageStream: (req,res,next)->

    # Options
    options = req.query
    res.send []

  # GET /api/page/latest
  getLatestPages: (req,res,next)->

    req.query.random = false
    req.query.sortByPubDate = true
    @getPageList req,res,next # @note リダイレクトのほうがいい？


  getSimilarPages: (req,res,next)->

    id = req.params.id
    return res.send 400 if not id

    # @todo 実装
    return res.json []


