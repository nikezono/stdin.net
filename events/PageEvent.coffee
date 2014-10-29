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

    Page.find({}).populate('feed').sort('article.pubDate':-1).limit(100).exec (err,pages)->
      if err
        app.emit 'error', err
        return res.send 500

      return res.send 404 if not pages or _.isEmpty pages

      return res.json pages

  getSimilarPages: (req,res,next)->

    id = req.params.id
    return res.send 400 if not id

    request.get
      url:app.get("jubatus_url")+"/neighbor" #@todo 修正
      body:
        id:id
      json:true
    ,(err,response,body)->
      if err
        app.emit 'error',err
        return res.send 500
      if not response.statusCode is 200
        debug response
        return res.send 500
      else
        #ids = _.pluck body,"id"
        # @note Findするとscore順に並ばないっぽい.毎回findOneするヤバいコードになってる
        #Page.find(_id:{ $in:ids }).populate("feed").exec (err,docs)->
        #  if err
        #    app.emit 'error',err
        #return res.send 500
        #  return res.json docs
        #
        respArray = []
        async.forEach body,(result,cb)->
          Page.findOne(_id:result.id).populate('feed').exec (err,doc)->
            if err
              app.emit 'error',err
              return cb()
            if not doc
              return cb()
            respArray.push doc
            return cb()
        ,->
          return res.json respArray


