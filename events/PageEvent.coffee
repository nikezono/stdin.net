###

  PageEvent.coffee

###

debug = require("debug")("stdin/events/page")
_     = require 'underscore'
request = require 'request'
async = require 'async'

module.exports.PageEvent = (app) ->
  Page        = app.get("models").Page

  getLatestPages: (req,res,next)->

    limit = req.query.limit or 100

    Page.find({}).populate('feed').sort('article.pubDate':-1).limit(limit).exec (err,pages)->
      if err
        app.emit 'error', err
        return res.send 500

      return res.send 404 if not pages or _.isEmpty pages

      return res.json pages

  getSimilarPages: (req,res,next)->

    id = req.params.id
    return res.send 400 if not id

    # @todo 実装
    return res.json []


