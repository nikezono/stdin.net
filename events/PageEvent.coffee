###

  PageEvent.coffee

###

debug = require("debug")("stdin/events/page")
_     = require 'underscore'

module.exports.PageEvent = (app) ->


  Page        = app.get("models").Page

  getLatestPages: (req,res,next)->

    Page.find({}).populate('feed').sort('article.pubDate':-1).limit(100).exec (err,pages)->
      if err
        app.emit 'error', err
        return res.send 500

      return res.send 404 if not pages or _.isEmpty pages

      return res.json pages

  getSimilarPages: (req,res,next)->

    debug req
    return res.send "not implemented"

