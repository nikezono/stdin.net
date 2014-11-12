###

  HomeEvent.coffee

###

debug = require('debug')('stdin/events/home')
module.exports.HomeEvent = (app) ->

  index: (req,res,next)->
    hatenaCrowlerQueue = app.get 'hatenaCrawlerQueue'
    feedCrowlerQueue = app.get 'feedCrawlerQueue'
    debug feedCrowlerQueue
    res.render "index",
      memoryUsage:"#{process.memoryUsage().rss/1024/1024}MB"
      hatena:hatenaCrowlerQueue?.length() || 0
      feed:feedCrowlerQueue?.length() || 0

