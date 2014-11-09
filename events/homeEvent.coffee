###

  HomeEvent.coffee

###

module.exports.HomeEvent = (app) ->

  index: (req,res,next)->
    res.render "index",
      memoryUsage:"#{process.memoryUsage().rss/1024/1024}MB"

