###

  HomeEvent.coffee

###

debug = require('debug')('stdin/events/home')
module.exports.HomeEvent = (app) ->

  Feed = app.get('models').Feed
  AnalyzeQueue = app.get('models').AnalyzeQueue

  index: (req,res,next)->
    hatenaCrawlerQueue = app.get 'hatenaCrawlerQueue'
    feedCrawlerQueue = app.get 'feedCrawlerQueue'
    Feed.count (err,count)->
      if err
        app.emit 'error',err
        return res.send 500
      res.render "index",
        memoryUsage:"#{process.memoryUsage().rss/1024/1024}MB"
        search:hatenaCrawlerQueue?.length() || "undef" # フィード探索キュー残数
        feed:feedCrawlerQueue?.length() || "undef" # フィード取得キュー残数
        analyze:AnalyzeQueue?.length() || "undef"
        feedCount:count || "undef"
